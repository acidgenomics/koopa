---
paths:
  - "lang/zsh/**"
---

# Zsh Conventions

## ShellCheck

ShellCheck cannot analyze zsh; all warnings from `lang/zsh/` are false positives.

- Never suggest running ShellCheck on files under `lang/zsh/`.
- Never add `# shellcheck` directives to zsh files to suppress warnings.
- Files under `lang/zsh/functions/` use `#!/usr/bin/env zsh` shebangs with a `.sh`
  extension; this is intentional. Do not suggest renaming to `.zsh`.
- The only shell linting for zsh files is the custom regex-based illegal-string checks
  inside `_handle_shellcheck()` in `cli_develop.py`.

`koopa develop shellcheck` already excludes zsh files intentionally.

## Reserved variable names

Never name a shell variable `status` in zsh. It is a read-only special
variable (an alias for `$?`, the last exit code). `status=$(...)` fails with
`read-only variable: status`. Use a different name, for example `<name>_status`.
