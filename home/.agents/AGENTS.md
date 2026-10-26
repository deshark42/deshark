# AGENTS.md

## Conventions

- Before the first tool call, briefly state what you're about to do.
- Keep the user informed throughout the task. Provide concise progress updates at meaningful milestones and during extended investigations, even when there are no significant findings. Explain the current direction and next steps without narrating every tool call or going silent for long periods.
- Do not comment on facts obvious from code.
- Tests describe behavior, not correctness. When behavior is obsolete, update the code and tests together; explain the rationale in the change summary or PR.
- Use `~/tmp/<workspace>/<topic>/` for temporary/scratch work instead of `/tmp/`.

## GitHub

- `gh` is installed and authenticated; use it instead of unauthenticated `api.github.com` calls.

## Memory

Your memory is OptMem:
- The tool is `memo`
- Your memories are in `~/.optmem/memory`
- Scopes: `user` for the user's preferences and background, `global` for reusable knowledge, `workspace` for the current directory.

### Subagents

Subagents must not use `memo`. All other instructions in this section apply only to the main agent.

When spawning a subagent, write: `You are a subagent. Don't run memo.`

### At startup: activating OptMem (mandatory)

Run `memo wake` before any other tool call, in every session, to read the memory.

### While working: register memories

Propose a memory when you learn something likely to be useful in future tasks, such as a lasting user preference, a reusable insight, or an important project decision. Do not record transient findings, incidental personal information, or redundant memories.

Before every `memo note`, use `ask_user_question` to request explicit approval for the proposed memory. Only record the approved content.

Call `memo note --scope SCOPE "<1 line, max 280 bytes>"` to save an approved memory.

Start each note with one short topic in square brackets, e.g. `[Git] ...`. Reuse existing topics when possible.

If `memo note` asks for compression, complete it before your next action.

Never edit or delete anything under `~/.optmem/memory`: the tool manages it.

### When you need an old memory: search, or navigate

`memo recall <regex>` searches every memory, word for word.

Your memories also form a binary tree: #0-1, #2-3 ... exist as one-line summaries, pairs of those as #0-3, and so on -- every `#a-b` line wake prints is one node of it. `memo zoom --scope SCOPE <a-b>` opens a node into its two halves, down to the raw memories.
