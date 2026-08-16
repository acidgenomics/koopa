---
name: koopa-theming
description: >-
  Reference for koopa theme synthesis across editors and terminals — Dracula Pro
  runtime pipeline, fish color architecture (fish_frozen_theme.fish override, _FISH_COLOR_ROLES
  generator, live sync hook), JetBrains/IntelliJ scheme delivery, atuin and mcfly color
  config, vim/nvim statusline theming (airline explicit g:airline_theme read, lualine
  palette-reading theme function, why 'auto' silently produces wrong colors), and
  macOS sandboxed-app theme installation. Use when generating or fixing editor/terminal
  color schemes, debugging a theme that renders incorrectly, or writing theme-install
  code. For the "never hardcode Pro hex" guardrail see the path-scoped theme-colors rule.
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

### Synthesizing a Theme When No Upstream Dracula Pro File Exists

Most terminal tools (kitty, alacritty, wezterm, atuin) have an official Dracula
Pro theme file to parse. Some don't — no `find ~/.local/share/dracula-pro
-ipath '*<tool>*'` hit anywhere in the vendor tree (btop, in the 2026-08 case:
`btop`/`bpytop`/`bashtop` share a `.theme` key=value grammar, but Dracula Pro
never shipped one). The generator has to build the file from a parsed palette
rather than transform an existing one.

**Palette source: prefer `_parse_vim_palette()` over
`_parse_ghostty_palette()`** when the target format needs more than the 16 raw
ANSI slots. `_parse_ghostty_palette()` only gives ANSI red/green/yellow/etc.
`_parse_vim_palette()` additionally names `orange`/`pink`/`purple` explicitly
and provides a 5-step background ramp (`bg`/`bgdark`/`bgdarker`/`bglight`/
`bglighter`) — exactly what a system-monitor theme's `main_bg`/`meter_bg`/
`selected_bg`/`div_line` roles need and the ANSI-only palette can't supply.

**Gradient stops: derive with `_hex_lerp()`, never hand-pick intermediate hex.**
When the target format wants a 3-stop gradient (`theme[foo_start]`/`_mid`/
`_end`) but the palette only names one color per role, blend that named role
toward `bg` (for the pale `start`) and toward `fg` (for the saturated `end`)
with the existing `_hex_lerp()` helper — same shape the free `dracula.theme`
uses for its `free_start`/`free_mid`/`free_end` ramps. This keeps every value
runtime-derived (passes the proprietary-hex audit) instead of inventing a
plausible-looking literal.

**A `removed: true` predecessor is a ready-made porting reference.** If the
new tool has a predecessor in `etc/koopa/app.json` marked
`{"removed": true, "successor": "<tool>"}` that used the same config grammar
(`bpytop` → `btop`: both are the `.theme` format), that predecessor's existing
`.tmpl` — even though dead code and not installed — is the fastest way to find
the working non-color settings to seed the new template from, and its dark/light
branching (however primitive) shows which lines actually need to vary.

**Verify per-variant legibility before shipping**, not just per-role existence:
compute WCAG contrast of every candidate foreground role against that variant's
`bg` (reuse `_wcag_relative_luminance()`/`_contrast_ratio()`, already in
`install`). A role that reads fine on `pro`'s near-black `bg` can fail on
`alucard`'s near-white `bg` — this is a broader case of the documented
Alucard-`comment`-is-white quirk in `_generate_atuin_dracula_pro_toml`/
`_fzf_color_opts`: assume nothing about legibility carries between variants,
check both.

### ANSI 8 is unreadable as a dim/comment color in every variant

`ansi.get(8)`/`black_bright` is too low-contrast against its own background in
every Dracula Pro variant, not just Alucard: CR ranges 1.84-2.35:1 in the dark
variants, 1.09:1 in Alucard. Any consumer that treats ANSI 8 as a dim/comment/
shadow color renders invisible text, confirmed for htop's meter-shadow color
pair (decoded straight out of the shipped binary's `_CRT_colorSchemes` table),
kitty's `color8`, WezTerm's `brights[0]`, and RStudio's ANSI-8 terminal remap.

**Fix: `_dracula_dim_color(dp_dir, variant, fallback_fg, fallback_bg)`.** Reads
the variant's named Vim `comment` role, which clears 3.5-5.6:1 in every
variant, instead of the raw ANSI-8 sentinel. Falls back to a `_hex_lerp()`
blend only if the Vim palette is unavailable. `_parse_ghostty_palette()`'s
`"comment"` key now returns this. `"black_bright"` is left as the raw ANSI-8
value and stays safe only as a background (e.g. an inactive tab panel); never
route it to a text/foreground role again.

**Ghostty's own theme file is generated, not symlinked.** Every other Dracula
Pro consumer in `install` parses the upstream file and writes a different
generated file elsewhere. Ghostty is the one exception: htop, and any other
app that resolves ANSI 8 straight from the terminal, reads Ghostty's palette
directly, and there is no koopa-owned config downstream to intercept.
`_generate_ghostty_dracula_pro_theme()` rewrites just the `palette = 8=` line
of the upstream file, and `_configure_dracula_pro()` writes that as a real
file under `~/.config/ghostty/themes/`. If an older install symlinked that
path, clear the symlink before writing: `open(dest, "w")` on a stale symlink
writes through it into the upstream vendor file.

**`_parse_vim_palette()` variant slugs are hyphenated, filenames are not.**
`van-helsing`'s Vim colorscheme file is `dracula_pro_van_helsing.vim`, so the
naive `f"dracula_pro_{variant}.vim"` never matches: that variant silently got
no named palette (fell through to the `_hex_lerp()` fallback) until fixed with
`variant.replace("-", "_")`.

## Colorblind-Safe Diff and Git-Status Colors

`_generate_diff_colorblind_palette(dp_dir, variant)` in `install` derives a
blue/orange/cyan palette for git-related coloring across three surfaces:
delta (terminal), git's own `[color "diff"/"status"/"branch"]`, and VS Code's
`workbench.colorCustomizations`. This is a **deliberate override**, not an
adopted vendor convention: the Dracula Pro VS Code extension, its vim
colorscheme, and koopa's own generators all use plain green=added/red=removed
with no exception. Confirm the distinction before touching any of this again:
check `contributes.colors`/`tokenColors` in the installed `.vsix`'s theme
JSON, and `DiffAdd`/`DiffDelete`/`DiffChange` in
`themes/vim/colors/dracula_pro_base.vim` — every one of them is red/green,
never blue/orange.

**What *is* adopted from the vendor:** orange for a "modified/changed" role.
Confirmed independently in three places: `gitDecoration.modifiedResourceForeground`
in the theme JSON, `DiffChange`/`DiffText` in the vim colorscheme's base
file, and the Vim palette's own named `orange` role are the same hex.
`status.changed` uses this, unmodified, on purpose — treat it as vendor-exact,
not koopa-derived, when reasoning about it. `status.deleted` is cyan, not
orange, specifically *because* orange is spoken for: `modified:` and
`deleted:` entries co-occur in the same `git status` output, so they can't
share a hue. Also adopted from the vendor: VS Code's alpha suffixes (`20`
line background, `40` text background, `80` gutter) — read directly from the
installed `.vsix`'s `colors.diffEditor.*` keys, not invented.

**Deriving mutual separation for background tints.** Two colors that are each
individually legible against a background can still read as near-identical
to each other if derived the same way: blending both toward `bg` to hit the
*same* target contrast ratio converges them to nearly the same luminance
regardless of hue (measured: 1.01:1 mutual contrast). Deliberately picking
two *different* target ratios (1.3 for added, 2.2 for removed) forces them
apart in lightness as well as hue. This only matters for backgrounds/washes;
for plain text (git status labels, gitDecoration foregrounds), hue-only
separation is enough, because each entry is always paired with its own
English word ("modified:", "deleted:") — the same standard the vendor's own
theme uses for that specific distinction.

**A vendor-exact color can still fail on user taste even when it's not a
contrast bug.** Alucard's `orange` (`#A34D14`) measures a fine 5.3:1 against
its background as text, but its HLS hue angle is ~24 degrees, closer to pure
red (0 degrees) than to a hue most people would call orange (30-40 degrees)
— it reads as "reddish" even though it passes every contrast check. This is
real and measurable (compute hue via `colorsys.rgb_to_hls`), not merely
subjective, and it is the vendor's own value (confirmed identical in the
Fleet experimental palette) — not a koopa derivation bug to "fix" by changing
the source. `_nudge_hue_toward(hexcolor, target_hex, min_hue_deg)` blends
toward another real, already-verified palette color (the Vim `yellow` role,
in this case) only as far as needed to clear a hue floor, and is a no-op when
the input already clears it (Pro's orange, hue ~35, is untouched). Never
invent a replacement hex to fix a "looks wrong" complaint — derive the
correction from another real color in the same palette, the same way every
other value in this pipeline is derived.

**Terminal (pre-composited) vs VS Code (live-composited) need opposite math
for the *same* visual role.** A terminal has no alpha compositing, so a
background tint has to be a real, final, opaque hex, pre-blended toward `bg`
via `_hex_lerp` at generation time (used for delta's `plus-style`/`minus-style`
and nothing else needs this). VS Code composites `colorCustomizations`
values live over the actual syntax-highlighted text underneath, so the same
visual effect there is the *raw* saturated color plus an alpha suffix, with
no pre-blending at all — pre-blending toward `bg` for VS Code would produce
an opaque wash that hides syntax highlighting entirely, the opposite of what
alpha compositing is for.

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

Not Alucard-specific: see "ANSI 8 is unreadable as a dim/comment color in
every variant" above. `_parse_ghostty_palette()`'s `"comment"` key is now
`_dracula_dim_color()`-derived everywhere, so this predates that fix and is
redundant for alucard, but still correct (cursor and the Vim comment role
both clear contrast there). Kept as the fish-specific implementation record.

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

**Unmapped tokens need a role-aware transform, not a blind luminance-flip.**
A flat "lighten anything unmapped" pass (`_lightify_hex()`, forces lightness
>= 0.88) is correct for background/decoration roles but wrong for foreground/
text roles. Checked against the actual vendor `DraculaPro.xml`: 34 of 45
distinct colors fell through to it, and all 34 landed between 1.04:1 and
1.32:1 against the light editor background. Classify by the enclosing
`<option name="...">`: `BACKGROUND`/`CARET_ROW_COLOR`/`*_STRIPE_COLOR` roles
still use `_lightify_hex()`; everything else (including `FOREGROUND`,
`EFFECT_COLOR`, and the various `FILESTATUS_*`/`VCS_ANNOTATIONS_*` text-tint
roles) needs `_darken_for_light_bg()` instead. It preserves hue/saturation and
binary-searches HLS lightness against `_contrast_ratio()` until it clears the
threshold, since a fixed HLS-lightness constant doesn't track WCAG luminance
for green/yellow hues.

**The named ANSI map itself can collide with a text role.** Pro's dark
`selection_bg` hex was also reused by the vendor XML for
`LINE_NUMBERS_COLOR`/`INDENT_GUIDE`/separator roles, and Alucard's
`selection_bg` is deliberately near the editor background, so trusting the map
blindly left those at 1.48:1. Gate every non-background named-map hit on
`_contrast_ratio(...) >= 3.0` and fall back to `_darken_for_light_bg()` when it
fails.

**Mandatory verification asserts (add permanently in the synthesis function):**

```python
# No dark tokens survived substitution
survivors = {t.lower() for t in re.findall(r'value="([0-9A-Fa-f]{6})"', xml)} & set(named_map)
assert not survivors, f"Dark tokens survived: {sorted(survivors)}"

# All background values are light (luminance ≥ 0.55)
for m in re.finditer(r'name="[A-Z_]*BACKGROUND[^"]*"\s+value="([0-9A-Fa-f]{6})"', xml):
    assert _relative_luminance("#" + m.group(1)) >= 0.55

# All foreground/text values are actually readable -- the background
# check above doesn't cover this.
for m in _option_hex_re.finditer(xml):
    if _bg_role_re.search(m.group(1)):
        continue
    assert _contrast_ratio("#" + m.group(2), bg) >= 3.0
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

## Vim Colorscheme and Airline Theme

### Airline is not auto-adaptive — set it explicitly

vim-airline does **not** inherit the theme from the active colorscheme. When
`colorscheme dracula_pro_alucard` (light) is set without also setting
`g:airline_theme`, airline falls back to its implicit dark theme (`theme=dark`),
producing a neon-yellow/near-black statusline over a light Alucard buffer.

The `dracula_pro` airline theme file
(`~/.vim/pack/theme/start/dracula_pro/autoload/airline/themes/dracula_pro.vim`)
is palette-adaptive: it reads `g:dracula_pro#palette` at the time the theme is
applied. Since Alucard populates that palette with light values before
`dracula_pro_base.vim` runs, the airline theme is light-safe — one theme name is
correct for both light and dark modes.

**Pattern:** set `g:airline_theme='dracula_pro'` immediately after every
`colorscheme dracula_pro*` call — both in the startup block and in any live-switch
function. In the live-switch function, pair it with `silent! AirlineTheme dracula_pro`
to repaint a running airline instance (a `let g:` alone does not refresh the running
statusline).

```vim
" Startup (both light and dark branches):
colorscheme dracula_pro_alucard   " or dracula_pro / dracula_pro_<variant>
let g:airline_theme='dracula_pro'

" Live-switch function (s:KoopaApplyColorMode):
colorscheme dracula_pro_alucard   " or variant
silent! AirlineTheme dracula_pro
```

Leave non-Pro fallbacks (`vim-one` → `airline_theme='one'`; free `dracula` → no
airline theme) unchanged.

### `set background=dark` is baked into the Dracula Pro base scheme

`dracula_pro_base.vim` always sets `set background=dark` regardless of which variant
is loaded. This is intentional — the scheme uses explicit `guifg`/`guibg` values and
does not rely on Vim's `background` option for palette selection. A `background=dark`
value after loading Alucard is therefore expected and correct, not a bug. The
Alucard-specific `dracula_pro_alucard.vim` overrides the palette dict entries before
calling `runtime colors/dracula_pro_base.vim`, so the light colors are already in
`g:dracula_pro#palette` when the base file runs.

### nvim (lualine) needs the same explicit read as airline — `auto` does not work

Unlike vim-airline, lualine ships **no** Dracula Pro theme file at all (no
`lua/lualine/themes/dracula_pro.lua`), so `theme = 'auto'` was never deriving
from the colorscheme — it was falling through to lualine's bundled `auto.lua`,
which *guesses* by scraping unrelated highlight groups (`PmenuSel`,
`StatusLine`, `String`) through a ±10% brightness modifier and a contrast-
iteration loop. Measured result: gray-on-gray in both dark and Alucard, with
wrong per-mode accents (e.g. yellow instead of green for insert in Alucard).
This is a heuristic guess, not a faithful derivation, and it produces the
wrong colors.

**Fix (`dot_config/nvim/lua/plugins/ui.lua`):** mirror the airline pattern —
read `g:dracula_pro#palette` directly, just via the Lua accessor
`vim.g['dracula_pro#palette']` instead of vim's `g:` syntax. A
`dracula_pro_lualine_theme()` function builds the lualine theme table from
`purple`/`green`/`yellow`/`red`/`cyan` per mode, with `fg` on `selection` for
section `b` (the vendor airline theme's `fg` on `comment` measures 2.78:1 in
Alucard — fails WCAG AA) and `bgdark` for section `c` (Alucard's `bglight`
equals `Normal.bg` exactly, so the bar's middle would vanish).

```lua
local function dracula_pro_lualine_theme()
    local p = vim.g['dracula_pro#palette']
    if type(p) ~= 'table' or type(p.purple) ~= 'table' then
        return nil
    end
    -- build theme table from p.purple, p.green, p.selection, p.bgdark, etc.
end
```

`opts` must be a **function**, not a table literal — a literal is evaluated at
lazy.nvim spec-parse time, before any colorscheme has loaded, so the palette
global wouldn't exist yet. `theme` must also be a function: lualine's own
`autocmd lualine ColorScheme *` re-invokes it on every `:colorscheme` call,
which is what makes a live dark↔light flip re-derive automatically — the
Lua-side equivalent of airline's `silent! AirlineTheme dracula_pro` re-paint.

Leave non-Pro fallbacks unchanged: the function returns `nil` when Pro isn't
installed, so `theme` falls back to the string `'auto'` — correct for
`dracula.nvim` (bundled `lualine/themes/dracula.lua`, free OSS hex) and
`vim-one` (no bundled match either way).
