# Global User Instructions

## Worktrees

When a skill calls `using-git-worktrees` and a worktree already exists for the
current branch, skip the creation steps (directory selection, `git worktree add`,
dependency install). Go directly to the baseline verification step, then proceed.
