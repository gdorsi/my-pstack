# Sync this fork

my-pstack is a fork of [backnotprop/pstack](https://github.com/backnotprop/pstack). backnotprop/pstack mirrors Cursor's pstack and rewrites its Cursor-only instructions so they work in Claude Code, Codex, and other agents. A merge from backnotprop/pstack brings in both. The fork also carries 17 UI skills copied from [emilkowalski/skills](https://github.com/emilkowalski/skills), pinned to one commit in `vendor/emilkowalski-skills/manifest`.

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

## Update Emil Kowalski's skills

Emil's skills live in `skills/` next to pstack's. `vendor/emilkowalski-skills/manifest` pins the upstream commit and lists the skills.

1. From the repo root, run the sync.

	```bash
	vendor/emilkowalski-skills/sync.sh --update
	```

2. Review the diff. The script rewrites the `commit` line and the copied skills, and it fails on a broken relative link or a reference to a skill the manifest leaves out.
3. Open a PR.

Never edit a vendored skill by hand. The next sync overwrites it.

To add or drop a skill, edit `manifest`. Delete a dropped skill's directory by hand, then rerun `vendor/emilkowalski-skills/sync.sh`. Run it without `--update` to stay on the pinned commit.
