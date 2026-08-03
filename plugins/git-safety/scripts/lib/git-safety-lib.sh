#!/bin/bash
# Git Safety - shared dangerous-file matcher.
# git-safety-version: 2
#
# Sourced by the pre-commit and pre-push hooks. Contains no machine-specific
# paths: it is published to a public plugin repository.

GIT_SAFETY_VERSION=2

# Tier 2: shell and REPL history files, matched by exact basename.
GS_T2_HISTORY=(
    .zsh_history .sh_history .history .python_history .node_repl_history
    .psql_history .mysql_history .irb_history .lesshst .rediscli_history
    .sqlite_history
)

# Tier 4: credential files, matched by exact basename.
#
# Deliberately EXCLUDED: .npmrc and credentials.json. Both are routinely
# committed and benign - .npmrc as a registry config in JS projects,
# credentials.json as a filename in GCP tooling. This library ships to a
# public plugin, and a check that cries wolf gets uninstalled.
GS_T4_NAMES=(
    .netrc _netrc .pgpass .pypirc .git-credentials .htpasswd
    .terraformrc terraform.tfstate .kubeconfig
)

# Known public CA bundle filenames.
#
# These are collections of public certificates, not key material. The bundle
# `ca-certs.pem` appears in 14 repos on this machine; because pre-push
# classifies tier 3b by NAME (it cannot afford a content read across a whole
# push range), those repos could not push a branch at all.
#
# IMPORTANT: this list is consulted by pre-push ONLY, via
# gs_is_public_cert_name. gs_classify_path does NOT exempt these names, so
# pre-commit still classifies ca-certs.pem as T3b-candidate and content-checks
# it. A genuine CA bundle passes that check; a private key wearing the name
# does not.
#
# Exempting them in gs_classify_path was measurably wrong: gitleaks catches
# RSA/EC/DSA/PKCS#8/OpenSSH key material by content, but NOT PuTTY-format
# keys. A .ppk-format key named ca-certs.pem committed clean under the
# blanket exemption, while gs_has_private_key would have caught it. The
# exemption was never needed in pre-commit anyway - the content check already
# let real bundles through.
#
# `cacerts` is deliberately absent - the Java truststore is a keystore format
# and stays in tier 3a.
GS_PUBLIC_CERT_NAMES=(
    ca-certs.pem cacert.pem ca-bundle.pem ca-certificates.pem
    ca-certs.crt ca-bundle.crt ca-certificates.crt
)

# gs_is_public_cert_name <path>
# Exit 0 if the basename is a known public CA bundle. For pre-push, which
# cannot content-check across a push range. Never used by pre-commit.
gs_is_public_cert_name() {
    local base="${1##*/}" n r=1 gs_nc=0
    shopt -q nocasematch && gs_nc=1
    shopt -s nocasematch
    for n in "${GS_PUBLIC_CERT_NAMES[@]}"; do
        if [[ "$base" == "$n" ]]; then r=0; break; fi
    done
    [ $gs_nc -eq 0 ] && shopt -u nocasematch
    return $r
}

# Tier 4: credential files that are only meaningful as a path suffix.
GS_T4_PATHS=(
    .aws/credentials .docker/config.json .kube/config .ssh/authorized_keys
)

# gs_classify_path <path>
# Echo a tier label if the path is dangerous by NAME alone, else nothing.
# Never inspects file content. T3b-candidate means "content check required".
#
# Matching is case-insensitive: files from case-insensitive filesystems and
# Windows tooling routinely arrive as .Pem, ID_RSA, or .BASH_HISTORY.
#
# Case-insensitivity uses `shopt -s nocasematch` (bash 3.1+, inside our floor)
# rather than lowercasing with `printf | tr`. That helper forked twice per
# call, and with the caller's own command substitution cost ~10ms per path.
# Invisible when pre-push scanned a handful of paths - but it now walks full
# history on a new ref, where it measured 68 SECONDS of pure classify time on
# a 6,747-path repo. A push that appears to hang gets --no-verify'd.
#
# Scoped and restored here rather than set globally: gs_is_allowlisted's glob
# match MUST stay case-sensitive. Single exit point so the restore cannot be
# skipped by an early return. `shopt -q` is a builtin - no fork.
gs_classify_path() {
    local path="$1"
    local base="${path##*/}"
    local n r='' gs_nc=0

    shopt -q nocasematch && gs_nc=1
    shopt -s nocasematch

    while :; do
        # Public keys are meant to be committed.
        case "$base" in
            *.pub) break ;;
        esac

        # NOTE: public CA bundle names are deliberately NOT exempted here.
        # They fall through to tier 3b and are decided by content. See
        # GS_PUBLIC_CERT_NAMES - the exemption belongs to pre-push alone.

        # Tier 1 - deliberately broad bash match.
        case "$base" in
            .bash*|*.bash*) r='T1-bash'; break ;;
        esac

        # Tier 2 - histories.
        for n in "${GS_T2_HISTORY[@]}"; do
            [[ "$base" == "$n" ]] && { r='T2-history'; break; }
        done
        [ -n "$r" ] && break

        # Tier 3a - formats that exist only to hold key material.
        case "$base" in
            *.p12|*.pfx|*.jks|*.keystore|*.ppk|*.kdbx|*.p8)
                r='T3a-keystore'; break ;;
        esac

        # Tier 3b - ambiguous text formats; caller must check content.
        case "$base" in
            id_rsa|id_dsa|id_ecdsa|id_ed25519) r='T3b-candidate'; break ;;
            *.pem|*.key|*.asc|*.gpg|*.ovpn)    r='T3b-candidate'; break ;;
        esac

        # Tier 4 - credential files by basename.
        for n in "${GS_T4_NAMES[@]}"; do
            [[ "$base" == "$n" ]] && { r='T4-cred'; break; }
        done
        [ -n "$r" ] && break

        # Tier 4 - credential files by path suffix.
        for n in "${GS_T4_PATHS[@]}"; do
            [[ "$path" == "$n" || "$path" == */"$n" ]] && { r='T4-cred'; break; }
        done
        break
    done

    [ $gs_nc -eq 0 ] && shopt -u nocasematch
    [ -n "$r" ] && printf '%s' "$r"
    return 0
}

# gs_pattern_too_broad <pattern>
# Exit 0 if an allowlist pattern matches a known-dangerous canary without
# naming it literally. A fixed blacklist of "*", "**" etc. is not enough:
# `?*` and `[a-z._]*` also match everything and walked straight through it.
gs_pattern_too_broad() {
    local pat="$1" c
    # Canaries are DERIVED from the tier tables, not hand-maintained. A
    # parallel literal list drifted twice: `*.p8`, `*.keystore`, `*.tfstate`,
    # `.ssh/*`, `.aws/*` and `.kube/*` were all accepted and would have
    # released every matching file in the repo from gate 2.
    local canaries=(
        .bash_history a/.bash_history a/b/.bash_history
        id_rsa secrets/id_rsa a/b/id_rsa
        app.p12 app.pfx app.jks app.keystore key.ppk vault.kdbx key.p8
        server.pem deploy.key key.asc key.gpg vpn.ovpn
        "${GS_T2_HISTORY[@]}" "${GS_T4_NAMES[@]}" "${GS_T4_PATHS[@]}"
    )
    for c in "${canaries[@]}"; do
        case "$c" in
            $pat)
                # Naming a canary literally is a deliberate, reviewable choice.
                case "$pat" in
                    *"$c"*) ;;
                    *) return 0 ;;
                esac
                ;;
        esac
    done
    return 1
}

# gs_has_private_key
# Read a blob on stdin. Exit 0 if it contains private key material.
gs_has_private_key() {
    grep -qE 'PRIVATE KEY|PuTTY-User-Key-File|BEGIN [A-Z ]*PRIVATE'
}

# gs_load_allowlist <repo_root>
# Populate GS_ALLOW from <repo_root>/.gitsafety-allow.
#
# Three guards stop the escape hatch becoming a hole in the gate it serves:
#   1. The file must be TRACKED. An untracked allowlist would govern the gate
#      while appearing in no diff and no review.
#   2. Over-broad patterns are refused. A single "*" would disable gate 2 for
#      every file in the repo.
#   3. Applied entries are echoed by the caller, so exemptions show up in the
#      commit transcript.
gs_load_allowlist() {
    local repo_root="$1"
    local line tmp
    GS_ALLOW=()

    # Read the INDEX BLOB, not the working-tree file. Checking only that the
    # PATH is tracked while reading unversioned CONTENT is not a guard at all:
    # commit a benign allowlist, append a dangerous line without staging it,
    # and gate 2 honours a rule that appears in no diff and no review.
    # Verified bypass. `git show :path` also fails for an unindexed path, so
    # this subsumes the tracked check.
    if ! tmp=$(mktemp); then
        echo "[Git Safety] WARNING: mktemp failed - .gitsafety-allow IGNORED." >&2
        echo "[Git Safety]          Check TMPDIR. Exemptions will not apply." >&2
        return 0
    fi
    if ! git -C "$repo_root" show ":.gitsafety-allow" > "$tmp" 2>/dev/null; then
        rm -f "$tmp"
        if [[ -f "${repo_root}/.gitsafety-allow" ]]; then
            echo "[Git Safety] WARNING: .gitsafety-allow is not in the index - IGNORING it." >&2
            echo "[Git Safety]          Run: git add .gitsafety-allow" >&2
        fi
        return 0
    fi

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Strip comments: whole-line, or preceded by whitespace. A bare '#'
        # mid-token is legal in a filename and must not truncate the pattern.
        line="${line%"${line##*[![:space:]]}"}"
        case "$line" in
            '#'*) continue ;;
        esac
        line="${line%%[[:space:]]#*}"
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        [[ -z "$line" ]] && continue

        if gs_pattern_too_broad "$line"; then
            echo "[Git Safety] WARNING: refusing over-broad .gitsafety-allow entry: $line" >&2
            continue
        fi

        GS_ALLOW+=("$line")
    done < "$tmp"
    rm -f "$tmp"
}

# gs_is_allowlisted <path>
# Exit 0 if the path matches an allowlist glob.
gs_is_allowlisted() {
    local path="$1" pattern
    [[ ${#GS_ALLOW[@]} -eq 0 ]] && return 1
    for pattern in "${GS_ALLOW[@]}"; do
        # shellcheck disable=SC2053
        [[ "$path" == $pattern ]] && return 0
    done
    return 1
}
