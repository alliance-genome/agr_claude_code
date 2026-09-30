#!/bin/bash
# Tests for the ripsecrets gate and in-place (pre-commit framework) layout of
# the git-safety pre-commit hook.
#
# Hermetic: HOME points at a temp dir and stub scanners are placed in
# $HOME/.local/bin, which the hook puts first on PATH. No real scanner runs
# unless REAL_RIPSECRETS=/path/to/ripsecrets is set.
#
# Usage: bash plugins/git-safety/tests/test-pre-commit-ripsecrets.sh

set -u

SCRIPTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

PASS=0
FAIL=0
ok()   { PASS=$((PASS + 1)); echo "ok   - $1"; }
fail() { FAIL=$((FAIL + 1)); echo "FAIL - $1"; [ -n "${2:-}" ] && printf '%s\n' "$2" | sed 's/^/       /'; }

export HOME="$WORK/home"
STUBS="$HOME/.local/bin"
mkdir -p "$STUBS"
export GIT_CONFIG_GLOBAL="$WORK/gitconfig"
export GIT_CONFIG_NOSYSTEM=1
git config --file "$GIT_CONFIG_GLOBAL" user.email test@example.org
git config --file "$GIT_CONFIG_GLOBAL" user.name test
git config --file "$GIT_CONFIG_GLOBAL" init.defaultBranch main

# Scanners that must never run from the host during these tests.
for t in gitleaks trufflehog; do
    printf '#!/bin/sh\nexit 0\n' > "$STUBS/$t"
done

# Stub ripsecrets: records cwd and args, reports any line containing
# FAKE-SECRET as "path:line:content" (the real tool's format), exits 1.
# RS_STUB_MODE=error simulates a tool failure.
cat > "$STUBS/ripsecrets" <<'STUB'
#!/bin/bash
{ echo "cwd=$PWD"; printf 'arg=%s\n' "$@"; [ -f .secretsignore ] && echo "secretsignore=$(cat .secretsignore)"; } >> "$HOME/rs.log"
if [ "${RS_STUB_MODE:-}" = error ]; then echo "Error: boom" >&2; exit 2; fi
found=0
for a in "$@"; do
    case "$a" in --*) continue ;; esac
    n=0
    while IFS= read -r line || [ -n "$line" ]; do
        n=$((n + 1))
        case "$line" in *FAKE-SECRET*) echo "$a:$n:$line"; found=1 ;; esac
    done < "$a"
done
exit $found
STUB
chmod +x "$STUBS"/*

new_repo() {
    local r="$WORK/repo$1"
    git init -q "$r"
    (cd "$r" && echo init > README && git add README && git commit -q -m init)
    printf '%s' "$r"
}

# Run the hook in place from the plugin tree (library under scripts/lib/).
run_inplace() { (cd "$1" && bash "$SCRIPTS_DIR/pre-commit") 2>&1; }

# Run the hook as installed by /secure-repo (library beside the hook).
run_copied() {
    local hooks
    hooks=$(cd "$1" && git rev-parse --git-path hooks)
    (cd "$1" && mkdir -p "$hooks" \
        && cp "$SCRIPTS_DIR/lib/git-safety-lib.sh" "$hooks/git-safety-lib.sh" \
        && cp "$SCRIPTS_DIR/pre-commit" "$hooks/pre-commit" \
        && bash "$hooks/pre-commit") 2>&1
}

# --- 1. finding blocks, output is file:line only -------------------------
R=$(new_repo 1)
(cd "$R" && printf 'a = 1\ntoken = FAKE-SECRET-value-xyz\n' > app.py && git add app.py)
rm -f "$HOME/rs.log"
OUT=$(run_inplace "$R"); RC=$?
if [ $RC -ne 0 ] && grep -q "ripsecrets Found Secrets" <<<"$OUT" && grep -q "app.py:2" <<<"$OUT"; then
    ok "ripsecrets finding blocks the commit and names file:line"
else
    fail "ripsecrets finding blocks the commit and names file:line" "$OUT"
fi
if grep -q "FAKE-SECRET" <<<"$OUT"; then
    fail "matched line content is not echoed" "$OUT"
else
    ok "matched line content is not echoed"
fi

# --- 2. clean content passes, library found under scripts/lib ------------
R=$(new_repo 2)
(cd "$R" && echo 'print(1)' > ok.py && git add ok.py)
OUT=$(run_inplace "$R"); RC=$?
if [ $RC -eq 0 ] && grep -q "\[ripsecrets\] No secrets detected" <<<"$OUT"; then
    ok "clean commit passes when run in place from the plugin tree"
else
    fail "clean commit passes when run in place from the plugin tree" "$OUT"
fi

# --- 3. copied install layout still works --------------------------------
OUT=$(run_copied "$R"); RC=$?
if [ $RC -eq 0 ] && grep -q "All checks passed" <<<"$OUT"; then
    ok "copied install (library beside hook) passes"
else
    fail "copied install (library beside hook) passes" "$OUT"
fi

# --- 4. tool failure fails closed ----------------------------------------
OUT=$(RS_STUB_MODE=error run_inplace "$R"); RC=$?
if [ $RC -ne 0 ] && grep -q "ripsecrets failed" <<<"$OUT"; then
    ok "ripsecrets error blocks the commit"
else
    fail "ripsecrets error blocks the commit" "$OUT"
fi

# --- 5. dotfiles are passed explicitly; index .secretsignore is used -----
R=$(new_repo 5)
(cd "$R" && printf 'x.txt\n' > .secretsignore && git add .secretsignore && git commit -q -m ignore \
    && printf 'unstaged-edit\n' > .secretsignore \
    && echo 'DB=1' > .env && git add .env)
rm -f "$HOME/rs.log"
OUT=$(run_inplace "$R"); RC=$?
if [ $RC -eq 0 ] && grep -qx "arg=.env" "$HOME/rs.log"; then
    ok "staged dotfile is passed to ripsecrets"
else
    fail "staged dotfile is passed to ripsecrets" "$OUT
$(cat "$HOME/rs.log" 2>/dev/null)"
fi
if grep -qx "secretsignore=x.txt" "$HOME/rs.log"; then
    ok "index copy of .secretsignore is used, not the working tree"
else
    fail "index copy of .secretsignore is used, not the working tree" "$(cat "$HOME/rs.log" 2>/dev/null)"
fi

# --- 6. no scanners at all warns -----------------------------------------
rm -f "$STUBS/gitleaks" "$STUBS/trufflehog" "$STUBS/ripsecrets"
R=$(new_repo 6)
(cd "$R" && echo hi > a.txt && git add a.txt)
OUT=$(PATH=/usr/bin:/bin run_inplace "$R"); RC=$?
if ! PATH=/usr/local/bin:/usr/bin:/bin command -v gitleaks trufflehog ripsecrets >/dev/null 2>&1; then
    if [ $RC -eq 0 ] && grep -q "no content scanner is installed" <<<"$OUT"; then
        ok "warns when no content scanner is installed"
    else
        fail "warns when no content scanner is installed" "$OUT"
    fi
else
    echo "skip - a real scanner is installed on this host"
fi

# --- 7. optional: real ripsecrets ----------------------------------------
if [ -n "${REAL_RIPSECRETS:-}" ] && [ -x "$REAL_RIPSECRETS" ]; then
    ln -sf "$REAL_RIPSECRETS" "$STUBS/ripsecrets"
    R=$(new_repo 7)
    # Built at runtime so no token-shaped literal lives in this file.
    TOKEN="gh""p_$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 36)"
    (cd "$R" && printf 'GITHUB_TOKEN=%s\n' "$TOKEN" > .env && git add .env)
    OUT=$(run_inplace "$R"); RC=$?
    if [ $RC -ne 0 ] && grep -q "\.env:1" <<<"$OUT" && ! grep -qF "$TOKEN" <<<"$OUT"; then
        ok "real ripsecrets blocks a token in a staged dotfile, redacted"
    else
        fail "real ripsecrets blocks a token in a staged dotfile, redacted" "$(sed "s/$TOKEN/<token>/g" <<<"$OUT")"
    fi
fi

echo ""
echo "passed: $PASS  failed: $FAIL"
[ $FAIL -eq 0 ]
