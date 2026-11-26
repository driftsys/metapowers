#!/usr/bin/env bash
# Usage: copilot-sol-home.sh <dir>
# Creates a COPILOT_HOME for the copilot-sol cell: an empty Copilot home that holds only
# the login credentials copied from ~/.copilot/config.json. With a fully empty home,
# Copilot CLI reports that the model gpt-6.1-sol is not available. No plugins,
# skills or instructions are copied, so the isolation is the same as for the copilot cell.
# The home holds a copy of the login token: the runners remove it when they exit
# (see the trap that reads COPILOT_SOL_HOMES).
set -eu
[ -n "${COPILOT_SOL_HOMES:-}" ] && echo "$1" >> "$COPILOT_SOL_HOMES"
mkdir -p "$1"
python3 - "$1" <<'PY'
import json, os, sys
text = open(os.path.expanduser("~/.copilot/config.json")).read()
text = "\n".join(l for l in text.splitlines() if not l.strip().startswith("//"))
d = json.loads(text)
keep = {k: d[k] for k in ("lastLoggedInUser", "loggedInUsers", "copilotTokens", "firstLaunchAt") if k in d}
path = os.path.join(sys.argv[1], "config.json")
with open(path, "w") as f:
    json.dump(keep, f)
os.chmod(path, 0o600)
PY
