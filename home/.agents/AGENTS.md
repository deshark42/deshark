# AGENTS.md

## Conventions

- Before your first tool call, say in one sentence what you're about to do; afterwards, narrate briefly only on important findings or changes of direction.
- Do not comment on facts obvious from code.
- Tests describe behavior, not correctness. Change obsolete behavior with its tests; explain why in the PR.
- Use `~/tmp/<workspace>/<topic>/` for temporary/scratch work instead of `/tmp/`.

## GitHub

- `gh` is installed and authenticated; use it instead of unauthenticated `api.github.com` calls.

## Memory

Your memory is OptMem:
- The tool is `memo`
- Your memories are in `~/.optmem/memory`
- Scopes: `user` for the user's preferences and background, `global` for reusable knowledge, `workspace` for the current directory.

### At startup: activating OptMem (mandatory)

Run `memo wake` before any other tool call, in every session, to read the memory.

### While working: register memories (mandatory)

Call `memo note --scope SCOPE "<1 line, max 280 bytes>"` whenever you learn something new, or something worth keeping happens. That covers a task worth real effort, a fact or insight the user teaches you, anything you learn about the user's life (even indirectly), any event of lasting effect.

Start each note with one short topic in square brackets, e.g. `[Git] ...`. Reuse existing topics when possible.

Ask the user with `ask_user_question` before every `memo note`, and record only what the user approves.

Do not register redundant memories.

If `memo note` asks a compression: do it before your next action.

Never edit or delete anything under `~/.optmem/memory`: the tool manages it.

### When you need an old memory: search, or navigate

`memo recall <regex>` searches every memory, word for word.

Your memories also form a binary tree: #0-1, #2-3 ... exist as one-line summaries, pairs of those as #0-3, and so on -- every `#a-b` line wake prints is one node of it. `memo zoom --scope SCOPE <a-b>` opens a node into its two halves, down to the raw memories.

### If you're a subagent: skip everything above

Parallel sessions on this machine are all you, and may all write memories. A subagent is not: it must never run `memo`, because it cannot judge what is already known, and its notes would arrive duplicated and incorrectly. When you spawn one, write: `You are a subagent. Don't run memo.`
