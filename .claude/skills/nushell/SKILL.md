---
name: nushell
description: >-
  Nushell (nu) pitfalls, parse-time constraints, and koopa activation architecture.
  Use when writing or debugging .nu files, editing lang/nushell/include/header.nu or
  any activate-*.nu, sourcing prompt tools (starship, zoxide), or porting shell logic
  from bash/zsh/fish to nushell.
---

# Nushell in koopa

## `use` and `source` Require Parse-Time-Constant Paths

nushell resolves `use` and `source` at **parse time**, not runtime. Passing a runtime
expression — including `$env.X` — throws `nu::shell::not_a_constant` even if the value
is set:

```nu
use ($env.KOOPA_PREFIX + "/lang/nushell/include/header.nu") *  # ❌ parse error
```

**The koopa fix:** render the literal path via a chezmoi template so the deployed file
contains a hardcoded string:

```
# In config.nu.tmpl:
{{- $dataHome := env "XDG_DATA_HOME" | default (joinPath .chezmoi.homeDir ".local/share") }}
use {{ joinPath $dataHome "koopa" }}/lang/nushell/include/header.nu *
```

A `const` cannot read `$env` either — `const p = $env.KOOPA_PREFIX` throws the same
error. The only options are a literal string or a chezmoi-rendered literal.

**For `source`** (prompt-tool caches), the same constraint applies — see the
"Starship + Zoxide" section below.

## `nu -c` Does Not Load User Config

`nu -c '…'` and `nu script.nu` **do not load `env.nu` or `config.nu`**. Any env values
visible in those modes are built-in defaults or inherited from the parent shell — NOT
our config. This causes false negatives when probing activation (e.g. `STARSHIP_SHELL`
appears as `zsh`, `which z` returns empty, `_koopa_activate_koopa` is absent).

**To verify config-dependent behaviour non-interactively:**
```sh
nu --env-config ~/.config/nushell/env.nu \
   --config ~/.config/nushell/config.nu \
   -c '…'
```
This faithfully mirrors the interactive REPL. `$nu.env-path` and `$nu.config-path`
confirm the deployed files are loaded by the REPL.

## Load Order: env.nu → config.nu → autoload dirs

nushell evaluates **env.nu fully before parsing config.nu**. This is the key to safely
sourcing parse-time caches:

1. **env.nu** — runs at *evaluation* time; may use `$env`, `if`, loops, external commands.
   Correct place to *generate* caches.
2. **config.nu** — *parsed* after env.nu completes; `source` paths must already exist on
   disk. Correct place to *source* caches.
3. **autoload dirs** (`$nu.user-autoload-dirs`, `$nu.vendor-autoload-dirs`) — sourced
   after config.nu.

## Starship + Zoxide: Generate in env.nu, Source in config.nu

Because `source` is parse-time and hard-errors on a missing file
(`nu::parser::sourced_file_not_found`), the cache must exist *before* config.nu parses.

**env.nu bootstrap block** (plain file — uses runtime `$env.HOME`):
```nu
# Ensure cached prompt-tool init exists for parse-time `source` in config.nu.
let _koopa_cache = $"($env.HOME)/.cache/koopa"
for _t in [
    { bin: "starship", args: ["init", "nu"] }
    { bin: "zoxide",   args: ["init", "nushell"] }
] {
    let _out = $"($_koopa_cache)/($_t.bin).nu"
    if not ($_out | path exists) {
        mkdir $_koopa_cache
        let _bin = $"($env.KOOPA_PREFIX)/bin/($_t.bin)"
        if ($_bin | path exists) { ^$_bin ...$_t.args | save -f $_out } else { "" | save -f $_out }
    }
}
```
When a binary is absent, an **empty stub** is written — sourcing an empty file is a
clean no-op, avoiding a missing-file parse error.

**config.nu.tmpl source lines** (chezmoi template — renders literal `homeDir`):
```
source {{ .chezmoi.homeDir }}/.cache/koopa/starship.nu
source {{ .chezmoi.homeDir }}/.cache/koopa/zoxide.nu
```

The mtime-guarded `_koopa_activate_starship` / `_koopa_activate_zoxide` functions in
`lang/nushell/include/header.nu` keep the caches *fresh* on binary upgrade; env.nu only
guarantees they *exist* on first launch.

**Verification gotcha:** calling `do $env.PROMPT_COMMAND` by hand throws
`column_not_found: CMD_DURATION_MS` — that variable is auto-populated by nushell per
prompt render; the error is a manual-invocation artifact, not a config bug.

## Activation Architecture

```
env.nu
  ├── sets $env.KOOPA_PREFIX (literal or XDG_DATA_HOME-derived)
  └── generates ~/.cache/koopa/starship.nu + zoxide.nu if absent

config.nu  (rendered from config.nu.tmpl by chezmoi)
  ├── use <literal-path>/lang/nushell/include/header.nu *   ← chezmoi renders literal
  ├── _koopa_activate_koopa                                  ← full activation
  ├── source ~/.cache/koopa/starship.nu                     ← sets PROMPT_COMMAND
  └── source ~/.cache/koopa/zoxide.nu                       ← defines z, __zoxide_*
```

`_koopa_activate_koopa` (`lang/nushell/include/header.nu:49`) handles `KOOPA_MINIMAL`,
PATH additions, conda, direnv, fzf, color-mode sync, and aliases. It calls
`_koopa_activate_starship` + `_koopa_activate_zoxide` to *regenerate* stale caches —
the env.nu bootstrap and the runtime regeneration work together.

## Inclusive vs Exclusive Ranges (`str substring`)

nushell ranges are **inclusive** by default. `0..N` includes index N; `0..<N` excludes
it. The stock `create_left_prompt` in env.nu had this bug:

```nu
# ❌ double-counts the '/' at index len($home) → ~//.local/share/…
$env.PWD | str substring 0..($home | str length) | str replace $home "~"

# ✓ exclusive end — correct
$env.PWD | str substring 0..<($home | str length) | str replace $home "~"
```

## Deprecated / Removed Syntax (0.78 → 0.113)

| Old (≤0.78) | New (0.113+) |
|---|---|
| `let-env X = …` | `$env.X = …` |
| `$env \| get -i KEY` | `$env.KEY? \| default ""` |
| `str replace -s PAT REP` | `str replace PAT REP` (literal is now the default) |
| `date format '…'` | `format date '…'` |
| `$nu.scope.commands` | `scope commands` |
| `$nu.scope.vars` | `scope variables` |

## Shell Prompt Indicator (Starship)

The nushell indicator in `starship.toml` uses **ν** (U+03BD, Greek small letter nu):

```toml
[shell]
nu_indicator = 'ν'
```

Rationale: the shell is named after the Greek letter; ν renders in JetBrains Mono and
every standard Unicode font without requiring a nerd font variant.

Source file: `opt/dotfiles/chezmoi/dot_config/starship.toml.tmpl`, `[shell]` section.
