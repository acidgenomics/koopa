# Lessons

## CLI Changes Require Regenerating Completions

When renaming, adding, or removing CLI commands in koopa, always run
`koopa develop generate-completion` afterward. The shell autocomplete definitions
are generated, not hand-maintained, so they go stale if not regenerated. This
caused `koopa app brew upgrade-brews` to appear in completions even though the
command was renamed to `koopa app brew upgrade`.
