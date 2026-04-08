<!-- OMC:START -->
# oh-my-claudecode (OMC) v4.11.2 Summary

**oh-my-claudecode** is a multi-agent orchestration layer for Claude Code that coordinates specialized agents and tools to complete work efficiently.

## Key Operating Principles
- Delegate specialized tasks to appropriate agents
- Verify outcomes before making final claims
- Choose lightweight solutions that maintain quality
- Consult official documentation before using SDKs/frameworks

## Delegation Framework
**Delegate for:** multi-file changes, refactoring, debugging, reviews, planning, research, and verification

**Work directly for:** simple operations, clarifications, single commands

Route complex code to `executor` (using Opus model) and documentation questions to `document-specialist`

## Model Routing
- **Haiku:** quick lookups
- **Sonnet:** standard work
- **Opus:** architecture, deep analysis

## Core Skills (Tier-0 Workflows)
Invoked via `/oh-my-claudecode:<name>`:
- `autopilot`, `ultrawork`, `ralph`, `team`, `ralplan`
- `deep-interview`, `ai-slop-cleaner`, `analysis`, `tdd`, `deepsearch`

## Execution Protocols
- Start broad requests with exploration, then planning
- Run 2+ independent tasks in parallel
- Keep authoring and review as separate passes
- Never self-approve; use `code-reviewer` or `verifier`
- Complete all tasks and collect verification before concluding

## Cancellation
Use `/oh-my-claudecode:cancel` when work is complete+verified or blocked—never cancel incomplete work.
<!-- OMC:END -->
