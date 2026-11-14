# Applications

Koopa supports installation of many applications. Currently supported apps can be
seen using <kbd>TAB</kbd> autocompletion with `koopa install <TAB>`. To install the
recommended default stack, run `koopa install`. To update koopa to the latest version
and upgrade all currently installed apps, run `koopa update`. System configuration can
be checked with `koopa system check`.

## Lig shell integration

Lig is included in the default application stack. Koopa initializes it in interactive,
non-minimal Bash 4.4+, Zsh, fish, and PowerShell terminal sessions. Set
`LIG_DISABLE=1` before shell activation to opt out. Koopa runs `lig init` and
caches its shell snippets; it does not run `lig install` or modify shell startup
files. Koopa builds a pinned Lig release from SHA-256-verified source with a
patch that reloads theme changes in running sessions. Source builds require
Cargo registry access; vendor-only installations require a koopa binary package.

## Default application stack

```{include} _generated/app-stack.md
```
