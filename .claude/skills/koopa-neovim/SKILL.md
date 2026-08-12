---
name: koopa-neovim
description: >-
  koopa Neovim configuration and plugin lifecycle. Covers the lazy.nvim architecture
  (defaults.lazy true, checker disabled, the LazyDone autocmd that closes the plugin
  view), the koopa configure user neovim command that runs a headless Lazy sync,
  versioning lazy-lock.json in the chezmoi source, and the after/syntax/org.vim
  override that stops org inline emphasis from bleeding across lines. Use when adding
  or removing a plugin spec, when a plugin directory under
  ~/.local/share/nvim/lazy/ has no matching spec, when lazy-lock.json needs to be
  re-added after an update, or when org-mode markup renders with the wrong colors
  past an unclosed marker.
---

# koopa Neovim

## Source of truth

Chezmoi source: `opt/dotfiles/chezmoi/dot_config/nvim/`. Edit there, then deploy with
a targeted apply (see skill `koopa-chezmoi-dotfiles`). Never edit
`~/.config/nvim/` directly.

```
dot_config/nvim/
  init.vim              -- loads lua/init.lua, nothing else
  lazy-lock.json         -- versioned plugin pins, see below
  lua/
    init.lua.tmpl        -- lazy.nvim bootstrap, LSP enable
    opts.lua              -- options, keymaps, filetype detection
    plugins/*.lua         -- one lazy.nvim spec table per file
  after/
    syntax/org.vim        -- inline emphasis fix, see below
```

## Plugin lifecycle

lazy.nvim (`lua/init.lua.tmpl`) sets `defaults = { lazy = true }` and
`checker = { enabled = false }`. Missing plugins auto-install at the next startup,
but nothing ever checks for updates and nothing ever cleans a plugin whose spec was
removed. A removed spec leaves its directory behind under
`~/.local/share/nvim/lazy/<name>/` indefinitely, with no entry in `lazy-lock.json`
either, since the lock only tracks currently-specified plugins. That combination
(directory present, no spec, no lock entry) is the tell for an orphan.

Run the sync after any spec change (new plugin, removed plugin, or a `version`/
`branch` constraint edit):

```sh
koopa configure user neovim
```

This is `lang/python/src/koopa/configurers/neovim.py`, registered in
`configurers/__init__.py` as `("neovim", "common", "user")`. It runs
`nvim --headless "+Lazy! sync" +qa`, the documented headless idiom (the bang makes
the command block until finished). `:Lazy sync` = install missing + clean orphaned +
update existing, and rewrites `lazy-lock.json` as a side effect.

After the sync it diffs the deployed `~/.config/nvim/lazy-lock.json` against the
chezmoi source copy and, if they differ, prints the exact command to re-sync them:

```sh
chezmoi re-add --source=<koopa>/opt/dotfiles/chezmoi ~/.config/nvim/lazy-lock.json
```

**The lockfile is versioned**, consistent with how `etc/koopa/app.json` pins every
other koopa-managed app to an exact version. Without this, every host drifts to
whatever commits it happened to install on first run. Commit the re-added lock
alongside the spec change that caused it to move.

Full loop for a plugin change:

1. Edit the spec under `lua/plugins/*.lua` in the chezmoi source.
2. Targeted `chezmoi apply` of the changed file(s).
3. `koopa configure user neovim`.
4. If it prints the drift note, run the `chezmoi re-add` command it gives you.
5. Commit the spec change and the lockfile together.

## Inline emphasis bleeding across lines

Neovim's bundled `syntax/org.vim` (in the Neovim runtime, not koopa's) defines the
six inline emphasis regions (`*bold*`, `/italic/`, `+strike+`, `_underline_`,
`=verbatim=`, `~code~`) with `keepend` but no `oneline`. Per `:help :syn-oneline`,
without `oneline` an unclosed marker (a lone `~` in prose, e.g. "skips the ~10 min
compile") highlights everything until the next stray marker or end of file, instead
of failing to open. A single stray marker in a long note file can visibly recolor
everything after it.

`after/syntax/org.vim` in the chezmoi source clears and redefines all six regions
with `keepend oneline`, using character classes based on
`org-emphasis-regexp-components` (marker must not be adjacent to whitespace on the
inside; body cannot be empty). `oneline` means the closing marker must be found on
the same line the opening marker started on, or the region never opens at all
(nothing highlighted, rather than everything highlighted). This is a deliberate
tradeoff: real org syntax allows an emphasis span to wrap one newline, `oneline`
does not support that. An unclosed or mismatched marker is far more common in
freeform notes than a genuine multi-line emphasis span, and the runaway highlight is
much more disruptive than losing that one edge case.

Because this is an `after/syntax/` override, no `if exists("b:current_syntax")`
guard, it must run after the runtime file has already set it.

To verify the fix on a specific file, dump the syntax group at every column of
every line and confirm no emphasis group survives past its intended marker pair:

```sh
nvim -n --headless -c 'e <file>' \
  -c 'for l in range(1, line("$")) | let gs = {} | let mx = col([l, "$"]) - 1 |
      for c in range(1, mx > 0 ? mx : 1) | let n = synIDattr(synID(l, c, 1), "name") |
      if n != "" | let gs[n] = 1 | endif | endfor |
      if !empty(gs) | echo l . " " . join(keys(gs), ",") | endif | endfor' -c 'qa!'
```
