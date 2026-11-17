# UI craft

Read this reference when a playbook builds, prototypes, verifies, debugs, or audits a user interface. Emil Kowalski's skills sit beside pstack's in `skills/`. The playbook owns the process. At each point in the table, read the named skill by path and hold the work to its bar.

| Point in the playbook | Read | Apply |
|---|---|---|
| Prototype, a visual decision inside an existing app | [`prototype`](../../prototype/SKILL.md) | Build the variants on an isolated route in the app, on the app's tokens, behind its picker. This replaces the standalone scratch build in steps 3 and 4. |
| Feature step 4, before the brief | [`pick-ui-library`](../../pick-ui-library/SKILL.md) | Name the library in the brief before a delegate hand-rolls a dialog, toast, drawer, command menu, or drag and drop. |
| Feature step 4, the brief | [`animate`](../../animate/SKILL.md) for one animation, [`choreograph`](../../choreograph/SKILL.md) for several elements that move together, [`gestures`](../../gestures/SKILL.md) for drag, swipe, and sheets, [`mobile-native`](../../mobile-native/SKILL.md) for a web app on a phone, [`animate-expo`](../../animate-expo/SKILL.md) for React Native, and [`emil-design-eng`](../../emil-design-eng/SKILL.md) for polish with no motion or when none of the others fits, plus [`design-checklist`](design-checklist.md) in every UI brief | List the paths in the brief. The delegate reads them before it writes UI code. |
| Verify a change to UI | [`design-checklist`](design-checklist.md) on every change, [`review-animations`](../../review-animations/SKILL.md) when the diff adds or changes motion, and [`break-ui`](../../break-ui/SKILL.md) in its `+ fix` mode on every changed component that renders data | Run them before you call the work done. Breaks that predate your change count, because you ship the whole component. Fix what they flag. When the execution playbook's swarm has audit lanes, make each one the focus of its own lane, and that playbook's blocking rule decides what blocks. |
| Bug fix or Perf issue about dropped frames | [`animation-performance`](../../animation-performance/SKILL.md) | Find the cause with it. `benchmark-checklist` still governs the number. |
| Motion audit of an existing app | [`improve-animations`](../../improve-animations/SKILL.md) for bad motion, [`find-animation-opportunities`](../../find-animation-opportunities/SKILL.md) for missing motion, or [`remove-animations`](../../remove-animations/SKILL.md) for too much motion | Pick one by the complaint. |
| End of a session in which the user corrected a design choice | [`learn-taste`](../../learn-taste/SKILL.md) | Run it beside `reflect`. `reflect` edits skills. `learn-taste` writes the project's design rules and lint checks. |

When the knowledge or the word is what's missing, read [`apple-design`](../../apple-design/SKILL.md) or [`animation-vocabulary`](../../animation-vocabulary/SKILL.md).

## Where pstack overrides Emil's skills

- Skip a skill's Initial Response section when it has one. You invoke the skill with a task.
- `prototype` Phase 5 presents the variants with no favorite. Keep its table neutral, then give pstack's recommendation under the table.
- `prototype` Phase 6 promotes the winner into production code. Hand the winner to Feature for the real build instead, then delete the prototype route.
- `break-ui` stops after its report unless you invoke it with `+ fix`. Always use `+ fix`, and list its Decisions for you as open decisions in the reply.
- `improve-animations` stays read-only. Execute its plans through the Multi-phase plan playbook, never through its `execute` mode.
