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
  past an unclosed marker. Also covers nvim-treesitter's main-branch rewrite
  (no highlighting, empty parser directory), duplicate ruff diagnostics, and an
  Enter-key mapping that breaks quickfix.
---

# koopa Neovim

## Source of truth

Chezmoi source: `opt/dotfiles/chezmoi/dot_config/nvim/`. Edit it on a branch (see skill
`koopa-dotfiles` for the detached HEAD rule), then deploy with
a targeted apply (see skill `koopa-chezmoi-dotfiles`). Never edit
`~/.config/nvim/` directly.

```
dot_config/nvim/
  init.vim              : loads lua/init.lua, nothing else
  lazy-lock.json        : versioned plugin pins, see below
  lua/
    init.lua.tmpl       : lazy.nvim bootstrap, LSP enable
    opts.lua            : options, keymaps, filetype detection
    plugins/*.lua       : one lazy.nvim spec table per file
  after/
    syntax/org.vim      : inline emphasis fix, see below
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

## Gotchas from a 2026-10 config review

### nvim-treesitter `main` is a rewrite: highlighting is off until you start it

lazy.nvim installs the plugin's default branch, which is now the rewritten `main`.
A spec written for the old `master` loads without error and then does nothing:

- No `config` that starts highlighting. `main` does not start it for you. Call
  `vim.treesitter.start()` on `FileType`, wrapped in `pcall` so a language with no
  parser is skipped. Neovim 0.12 only starts it by itself for the parsers it bundles.
- `build = ':TSInstall ...'` is the old style. Use `build = ':TSUpdate'` and call
  `require('nvim-treesitter').install({ ... })` from `config`.
- `lazy = false`. `main` does not support lazy loading.
- It compiles parsers with the `tree-sitter` CLI. That CLI is a koopa app, so the
  fix is `koopa install tree-sitter`. Guard the install call with
  `vim.fn.executable('tree-sitter') == 1` so nvim still starts without it.

Symptom that exposed it: `~/.local/share/nvim/site/parser` was empty and the plugin
checkout had a `runtime/` directory (the `main` layout). See
`dot_config/nvim/lua/plugins/treesitter.lua` in the chezmoi source.

### A linter plugin plus the same language server doubles every diagnostic

`nvim-lint` running `ruff` and `vim.lsp.enable('ruff')` both report the same
findings, one under each source. Keep the language server (it also gives code
actions) and delete the `nvim-lint` spec. Formatting through `conform.nvim` is
separate and stays.

### A global `<CR>` mapping overrides the built-in Enter in special buffers

`vim.keymap.set('n', '<cr>', 'o<esc>')` makes Enter add a blank line everywhere,
including quickfix and location lists (where Enter jumps), help and man pages
(where it follows a link) and the command-line window. Restore it per buffer:

```lua
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'qf', 'help', 'man', 'checkhealth' },
    callback = function(args)
        vim.keymap.set('n', '<cr>', '<cr>', { buffer = args.buf })
    end,
})
vim.api.nvim_create_autocmd('CmdwinEnter', {
    callback = function(args)
        vim.keymap.set('n', '<cr>', '<cr>', { buffer = args.buf })
    end,
})
```

### Check a Lua edit headless, without installing anything

`nvim -l` passes script arguments in the `arg` table, not in `...`. Compile each
file with `loadfile`, run plugin spec files with `dofile` to see what they return,
and read a mapping back with `vim.fn.maparg`:

```sh
nvim --headless -u NONE -i NONE -l check.lua file1.lua file2.lua
```

Write the script to a `mktemp -d` directory and delete it afterwards. `-u NONE`
skips your config, so nothing loads and nothing is installed.
