# Git Worktrees

Git worktrees let you have multiple working directories from the same repository. Instead of stashing changes or cloning the repo again, you can check out different branches in separate folders simultaneously.

## Why Use Worktrees?

- **Work on multiple branches at once** - Fix a bug on `main` while your feature branch stays open
- **Review PRs without context switching** - Check out a PR in a separate directory, review it, then go back to your work
- **Run long processes** - Run tests or builds in one worktree while developing in another
- **Compare implementations** - Have two versions side-by-side in different editors

## Quick Start

### Create a Worktree

```bash
# From your main repo directory
git worktree add ../my-feature feature-branch

# Creates:
# ../my-feature/  ← new working directory
#   └── (all repo files, checked out to feature-branch)
```

### List Worktrees

```bash
git worktree list
# /path/to/repo         abc1234 [main]
# /path/to/my-feature   def5678 [feature-branch]
```

### Remove a Worktree

```bash
# When done with the branch
git worktree remove ../my-feature

# Or if the directory was deleted manually
git worktree prune
```

## Common Workflows

### Review a Pull Request

```bash
# Create a worktree for the PR
git fetch origin pull/123/head:pr-123
git worktree add ../pr-123 pr-123

# Review the code in ../pr-123
cd ../pr-123
# run tests, examine files, etc.

# Clean up when done
cd ../main-repo
git worktree remove ../pr-123
git branch -D pr-123
```

### Hotfix While Working on a Feature

```bash
# You're working on feature-x, but need to fix a bug on main
git worktree add ../hotfix main

cd ../hotfix
git checkout -b hotfix-urgent
# make fixes, commit, push, create PR

# Return to your feature work
cd ../main-repo
git worktree remove ../hotfix
```

### Compare Two Branches

```bash
# Create worktrees for both branches
git worktree add ../version-1 v1.0
git worktree add ../version-2 v2.0

# Open both in your editor/IDE
code ../version-1
code ../version-2
```

## Directory Organization

A recommended structure for worktrees:

```
~/projects/
├── my-repo/              ← main worktree (usually main/master)
├── my-repo-feature-x/    ← feature branch worktree
├── my-repo-pr-review/    ← temporary PR review worktree
└── my-repo-hotfix/       ← hotfix worktree
```

Or use a dedicated worktrees folder:

```
~/projects/
├── my-repo/              ← main worktree
└── my-repo-worktrees/
    ├── feature-x/
    ├── pr-review/
    └── hotfix/
```

## Using Worktrees with Claude Code

Each worktree is a separate directory, so you can run Claude Code independently in each one:

```bash
# Terminal 1: Working on feature
cd ~/projects/my-repo
claude

# Terminal 2: Reviewing a PR
cd ~/projects/my-repo-pr-review
claude
```

Each Claude Code session will have its own context and conversation history.

## Tips

### Create a Worktree for a New Branch

```bash
# Create worktree AND new branch in one command
git worktree add -b new-feature ../new-feature main
```

### Worktrees Share Git History

All worktrees share the same `.git` data. Commits, branches, and stashes are visible from any worktree. Only the working directory and index are separate.

### Don't Check Out the Same Branch Twice

Git prevents checking out a branch that's already checked out in another worktree. If you need the same code in two places, create a new branch:

```bash
# This fails if 'main' is checked out elsewhere
git worktree add ../test main  # Error!

# Instead, create a branch from main
git worktree add -b test-copy ../test main  # Works
```

### Clean Up Regularly

```bash
# See all worktrees
git worktree list

# Remove worktrees you're done with
git worktree remove ../old-worktree

# Clean up if directories were manually deleted
git worktree prune
```

## Comparison: Worktrees vs. Alternatives

| Approach | Pros | Cons |
|----------|------|------|
| **Worktrees** | Fast, shared history, lightweight | Multiple directories to manage |
| **Git stash** | Simple, single directory | Loses context, can forget stashes |
| **Multiple clones** | Fully isolated | Slow, uses more disk space, separate fetches |
| **Branch switching** | Familiar workflow | Interrupts work, can't run parallel processes |

## Further Reading

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [Atlassian Git Worktree Tutorial](https://www.atlassian.com/git/tutorials/git-worktree)
