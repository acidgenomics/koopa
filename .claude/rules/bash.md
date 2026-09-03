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

**Scratch directories:** the same rule applies to a `mktemp` variable. Brace it
when a path suffix follows; leave it bare on its own:

```sh
tmp="$(mktemp -d)"          # standalone: bare
uv venv --quiet "${tmp}/venv"
"${tmp}/venv/bin/python" -c 'import sys'
rm -rf "$tmp"               # standalone: bare
```

**Exception — fish:** fish uses bare `$VAR` and never `${VAR}` (see
`rules/fish.md`). This rule does not apply to ` ```fish ` blocks or `*.fish` files.

**Nested defaults:** the adjacency rule also applies inside a `${VAR:-...}`
expansion, judged on the inner variable alone:

```sh
"${KOOPA_PREFIX:-$HOME}"                      # inner var standalone: bare
"${KOOPA_PREFIX:-${HOME}/.local/share/koopa}" # text follows inner var: braced
```

**Scan for misses:** the `paths:` glob above covers `.claude/skills/**/*.md`,
but nothing runs it automatically. A written check catches what a re-read
misses:

```sh
grep -rn '\$[A-Za-z_][A-Za-z0-9_]*[/.]' .claude/skills/ --include='*.md' \
    | grep -v '\${'
```

This also reports fish, nushell, PowerShell, and elvish code blocks. Those are
false positives: `$env.X` and `$env:X` are that language's own syntax, not
POSIX-sh parameter expansion, and fish never uses braces.
