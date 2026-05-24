# Lessons

## Plan Files Must Have YYYY-MM-DD Prefix

Plan files saved to `.claude/plans/` must always be named with a `YYYY-MM-DD-` date prefix (e.g., `2026-05-19-fix-completion-duplicates.md`). Names without the prefix are non-conforming and will need to be renamed.

## Use `has_sudo` for Sudo Checks — Don't Add New Sudo Functions

`koopa.system.has_sudo()` is the single function for checking whether
sudo is currently usable without a password prompt. Do not create additional helpers
(e.g., `_has_sudo`, `can_sudo`, `check_sudo`) for this purpose — they duplicate it.
Always import and reuse `has_sudo` from `koopa.system`.

## app.json Edits Require Formatting and a Revision Bump

After modifying `etc/koopa/app.json`, always run:

```
koopa develop format-app-json
```

This keeps formatting consistent and all keys sorted correctly. Also increment
the `revision` field for the edited app entry (add `"revision": 1` if absent)
to signal that installed instances need to be re-linked or reinstalled.

## Chezmoi Templates Run Before Post-Install Generators

When a chezmoi template needs to detect something that an install script
generates *after* `chezmoi apply` (e.g., a file written by a post-chezmoi
function), `stat` on the generated output will always miss — chezmoi runs
first. Instead, detect the *source* that triggers generation (e.g., the
upstream `.tmTheme` file that causes `.rstheme` to be generated) rather than
the generated artifact itself.

## CLI Changes Require Regenerating Completions

When renaming, adding, or removing CLI commands in koopa, always run
`koopa develop generate-completion` afterward. The shell autocomplete definitions
are generated, not hand-maintained, so they go stale if not regenerated. This
caused `koopa app brew upgrade-brews` to appear in completions even though the
command was renamed to `koopa app brew upgrade`.

## Dotfiles Are Managed by Chezmoi — Edit the Source

Home-directory dotfiles (e.g., `~/.claude/settings.json`, `~/.bashrc`,
`~/.config/...`) are managed by chezmoi. The source of truth lives in
`~/.config/koopa/dotfiles/chezmoi/`. When modifying a dotfile, always edit
the corresponding chezmoi source template/file (e.g.,
`dot_claude/settings.json`) in addition to (or instead of) the deployed copy.
Otherwise the change will be overwritten on the next `chezmoi apply`.
