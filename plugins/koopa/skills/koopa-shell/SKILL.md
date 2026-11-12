---
name: koopa-shell
description: >-
  Shell coding conventions for Bash and POSIX shell, including indentation and
  control-flow layout. Use when writing shell scripts, editing shell startup
  files, or changing shell code in chezmoi templates.
---

# Shell coding conventions

## Indentation

Use four spaces for each indentation level in shell code.

Chezmoi filenames can hide their file type behind prefixes such as `dot_`,
`executable_`, and a `.tmpl` suffix. Shell conventions still apply to shell
code in those files. For non-shell data inside `.tmpl` files, follow the
formatting rules for that data format instead.

## Control-flow layout

Put `then`, `do`, and `else` on their own lines. Do not join a control-flow
keyword to its condition with a semicolon:

```sh
if [ -f "$file" ]
then
    ...
fi

for item in "${items[@]}"
do
    ...
done
```

## macOS `sed -i`

BSD `sed -i` on macOS requires a backup suffix. For in-place edits, use
`gsed -i` when available or an editor for a small change.
