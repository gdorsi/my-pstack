# my-pstack

This repo holds my agent skills. The base is [pstack](https://github.com/cursor/plugins/tree/main/pstack), Lauren Tan's engineering workflow for coding agents. This fork takes it from [backnotprop/pstack](https://github.com/backnotprop/pstack), which rewrites pstack's Cursor-only steps so they work in Claude Code, Codex, and other agents. On top of pstack, the fork adds UI skills from Emil Kowalski and Benji Taylor, and routes UI work in `poteto-mode` through them.

## Install

```bash
npx skills add gdorsi/my-pstack
```

The [`skills` CLI](https://skills.sh) lists every skill and asks which agents to install them into. Select all the skills. `poteto-mode` calls most of the others, and it reads Emil's skills from the folders next to its own.

After the install:

1. Run `/setup-pstack` once. It finds the models you can use and assigns one to each role. In Claude Code it writes them to `~/.claude/rules/pstack-models.md`.
2. Before you use `/stageshow`, run `npm install` in its installed folder.

## Use

Start any task that needs rigor with `/poteto-mode`:

```text
/poteto-mode this pr has a subtle bug where the scroll drifts every 750ms even when idle. repro first, then fix and verify.
```

`poteto-mode` matches the task to one of its 23 [playbooks](skills/poteto-mode/playbooks/), such as bug fix, feature, perf, refactoring, babysit, and autonomous run. It copies the playbook's steps into a todo list and calls other skills when a step needs them. The `principle-*` skills hold the 24 engineering rules it applies.

To find the right skill for a task, ask `/poteto-help`.

### Skills to call directly

| Skill | Use it when |
|---|---|
| `/how` | you want a walkthrough of how a subsystem works. |
| `/why` | you want to know why code was built this way, from the commits and PR discussions that introduced it. |
| `/teach` | you want to understand a change or subsystem, explained one diagram at a time. |
| `/recall` | you resume work and want your recent context on a topic rebuilt from your chat history. |
| `/ketchup` | you want to know what changed in this chat since your last message, and what waits on you. |
| `/architect` | you want the caller's usage, types, and module shape settled before code crosses a function boundary. |
| `/arena` | you want several attempts at the same task, then the best parts of each. |
| `/swarm` | you want parallel workers on separate slices of a task, with one combined report. |
| `/interrogate` | you want different models to try to break a diff. It keeps only the findings that a run proves. |
| `/blast-radius` | you want to know what else a small change could break. |
| `/tdd` | you fix a bug that a cheap local test can reproduce. |
| `/unslop` | you want AI patterns removed from writing. |
| `/bro` | you want the last message restated in plain words. |
| `/reflect` | a long task landed and you want its lessons written into a skill. |
| `/correct` | you keep correcting agents for the same mistake. |
| `/sharpen` | you want a prompt made deeper before you send it. |
| `/automate-me` | you want your own `-mode` skill, drafted from how you work. |

pstack's [guide](docs/guide/README.md) walks through a first real task. It assumes Cursor in places.

### UI work

Emil Kowalski's 17 skills cover animation, gestures, mobile web, prototyping, and UI polish. Benji Taylor's `stageshow` builds fake product UI in React and plain CSS, as a still illustration or an animated demo with a cursor.

[`ui-craft.md`](skills/poteto-mode/references/ui-craft.md) tells `poteto-mode` which of these skills to read at each playbook step. It sends product demos and app illustrations for marketing pages and docs to `stageshow`, and the rest of UI work to Emil's skills. Every UI change must also pass [`design-checklist.md`](skills/poteto-mode/references/design-checklist.md), a short list of rules for the rendered page that agents tend to miss.

These skills don't load on their own. Type `/animate`, `/stageshow`, or another skill name, or let `poteto-mode` pick one.

## How this fork differs from pstack

- It adds 17 of Emil Kowalski's skills and Benji Taylor's `stageshow`. A manifest in `vendor/` pins each upstream to one commit.
- `poteto-mode` sends UI work through `ui-craft.md` and `design-checklist.md`.
- It deletes the Cursor plugin manifests, the `poteto-agent` and `comment-sicko` subagent definitions, the logo and README images, and the Cursor-only `benny` automation pack. Without a registered `poteto-agent`, `poteto-mode` spawns a general subagent and tells it to read `poteto-mode` first. `/no-comments` carries its own copy of the Comment Sicko prompt.

[FORK.md](FORK.md) explains how to pull updates from pstack and the vendored upstreams.

## Credits and license

- [pstack](https://github.com/cursor/plugins/tree/main/pstack) is by Lauren Tan ([@poteto](https://x.com/poteto)), MIT.
- [backnotprop/pstack](https://github.com/backnotprop/pstack) adapts pstack for agents other than Cursor.
- Emil Kowalski's skills come from [emilkowalski/skills](https://github.com/emilkowalski/skills), MIT. See [`vendor/emilkowalski-skills/LICENSE`](vendor/emilkowalski-skills/LICENSE).
- `stageshow` comes from Benji Taylor's [benjitaylor/skills](https://github.com/benjitaylor/skills), MIT. See [`skills/stageshow/LICENSE`](skills/stageshow/LICENSE). Its MIT license doesn't cover the app icons it bundles. [`NOTICE.md`](skills/stageshow/NOTICE.md) has the details.
- `design-checklist.md` adapts rules from Paul Bakaus's [impeccable](https://github.com/pbakaus/impeccable), Apache-2.0. See [`vendor/impeccable/LICENSE`](vendor/impeccable/LICENSE).

Everything else is under the MIT license in [LICENSE](LICENSE).
