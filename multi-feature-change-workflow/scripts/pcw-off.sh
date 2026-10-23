#!/usr/bin/env bash
# Turn the multi-feature-change-workflow guard off. Safe to run when it is already off.
rm -f "$HOME/.claude/state/pcw-active" && echo "multi-feature-change-workflow guard OFF"
