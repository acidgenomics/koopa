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

## `def --env` Required for Any `$env` Mutation to Escape the Caller

`$env.X = ...`, `hide-env`, and `load-env` only affect the calling function's *own*
scope unless that function is declared `def --env`. This is not limited to the one
function doing the mutation — **every function in the call chain**, from the
top-level call site down to the mutation, must be `def --env`, or the change is
silently discarded the moment the innermost function returns:

```nu
def inner [] { $env.FOO = "bar" }
def outer [] { inner }
outer
$env.FOO?                              # null -- inner's own scope only

def --env inner [] { $env.FOO = "bar" }
def --env outer [] { inner }           # outer must ALSO be --env
outer
$env.FOO?                              # "bar"
```

**Regression found in koopa** (2026-08): none of `_koopa_export_env`, any
`_koopa_activate_*`, `_koopa_add_to_path_start`/`_end`, `_koopa_activate_koopa`, or
`_koopa_run_activation` were `def --env`. Every variable koopa's nushell activation
was supposed to set (`KOOPA_SHELL`, `KOOPA_CPU_COUNT`, `XDG_*`, `EDITOR`,
`KOOPA_COLOR_MODE`, ...) was silently discarded on return — the activation ran,
looked correct top to bottom, and did nothing. Fixed by adding `--env` to every
function in the chain.

**Which functions need it?** Only ones that mutate `$env` themselves, or call
another `--env` function and need that mutation to reach *their own* caller. Pure
readers (`_koopa_is_macos`, `_koopa_bin_prefix`, `_koopa_xdg_config_home`, etc.)
never need it.

**Verification.** This class of bug is invisible from reading any single function in
isolation — each one looks correct. The only reliable check is running the real
top-level entry point, not an isolated snippet:
```sh
KOOPA_ACTIVATE=1 KOOPA_PREFIX=<repo> nu -c '
    use <repo>/lang/nushell/include/header.nu *
    _koopa_run_activation
    print $env.KOOPA_CPU_COUNT   # must NOT be null
'
```

## `header.nu` Must `export use` Every File Whose Functions Are Called Elsewhere

`export use ../functions/X/Y.nu *` makes `Y.nu`'s functions visible across the whole
flattened `header.nu` namespace — but only for files actually listed. A file that is
never `export use`'d is invisible even to code that calls it, and the failure is a
hard runtime error (`Command 'foo' not found`), not a silent no-op.

**Regression found in koopa** (2026-08): `functions/core/is-light-mode.nu` and
`functions/core/terminal-is-light-background.nu` existed and were called from
`_koopa_export_env`, but neither had an `export use` line in `header.nu` — so
`_koopa_export_env` (and therefore all of `_koopa_activate_koopa`) crashed outright
the moment it reached the color-mode block. Adding a new `core/`-style helper file
requires adding its own `export use` line in `header.nu` — nothing does this
automatically, and there's no test that catches an omission.

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
