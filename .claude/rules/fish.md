---
paths:
  - "**/*.fish"
---

# Fish Shell Conventions

## Variable style

Fish uses `$VAR` — never `${VAR}` (bash-ism). Fish's parser already unambiguously
delimits variable names without braces; curly braces add noise with no benefit.

Applies to all environment variables referenced in fish scripts: `$KOOPA_PREFIX`,
`$XDG_CACHE_HOME`, `$XDG_CONFIG_HOME`, `$XDG_DATA_HOME`, `$HOME`, etc.

## `set` scope: `-g` vs `-gx` vs `-U`

| Flag | Use for |
|------|---------|
| `set -g VAR` | fish-internal vars (`fish_color_*`, `fish_pager_color_*`). Global scope, **not** exported to child processes. |
| `set -gx VAR` | Env vars consumed by child processes (`FZF_DEFAULT_OPTS`, `KOOPA_COLOR_MODE`, etc.). Global + exported. |
| `set -U VAR` | Universal vars — persist across sessions. Fish 4.3+ migrated theme vars *away* from `-U`; don't use for colors. |

`fish_color_*` and `fish_pager_color_*` are fish line-editor vars — always `set -g`, never `-gx`.

## `fish_variables` is fish-owned — don't manage theme vars there

`~/.config/fish/fish_variables` stores universal variables. Fish itself rewrites this
file freely (on upgrade, `fish_config` use, etc.). A chezmoi-managed `fish_variables.tmpl`
that sets `SETUVAR fish_color_*` will be clobbered — fish will strip the color block the
next time it rewrites the file, silently reverting the colors.

**Rule:** set theme/color vars via `set -g` in a conf.d file, not via `fish_variables`.

## `fish_frozen_theme.fish` — fish 4.3 migration artifact

Fish 4.3 migrated theme vars from universal to global scope by auto-generating
`~/.config/fish/conf.d/fish_frozen_theme.fish`. This file:
- Is **fish-owned and untracked** — `fish_config` web tool may overwrite it.
- Sets the full theme palette as `set --global fish_color_*` globals on every startup.
- Should **never be edited directly** (the header says so, and it would be clobbered).

To override it: place a `set -g fish_color_*` in any conf.d file that loads **after** it
alphabetically. `koopa.fish` (k > f) loads after `fish_frozen_theme.fish`.

## conf.d load order is alphabetical

Files under `~/.config/fish/conf.d/` load in alphabetical filename order. Globals set by
a later file win over globals set by an earlier file with the same name. Current order:

```
fish_frozen_key_bindings.fish   ← fish-owned
fish_frozen_theme.fish          ← fish-owned (One Light / whatever theme was active at 4.3)
koopa.fish                      ← koopa's entrypoint; sources the Dracula Pro palette file
```

When adding a new conf.d file, its position in the alphabet determines load order.

## `fish_color_*` value format

Fish color vars accept:
- Bare hex: `set -g fish_color_normal f8f8f2`
- Hash-prefixed hex: `set -g fish_color_normal '#f8f8f2'` or `#f8f8f2`
- Modifiers (space-separated): `set -g fish_color_selection --background=44475a`
- Multiple tokens: `set -g fish_color_redirection ff79c6 --bold`
- Modifier-only (no color): `set -g fish_color_valid_path --underline`

The `fish_frozen_theme.fish` convention is bare hex (no `#`); the generated Dracula Pro
palette files emit `#`-prefixed hex (from `_parse_ghostty_palette` output). Both work.

## Diagnosing which scope is winning

```fish
set -S fish_color_autosuggestion
```

`set -S` prints the variable's value **and** its scope (global, universal, local). Use
this to confirm a generated palette's `set -g` is actually overriding the frozen theme's
`set --global`. Also useful from a one-shot check:

```sh
fish -c 'set -S fish_color_autosuggestion'
```
