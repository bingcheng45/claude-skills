#!/usr/bin/env bash
# Turn the multi-feature-change-workflow guard on for the current Claude session.
#   pcw-on.sh <session-id | scratchpad-dir>
# Pass the session id, or the scratchpad directory from the system prompt (its parent folder is the
# session id). While active, the guard hook blocks Agent spawns that are not pstack:poteto-agent and
# adds the poteto-mode requirement to every subagent this session starts. Expires after 12 hours.
set -euo pipefail
arg="${1:-}"
[ -n "$arg" ] || { echo "usage: pcw-on.sh <session-id | scratchpad-dir>" >&2; exit 1; }
python3 - "$arg" <<'PY'
import json, os, re, sys, time
arg = sys.argv[1].rstrip("/")
if os.sep in arg:
    parts = arg.split(os.sep)
    session = parts[-2] if parts[-1] == "scratchpad" else parts[-1]
else:
    session = arg
if not re.fullmatch(r"[0-9a-fA-F-]{16,}", session):
    sys.exit(f"pcw-on: '{session}' does not look like a session id")
path = os.path.expanduser("~/.claude/state/pcw-active")
os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w", encoding="utf-8") as fh:
    json.dump({"sessions": [session], "started": time.time()}, fh)
print(f"multi-feature-change-workflow guard ON for session {session} (12 hour expiry)")
PY
