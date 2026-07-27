---
paths:
  - "lang/bash/**"
  - "lang/sh/**"
  - "**/*.sh"
  - ".claude/skills/**/*.md"
---

# Bash / POSIX-sh Conventions

## Variable bracing

Use `${VAR}` (braced) only when the variable is immediately adjacent to other
text that would otherwise be parsed as part of the name — path suffixes, string
concatenation, filename suffixes, etc. Use bare `$VAR` when the variable stands
alone in quotes or as an argument.

```sh
# Braces required: adjacent text follows
--source="${HOME}/path"
"${XDG_CACHE_HOME}/koopa/logs/${name}.log"

# No braces needed: variable stands alone
mkdir -p "$dir"
export KOOPA_SHELL="$BASH"
touch "$HISTFILE"
```

This applies to bash/POSIX-sh code, fenced ` ```sh ` blocks in skills and docs,
and Python docstrings that reference shell paths.

**Exception — fish:** fish uses bare `$VAR` and never `${VAR}` (see
`rules/fish.md`). This rule does not apply to ` ```fish ` blocks or `*.fish` files.

**Nested defaults:** `${VAR:-$HOME}` — the inner `$HOME` is standalone inside
the expansion and does not need further bracing.
