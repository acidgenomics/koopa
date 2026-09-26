---
paths:
  - "**/*.tmpl"
  - "**/themes/**"
  - "**/*.bbColorScheme"
  - "**/colors/*.xml"
---

# Theme File Color Rules

## Never hardcode proprietary theme hex values

Proprietary paid-theme hex values (Dracula Pro, Dracula Pro Alucard) must **not**
appear as literals in any tracked file. Committing them is an IP violation.

**Allowed as literals:**
- Free Dracula OSS colors: `#282a36`, `#6272a4`, `#50fa7b`, `#f1fa8c`, `#ff79c6`,
  `#bd93f9`, `#8be9fd`, `#ffb86c`, `#ff5555`
- Generic neutrals: `#ffffff`, `#000000`, `#fafafa`, plain greys

**Everything else in a Dracula Pro context** must be derived at runtime from
`~/.local/share/dracula-pro/`. When in doubt, verify before writing:

```sh
grep -iE '<THE_HEX>' ~/.local/share/dracula-pro/themes/ghostty/pro
```

If it matches, the code must read it at runtime — not embed it as a literal.

See skill `koopa-theming` for the runtime-derivation architecture (`_parse_ghostty_palette`,
the conditional-include chezmoi template pattern, and JetBrains synthesis asserts).
