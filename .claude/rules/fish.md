---
paths:
  - "**/*.fish"
---

# Fish Shell Conventions

## Variable style

Fish uses `$VAR` — never `${VAR}` (bash-ism). Fish's parser already unambiguously
delimits variable names without braces; curly braces add noise with no benefit.

Applies to all environment variables referenced in fish scripts: `$KOOPA_PREFIX`,
`$XDG_CACHE_HOME`, `$XDG_CONFIG_HOME`, `$XDG_DATA_HOME`, `$HOME`, etc.
