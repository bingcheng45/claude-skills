#!/usr/bin/env python3
"""Check that a subagent report shows the unit went through poteto-mode.

  check-report.py report.txt     (or pipe the report on stdin)

Exit 0 when the report names a poteto-mode playbook, shows its todolist and cites principles.
Exit 1 and list what is missing otherwise, so the coordinator can respawn with the gap named.
"""
import re
import sys

PLAYBOOKS = [
    "feature", "bug fix", "refactoring", "prototype", "investigation", "perf issue", "hillclimb",
    "runtime forensics", "trace forensics", "visual parity", "eval", "babysit", "shipping",
    "autonomous run", "orchestrate", "autopilot", "session pickup", "pause safely",
    "multi-phase", "authoring a skill", "worktree and simulator cleanup", "opening a pr",
]


def main():
    text = open(sys.argv[1], encoding="utf-8").read() if len(sys.argv) > 1 else sys.stdin.read()
    low = text.lower()
    missing = []
    if "poteto" not in low and not any(re.search(r"\b" + re.escape(p) + r"\b", low) for p in PLAYBOOKS):
        missing.append("which poteto-mode playbook was run")
    if not re.search(r"todo(list)?|checklist|steps? (completed|done)", low):
        missing.append("the todolist or step summary from that playbook")
    if not (re.search(r"principle[- ]", low) or "principles" in low):
        missing.append("the principles that changed a decision")
    for field, pattern in (("branch", r"branch"), ("PR URL", r"github\.com/.+/pull/\d+|pull request"),
                           ("head SHA", r"\b[0-9a-f]{7,40}\b"), ("test counts", r"\d+\s*(of|/)\s*\d+|passed|tests?")):
        if not re.search(pattern, low):
            missing.append(field)
    if missing:
        print("Report is missing: " + "; ".join(missing))
        return 1
    print("Report shows the poteto-mode playbook, todolist and principles.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
