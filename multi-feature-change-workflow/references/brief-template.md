# Brief template

One brief per unit, written as a file the agent reads. Point to the file in the spawn prompt, and
paste the standing orders next to it. The brief is the product: an agent cannot ask you questions.

## First line of every brief (do not remove)

> Run the poteto-mode playbook that matches this unit. Copy its steps into your todolist first,
> follow them end to end, and name the principles that changed a decision in your report.

## Spawn call

- `subagent_type: "pstack:poteto-agent"` for every agent, including read-only ones.
- `model`: the user's choice (this workflow used Opus for implementation).
- `run_in_background: true`.
- The prompt names the two files to read in full (standing orders and the brief), the worktree,
  and any base-branch difference. Keep it short and use file pointers.

## Header

```
# Unit: <slug> (review item <n>)
Worktree: <absolute path>   Branch: <branch>   PR base: <base>   Device: <device name>
Depends on: <other unit or none>
```

## Why

What happens today and why it is wrong, in the user's words where possible.

## Exact spec

Timings, curves, sizes, copy and behaviour. State what must stay synchronous, what must not be
held across an animation or async step, which existing infrastructure to reuse, and what must
not change. Name the files and functions where the code lives when you know them.

## Tests

Which logic gets unit tests, which existing suites must still pass, and any mutation check you
want (break the logic on purpose and confirm tests fail).

## Recording plan

The exact trigger to film, a second clip if the effect is subtle, and what the clip must show.
Note anything that blocks the obvious route, for example a deep link that does not work on a
simulator.

## Notes from earlier units

For wave 2, paste what the first unit learned: required host or wrapper, timing quirks, tools
that do not work, load warnings. Add it before spawning.

## Risk call

Say which part is riskiest and what to do if the lowest-risk option still fails.
