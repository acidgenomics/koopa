---
name: koopa-completion
description: >-
  koopa shell completion architecture — generator, flag extraction, bash/zsh/PowerShell/elvish
  emitters, lazy-load mechanism, compdump freshness, and known bug patterns. Use when
  debugging missing completions, editing generate_completion.py, or adding flags to a
  CLI handler that need to appear in TAB completion.
---

# koopa Completion Architecture

## Source of truth

All completion files are **auto-generated** — never hand-edit them:

| Generated file | Shell |
|---|---|
| `share/bash-completion/completions/koopa` | bash (and zsh via bashcompinit fallback) |
| `share/zsh/site-functions/_koopa` | zsh native `#compdef` |
| `share/fish/vendor_completions.d/koopa.fish` | fish |
| `share/powershell/completions/koopa.ps1` | PowerShell |
| `share/elvish/completions/koopa.elv` | elvish |
| `share/nushell/completions/koopa.nu` | nushell |

Generator: `lang/python/src/koopa/generate_completion.py`  
Invoke via: `koopa develop generate-completion`  
After a successful run it prints `"Reload your shell to apply changes."`.

The CLI handler (`cli_develop.py:543`) already emits both the success and reload
messages — no need to add them.

## How flags reach completions

`_extract_handler_flags()` (generator ~line 224) AST-walks each `_handle_*`
function and collects literal `"--..."` strings from `parser.add_argument(...)` and
`--flag` comparisons. `_build_flag_map()` then assembles a
`"develop/check-app-versions" → ["--help", "--json", ...]` map.

**Adding a new flag to a command:** add `parser.add_argument("--my-flag", ...)` in
the handler, then run `koopa develop generate-completion`. The flag is picked up
automatically — no manual edits to the completion files.

Flags are only picked up if the literal `"--flag-name"` string appears directly in
the handler function body (not constructed dynamically).

## Bash lazy-load mechanism

Activation sets `BASH_COMPLETION_USER_DIR=${KOOPA_PREFIX}/share/bash-completion`
(in `lang/bash/functions/activate/activate-bash-completion.sh`).

The bash-completion v2 framework (`opt/bash-completion/`) lazy-loads the `koopa`
completion file on first TAB. Until that first TAB:
- `complete -p koopa` returns nothing
- `_koopa_complete` is not defined in memory

This is normal — it is **not** a sign that completion is broken. Running
`complete -p koopa` before ever TABbing on `koopa` will always show "NOT
registered".

The framework requires `PS1` to be set (interactive shell check). It is
version-guarded (`BASH_COMPLETION_VERSINFO`); activation unsets this sentinel so
koopa's versioned framework always wins over any system-installed v2.

## zsh compdump freshness

`_koopa_activate_zsh_compinit` (`lang/zsh/functions/activate/activate-zsh-compinit.sh`):
- Dump path: `${ZDOTDIR:-$HOME}/.zcompdump` → typically `~/.config/zsh/.zcompdump`
- Fast path (`compinit -C`) only fires when dump is < 24 h old AND no file in
  `${KOOPA_PREFIX}/share/zsh/site-functions` is newer than the dump.
- After `koopa develop generate-completion`, the `_koopa` mtime changes, so the
  next new shell forces a full `compinit` rebuild automatically.

A live session never picks up completion file changes — `exec zsh` or open a new
terminal.

## Known bug pattern: flag-gate too strict (fixed 2026-06-19)

**Symptom:** `koopa develop check-app-versions `+TAB (bare or single `-`) showed
nothing; had to type `--` first.

**Root cause:** the bash flag-collection block in the generator was gated on
`[[ "${COMP_WORDS[COMP_CWORD]}" == --* ]]` — only fired when the current word
already started with two dashes.

**Fix applied to `generate_completion.py`:**

```python
# Bash emitter (~line 1649) — was `--*`, now `-*` || empty args
lines.append(f'{_I}if [[ "${{COMP_WORDS[COMP_CWORD]}}" == -* ]] || [[ -z "${{args[*]}}" ]]')
```

The `|| [[ -z "${args[*]}" ]]` clause fires the flag lookup when no subcommand
candidates were found (leaf command), so bare TAB on a fully-resolved command
offers its flags. Non-leaf commands (`develop`, `configure`, etc.) populate `args`
with subcommand names before this block and are unaffected.

Same single-dash relaxation applied to PowerShell (`-like '-*'`) and elvish
(`str:has-prefix $last '-'`) emitters.

## Known bug pattern: completion offering args the parser rejects (fixed 2026-08-11)

**Symptom:** `koopa update system` TAB-completed `homebrew python r
tex-packages`, but running `koopa update system homebrew` was an argparse
error ("unrecognized arguments"). The `update` subparser's `mode` positional
had no `apps` positional to receive them (see the `koopa-update` skill for
the CLI-side fix).

**Root cause, part 1 (bash only):** the bash emitter's depth-3 block for
`update system` (`generate_completion.py`, `_emit_platform_block(
installer_modes["update-system"], ...)`) was already correctly deriving app
names from the registry; it was the parser that lagged behind. No other
shell emitted this depth-3 block at all, so bash alone offered-then-rejected.

**Root cause, part 2 (bash + PowerShell + elvish): a phantom `user` mode.**
Three emitters offered `koopa`, `system`, **and** `user` after `update` even
though `koopa update user` has never existed:

```python
# bash (was):
update_items = ["koopa", "system", "user"]
# PowerShell (was):
f"{_ps_array(['koopa', 'system', 'user'])}"
# elvish (was):
lines.append("            put koopa system user")
```

fish and zsh were already correct (`koopa`, `system` only) and nushell didn't
enumerate modes at all, so the drift was bash/PowerShell/elvish-only. The `user`
token likely leaked in by analogy with `koopa configure system|user`, which
is a real two-mode command; `update` only ever had `koopa`/`system`.

**Fix:** dropped `'user'` from all three emitters; added the equivalent
depth-3 `update system <app>` completion to fish (the one shell that had the
top-level `koopa`/`system` mode completion but no per-app follow-up), keyed
off the same `installer_modes["update-system"]` list already computed by
`_get_installer_mode_apps()`. Threaded that list into
`_generate_fish_completion()` as a new parameter rather than re-deriving it,
since the caller (`generate_completion()`) already has it in scope.

**Trap when generating a fish app-name list from a multi-platform registry
entry:** `PYTHON_INSTALLER_MODES` lists `r` twice (once per `("r", "macos",
"update-system")` and `("r", "debian", "update-system")` platform variant).
A naive `for app, _plat in entries: lines.append(...)` emits a duplicate
`complete` line for `r`. Dedupe by name first: `sorted({name for name, _plat
in entries})`. zsh/PowerShell/elvish's depth-3 blocks don't have this trap
because they route through `_emit_platform_block()`, which already groups
entries by platform tag before emitting.

**Still not covered:** depth-3 `update system <app>` completion for zsh,
PowerShell, elvish, and nushell. Those emitters would need structural changes
(zsh's `_koopa_update` is a flat `_arguments` spec; PowerShell/elvish hardcode
their depth-2/3 blocks to `$tokens[0] -eq 'app'`) to add it without
over-offering app names after `koopa update koopa`. They currently offer
nothing after `system`, which is wrong-but-harmless rather than
offer-then-reject.

## Adding a `koopa run` command

`koopa run` completions are auto-discovered from `cli_bin.py:_HANDLERS` via
`_load_run_commands()` in `generate_completion.py`. No manual completion edits
are needed — just:

1. Add `_handle_my_cmd(args: list[str]) -> None` in `cli_bin.py`.
2. Register `"my-cmd": _handle_my_cmd,` in `_HANDLERS` (keep alphabetical).
3. Run `koopa develop generate-completion`.

`koopa system` subcommands are similarly auto-discovered from the `handle_system`
string-comparison chain, but require explicitly adding a `if subcmd == "my-cmd":` branch.
`koopa admin` subcommands are discovered from `_ADMIN_HANDLERS`.

Top-level commands (`koopa install`, `koopa configure`, …) require manual edits to
`_build_parser` and to `_TOP_CMDS` in 8 places in `generate_completion.py` — avoid
adding top-level commands unless truly necessary.

## Diagnosing "completion not working"

```bash
# In the live interactive shell:
complete -p koopa 2>/dev/null || echo "NOT registered (normal before first TAB)"
declare -F _koopa_complete >/dev/null && echo "DEFINED" || echo "NOT defined (normal before first TAB)"
echo "framework: ${BASH_COMPLETION_VERSINFO[*]:-UNSET — framework not loaded}"
echo "user dir:  ${BASH_COMPLETION_USER_DIR:-UNSET — wrong activation}"
```

If `BASH_COMPLETION_VERSINFO` is unset after opening a new shell, the framework
didn't load — check that activation ran (`echo $KOOPA_PREFIX`) and that the shell
is interactive (`PS1` set).

## Dead symlink cleanup (done 2026-06-19)

`~/.local/share/bash-completion/completions/koopa` was a dangling symlink to
the deleted file `etc/completion/koopa.sh`. It was harmless (bash-completion's
`_comp_load` uses `[[ -e ]]` which is false for dangling links, so it silently
skips it), but it was removed as cruft. If it reappears, just `rm` it — it is
not managed by chezmoi or koopa.
