---
name: project-handover
description: Preserve project history, verified current state, and deferred work when handing a project between agent sessions.
---

Prepare a concise, evidence-based handover when project continuity is requested or a meaningful session transition needs recording. Follow the user's authorized scope, active project instructions, level, priorities, and documentation conventions. Prefer existing records; do not create a new record structure without a need.

The Core Policy's project-memory lifecycle applies during normal development,
whether or not a handover is requested. This workflow supplements those
obligations; it does not defer or replace required memory updates.

Keep three information responsibilities distinct, whether the project uses one document or several:

- **Development history** records the meaningful sequence of stages: decisions, changes, verification outcomes, failures, and unresolved issues. Add concise entries to the established history. Do not duplicate ordinary Git history or write activity transcripts.
- **Current state** is a short fresh-session summary of confirmed goals, architecture, implemented behavior, limitations or blockers, and immediate next actions. Verify it against the repository and authoritative documents; link to those sources instead of copying them.
- **Backlog** contains deferred improvements, unanswered questions, wishes, and postponed decisions. Keep these separate from completed work and immediate tasks. Recording an item does not approve or authorize it.

For the handover:

1. Inspect the relevant project instructions, roadmap or task, authoritative design, existing continuity records, repository status, and changed implementation. Focus on sources that matter to the current work.
2. Establish what changed and the actual sequence of meaningful work. Check commits, diffs, artifacts, and verification output as relevant; do not infer completion from plans or claims alone.
3. Update only the records needed to preserve that history, current state, and deferred work. Keep existing conventions and useful content; do not reorganize or overwrite documentation unnecessarily. Create a missing record only when needed and within scope.
4. State the next authorized action from the user's instructions or approved project plan. Do not turn a suggestion or backlog item into approval, a new task, or permission to proceed. If no next action is authorized, say so.
5. Give a concise handover with pointers to durable records. Distinguish verified facts from assumptions, and name relevant failed or unrun checks and unresolved questions. Never invent work, commits, approvals, or results.

Scale the record and report to the work. Trivial changes may need no separate history or backlog entry; preserve enough context for another session to resume meaningful work without reproducing the full conversation.
