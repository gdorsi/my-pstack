# Sync this fork

my-pstack is a fork of [backnotprop/pstack](https://github.com/backnotprop/pstack). backnotprop/pstack mirrors Cursor's pstack and rewrites its Cursor-only instructions so they work in Claude Code, Codex, and other agents. A merge from backnotprop/pstack brings in both. The fork also carries Emil Kowalski's UI skills from [emilkowalski/skills](https://github.com/emilkowalski/skills) and Benji Taylor's `stageshow` from [benjitaylor/skills](https://github.com/benjitaylor/skills), each pinned to one commit in `vendor/<upstream>/manifest`.

This fork edits only these pstack files. Keep the list current, because a sync conflict can only come from a file on it or from a deleted path below.

- `README.md`: the whole file. The fork keeps its own version on every sync.
- `LICENSE`: a second copyright line for this fork's changes.
- `skills/poteto-mode/SKILL.md`: one trigger line that sends UI work to `references/ui-craft.md`.
- `docs/guide/05-build-and-clean.md`: the Comment Sicko link points to the copy in `skills/no-comments/references/`.
- `docs/guide/07-overnight.md`: the paragraph about the `benny` automation pack is gone.

The fork also deletes these pstack paths. No skill reads them.

- `.cursor-plugin/` and `plugin.json`: the Cursor plugin manifests.
- `agents/`: the `poteto-agent` and `comment-sicko` subagent definitions. `poteto-mode` spawns a general subagent where `poteto-agent` isn't registered, and `/no-comments` carries its own copy of Comment Sicko.
- `assets/` and `mirror-assets/`: the logo and the images in pstack's README.
- `automations/`: the `benny` automation pack, which runs only on Cursor Automations.

The fork also adds two files of its own next to pstack's.

- `skills/poteto-mode/references/ui-craft.md` routes UI work to Emil's skills and stageshow.
- `skills/poteto-mode/references/design-checklist.md` holds design rules adapted from [pbakaus/impeccable](https://github.com/pbakaus/impeccable). `vendor/impeccable/LICENSE` is impeccable's Apache-2.0 license. No script syncs this file. Edit it by hand, and keep a rule only when agents miss it without the file.

MIRROR.md and SYNC-LOG.md belong to backnotprop/pstack. Leave them unchanged. backnotprop edits SYNC-LOG.md almost every day, so a local edit conflicts with nearly every sync.

## Pull pstack updates

1. Add the remote once:

	```bash
	git remote add pstack https://github.com/backnotprop/pstack.git
	```

2. Merge it on a new branch, without committing yet:

	```bash
	git fetch pstack
	git switch -c sync-pstack origin/main
	git merge --no-commit pstack/main
	```

3. Restore this fork's README and delete anything the merge brought back under a deleted path. These commands also resolve conflicts on those paths, and they change nothing when the merge left them alone.

	```bash
	git checkout HEAD -- README.md
	git rm -r -q --ignore-unmatch .cursor-plugin agents assets automations mirror-assets plugin.json
	```

4. If another file conflicts, keep backnotprop's change and reapply this fork's edit on top. Then run `git commit`.
5. Open a PR and land it with a merge commit. A squash or rebase merge drops pstack's history, and the next `git merge pstack/main` then conflicts in every file.

## Update vendored skills

Vendored skills live in `skills/` next to pstack's. Each upstream has a `vendor/<upstream>/manifest` that pins one commit and lists the skills to copy. `vendor/sync.sh` reads every manifest and knows no upstream by name.

1. From the repo root, run the sync.

	```bash
	vendor/sync.sh                               # resync every upstream at its pinned commit
	vendor/sync.sh --update                      # move every upstream to its latest commit
	vendor/sync.sh --update benjitaylor-skills   # move one upstream, resync the rest at their pins
	```

2. Review the diff. The script rewrites the `commit` line and the copied skills. It fails on a broken relative link, a reference to a skill the manifest leaves out, a skill name that two manifests list, and a skill with no license.
3. After an update, read the diff under `skills/stageshow/scripts/`. Agents run those scripts on your machine.
4. Open a PR.

A manifest has these lines. A line that starts with `#` is a comment.

| Key | Count | Meaning |
|---|---|---|
| `repo` | 1 | Git URL of the upstream |
| `commit` | 1 | Full 40-character sha. `--update` rewrites it |
| `path` | 1 | Directory in the upstream that holds the skill folders. `skills` for Emil, `.` for Benji |
| `license` | 0 or 1 | File in the upstream that the sync copies to `vendor/<upstream>/LICENSE`. Leave it out when each skill ships its own `LICENSE` |
| `skill` | 1 or more | A skill folder under `path`. The sync copies it to `skills/<name>/` |

The sync prints `unlicensed: skills/<name>` for a skill that has neither a `license` line in its manifest nor its own `LICENSE`.

The sync sets `disable-model-invocation: true` on every vendored skill, so each one loads only from `/name` or a pstack route. The sync fails if a skill lacks the line.

Never edit a vendored skill by hand. The next sync overwrites it.

To add or drop a skill, edit its `manifest`. Delete a dropped skill's directory by hand, then rerun `vendor/sync.sh`. Run it without `--update` to stay on the pinned commit. To add an upstream, create `vendor/<owner>-<repo>/manifest` and run `vendor/sync.sh`. Nothing else registers it.

`skills/stageshow/` ships `package.json` and its lockfile but no `node_modules`. Run `npm install` in the installed `stageshow` folder before you use it. Don't run it in this repo, because the next sync deletes `node_modules` there.
