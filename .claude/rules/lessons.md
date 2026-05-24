# Lessons

## Plan Files Must Have YYYY-MM-DD Prefix

Plan files saved to `.claude/plans/` must always be named with a `YYYY-MM-DD-` date prefix (e.g., `2026-05-19-fix-completion-duplicates.md`). Names without the prefix are non-conforming and will need to be renamed.

## Use `has_sudo` for Sudo Checks — Don't Add New Sudo Functions

`koopa.system.has_sudo()` is the single function for checking whether
sudo is currently usable without a password prompt. Do not create additional helpers
(e.g., `_has_sudo`, `can_sudo`, `check_sudo`) for this purpose — they duplicate it.
Always import and reuse `has_sudo` from `koopa.system`.

## CLI Changes Require Regenerating Completions

When renaming, adding, or removing CLI commands in koopa, always run
`koopa develop generate-completion` afterward. The shell autocomplete definitions
are generated, not hand-maintained, so they go stale if not regenerated. This
caused `koopa app brew upgrade-brews` to appear in completions even though the
command was renamed to `koopa app brew upgrade`.
