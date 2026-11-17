# Sync this fork

my-pstack is a fork of [backnotprop/pstack](https://github.com/backnotprop/pstack). backnotprop/pstack mirrors Cursor's pstack and rewrites its Cursor-only instructions so they work in Claude Code, Codex, and other agents. A merge from backnotprop/pstack brings in both.

This fork edits only these pstack files. Keep the list current, because a sync conflict can only come from a file on it.

- `README.md`: the block between `my-pstack:start` and `my-pstack:end`.

MIRROR.md and SYNC-LOG.md belong to backnotprop/pstack. Leave them unchanged. backnotprop edits SYNC-LOG.md almost every day, so a local edit conflicts with nearly every sync.

## Pull pstack updates

1. Add the remote once:

	```bash
	git remote add pstack https://github.com/backnotprop/pstack.git
	```

2. Merge it on a new branch:

	```bash
	git fetch pstack
	git switch -c sync-pstack origin/main
	git merge pstack/main
	```

3. If the merge conflicts, keep backnotprop's change and reapply this fork's edit on top.
4. Open a PR and land it with a merge commit. A squash or rebase merge drops pstack's history, and the next `git merge pstack/main` then conflicts in every file.
