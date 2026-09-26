# Lessons (koopa core)

> Cross-project patterns live in `~/.claude/rules/dotfiles-lessons.md` (user-curated).
> A lesson longer than a one-liner belongs in the owning skill's Gotchas
> section, or in a path-scoped rule if it fires on a file pattern: don't
> accumulate long narratives here.

## Conventions

- **Plan filenames**: use the system-generated filename as-is; never add a
  `YYYY-MM-DD-` prefix. VS Code's plan review UI requires the exact system filename.
- **Persistent env values route through the dotfiles and chezmoi sidecars.**
  Cross-shell defaults belong in koopa's own activation
  (`lang/{sh,bash,zsh,fish}/functions/activate/`), never a shell-specific
  dotfiles template. See `koopa-shell-internals` Gotchas.
- **Never search from the filesystem root; scope to a known root.** Plain `rg`
  may still walk ignored trees here (`~/.config/ripgrep/config` sets
  `--no-ignore`), so prefer `git ls-files` or `rg --ignore-vcs`. See
  `koopa-dotfiles` Gotchas.
- **Vendor-mirror docs and examples stay product-neutral.** Never name a
  specific artifact manager in `docs/`, `etc/koopa/vendor.json.example`,
  tests, or code comments; the backend identifier is `http` for exactly this
  reason.
- **Agent scratch files never land in the repo working directory or `/tmp`.**
  `uv pip compile` has no `-` = stdout convention: `-o -` writes a literal
  file named `-` into the cwd. Omit `-o` entirely for stdout, and put scratch
  inputs in a `mktemp -d` directory (respects `$TMPDIR`), deleted in the same
  command.
- **An advisory check called from `koopa update`/`koopa system check` must be
  fast/local or self-cached, never an unconditional live network call.** If
  it can't be, move it behind an explicit command instead. See
  `koopa-theming` (Dracula Pro update-check case).

## Skills and path-scoped rules

Claude Code lists every skill's description, and loads each `paths:`-scoped
rule when a matching file opens, so no index is kept here. Sources:
`.claude/skills/koopa-*/SKILL.md`, `.claude/rules/koopa-*.md`.
