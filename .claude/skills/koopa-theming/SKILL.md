---
name: koopa-theming
description: >
  Reference for koopa theme synthesis across editors and terminals — Dracula Pro
  runtime pipeline, fish color architecture (fish_frozen_theme.fish override, _FISH_COLOR_ROLES
  generator, live sync hook), JetBrains/IntelliJ scheme delivery, atuin and mcfly color
  config, and macOS sandboxed-app theme installation. Use when generating or fixing
  editor/terminal color schemes, debugging a theme that renders incorrectly, or
  writing theme-install code. For the "never hardcode Pro hex" guardrail see the
  path-scoped theme-colors rule.
---

# koopa Theming Reference

## Dracula Pro: Runtime Derivation Architecture

Proprietary paid-theme hex values (Dracula Pro, Dracula Pro Alucard) must **never**
appear as literals in any tracked file — derive them at runtime only.

**Allowed as literals:**
- Free Dracula OSS colors: `#282a36`, `#6272a4`, `#50fa7b`, `#f1fa8c`, `#ff79c6`,
  `#bd93f9`, `#8be9fd`, `#ffb86c`, `#ff5555`
- Generic neutrals: `#ffffff`, `#000000`, `#fafafa`, plain greys

**Correct architecture:**
1. Install script reads colors via `_parse_ghostty_palette(dp_dir, variant)` from
   `~/.local/share/dracula-pro/themes/ghostty/<variant>`.
2. Generates palette files outside the chezmoi tree (e.g.
   `~/.config/zsh/dracula-pro-colors.zsh`, `~/.config/fish/dracula-pro-colors.fish`).
3. Chezmoi templates source/include those generated files at runtime with a fallback
   to free Dracula OSS colors when the generated file does not exist:

```toml
{{- if stat (joinPath .chezmoi.homeDir ".config/starship/dracula-pro.toml") }}
{{- include (joinPath .chezmoi.homeDir ".config/starship/dracula-pro.toml") }}
{{- else }}
purple = "#bd93f9"
{{- end }}
```

**Before writing any hex into a tracked file:**
```sh
grep -iE '<THE_HEX>' ~/.local/share/dracula-pro/themes/ghostty/pro
```
If it matches, the code must read it at runtime.

## Fish Color Pipeline

### Architecture

Fish colors are set via the **generated palette file**, sourced by `conf.d/koopa.fish`
at startup and on live dark↔light flips:

```
_generate_fish_dracula_pro_palette()   ←  dotfiles install script
        │
        ▼
~/.config/fish/dracula-pro-colors.fish         (dark)
~/.config/fish/dracula-pro-alucard-colors.fish (light)
        │
        ▼  sourced by conf.d/koopa.fish (k > f, loads after fish_frozen_theme.fish)
fish_color_* globals override the frozen One Light theme
```

The generator (`_generate_fish_dracula_pro_palette` in `app/dotfiles/2937f77/install`)
uses `_FISH_COLOR_ROLES` (a module-level table adjacent to `_ZSH_HIGHLIGHT_ROLES`) to
loop over role→variable pairs and emit `set -g fish_color_*` lines, followed by
`set -gx FZF_DEFAULT_OPTS`. Colors are runtime-derived from `_parse_ghostty_palette` —
no Pro hex literals in tracked files.

### fish_frozen_theme.fish — the One Light override problem

Fish 4.3 auto-generates `~/.config/fish/conf.d/fish_frozen_theme.fish` when upgrading,
migrating theme vars from universal to global scope. This file:
- Is fish-owned; header says "Don't edit this file."
- Sets the full One Light palette (`A0A1A7` autosuggestion, `383A42` normal, etc.) as
  `set --global` on every startup.
- Loads *before* `koopa.fish` alphabetically — so `koopa.fish`'s globals win.

Never edit or delete `fish_frozen_theme.fish` — the fix is always to override via a
conf.d file that loads later (alphabetically after `f`).

### Alucard quirk: ANSI 8 = white

In the Dracula Pro Alucard palette, ANSI 8 (the `comment` role from
`_parse_ghostty_palette`) is white — invisible on the light background. The fish
generator handles this:

```python
dim = p["cursor"] if variant == "alucard" else p["comment"]
```

This substitutes the cursor color (a legible mid-purple, runtime-derived) as the
dim/comment tone for alucard, mirroring the existing alucard bg override in
`_fzf_color_opts`. The `#8787af` autosuggestion color is a fixed xterm-256 index-103
value (allowlist-safe generic, absent from both Pro/Alucard ghostty palettes) that reads
well on both backgrounds, so it bypasses both `comment` and `cursor`.

### Live color-mode sync

`lang/fish/functions/activate/activate-color-mode-sync.fish` fires on `fish_postexec`.
After re-running fzf/difftastic/dircolors, it re-sources the appropriate palette file:

```fish
set -l _palette
if test "$new_mode" = light
    set _palette (test -n "$XDG_CONFIG_HOME" && echo "$XDG_CONFIG_HOME" || echo "$HOME/.config")/fish/dracula-pro-alucard-colors.fish
else
    set _palette (test -n "$XDG_CONFIG_HOME" && echo "$XDG_CONFIG_HOME" || echo "$HOME/.config")/fish/dracula-pro-colors.fish
end
test -f "$_palette"; and source "$_palette"
```

This refreshes `fish_color_*` and `FZF_DEFAULT_OPTS` live without a shell restart,
mirroring zsh's hook in `lang/zsh/include/functions.sh`.

### Fallback (no Dracula Pro installed)

`conf.d/koopa.fish.tmpl` has an `else` branch (when the generated palette file is absent)
that sets a compact free-Dracula OSS `fish_color_*` set using only allowlisted literals.
The dark arm covers the high-visibility roles (normal/command/autosuggestion/comment/
error/quote/selection etc.).

### Proprietary hex audit command

Run after any change to the fish pipeline. **Comments count** — do not name proprietary
hex values in comments even when the code itself is runtime-derived. The audit pattern
is derived at runtime from the installed palette — never hardcode the hex here.

```sh
cd ~/.local/share/koopa
dp="${XDG_DATA_HOME:-$HOME/.local/share}/dracula-pro/themes/ghostty"
# Free Dracula OSS + generic neutrals that legitimately appear as literals.
allow='F8F8F2|F5F5F5|FFFFFF|1F1F1F|000000|FAFAFA'
PAT=$(find "$dp" -type f ! -name '*.md' -exec grep -hoiE '#[0-9a-f]{6}' {} + \
  | tr -d '#' | tr 'a-f' 'A-F' | sort -u | grep -ivxE "$allow" | paste -sd'|' -)
git grep -inE "$PAT" -- . ':(exclude)app/dotfiles'
( cd app/dotfiles/2937f77 && git grep -inE "$PAT" )
```

Both should return empty. (Requires Dracula Pro installed at `$dp`; empty `PAT` if absent.)

## JetBrains Editor Scheme Synthesis

### IntelliJ config-dir shadowing

IntelliJ gives `<config>/colors/*.xml` **priority over plugin-bundled schemes of the
same name**. A stale config-dir file silently wins even when the plugin jar has correct
colors.

**Fix pattern:** when switching from config-dir scheme delivery to plugin-bundled, add
cleanup to remove stale files before installing the plugin:

```python
for stale in (
    os.path.join(ide_dir, "colors", "SchemeName.xml"),
    os.path.join(ide_dir, "themes", "SchemeName.theme.json"),
):
    if os.path.isfile(stale):
        os.remove(stale)
```

### Runtime substitution map

Build the dark→light substitution map entirely at runtime — never hardcode map keys
or values:

- **Keys**: `_parse_ghostty_palette(dp_dir, "<dark-variant>")` — parsed from local
  vendor source.
- **Values**: `_parse_ghostty_palette(dp_dir, "<light-variant>")`, aligned by ANSI
  index. Non-ANSI roles (orange, etc.) from the Fleet experimental palette JSON at
  `~/.local/share/<theme>/themes/jetbrains/experimental/fleet/`.
- Tokens with no named-palette equivalent: lightened algorithmically via
  luminance-flip (`colorsys`).

**Mandatory verification asserts (add permanently in the synthesis function):**

```python
# No dark tokens survived substitution
survivors = {t.lower() for t in re.findall(r'value="([0-9A-Fa-f]{6})"', xml)} & set(named_map)
assert not survivors, f"Dark tokens survived: {sorted(survivors)}"

# All background values are light (luminance ≥ 0.55)
for m in re.finditer(r'name="[A-Z_]*BACKGROUND[^"]*"\s+value="([0-9A-Fa-f]{6})"', xml):
    assert _relative_luminance("#" + m.group(1)) >= 0.55
```

## macOS Sandboxed App Containers

macOS TCC blocks **all** external process I/O to sandboxed app containers — including
`defaults write`, `PlistBuddy`, `plistlib` file writes, and direct file writes into
`~/Library/Application Support/<App>/`. This is a kernel-level restriction.

**BBEdit 16 is fully sandboxed.** `~/Library/Application Support/BBEdit/Color Schemes/`
cannot be written from install scripts. Do not check `os.path.isdir(bbedit_schemes)`
and write there — it will silently fail.

**Pattern for sandboxed app theme files:**

```python
# Write to non-sandboxed source dir
os.makedirs(out_dir, exist_ok=True)
with open(os.path.join(out_dir, "MyTheme.bbColorScheme"), "w") as fh:
    fh.write(scheme_content)

# Tell the user — do NOT write into ~/Library/Application Support/BBEdit/
print(f"BBEdit: open .bbColorScheme files from {out_dir} in BBEdit to install.")
```

**Re-import is required after every regeneration.** Updating the source dir does NOT
automatically update the copy inside BBEdit's sandbox. The user must open the
`.bbColorScheme` file in Finder (or File → Open in BBEdit) each time the theme changes.

## Atuin Theme Files

Custom theme files (`~/.config/atuin/themes/NAME.toml`) must contain a `[theme]`
section with a `name` field in addition to `[colors]`. Without it, the theme silently
fails to load and atuin renders monochrome.

```toml
[theme]
name = "dracula-pro-alucard"   # must match the filename stem

[colors]
Important = "#HEX_COLOR"
```

The `name` must match the filename stem exactly.

## McFly Colors Through SSH+tmux

McFly's `config.toml` only supports the 16 named ANSI colors (e.g., `"grey"`,
`"black"`, `"blue"`). Hex values **silently fall back to white**.

Named ANSI colors render differently depending on the **local terminal emulator's
palette** — the ANSI palette passes through SSH unchanged, but tmux re-renders using
its internal state.

**Ghostty + Dracula Pro Alucard ANSI mapping:**
- ANSI 0 (`black`) = near-white → **washed out as foreground**
- ANSI 7 (`grey`) = near-black → **legible as foreground**
- ANSI 8 (`dark_grey`) = pure white → **washed out**
- ANSI 15 (`white`) = very dark → **legible**

For light mode with Dracula Pro Alucard (Ghostty): `results_fg = "grey"` works;
`results_fg = "black"` or `"dark_grey"` do NOT.

Always test mcfly colors from the specific terminal emulator that will be used — VS
Code and Ghostty can give opposite results for the same config.
