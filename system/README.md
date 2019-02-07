Shellcheck notes:

```
SC2236: Use `-n` instead of `! -z`.
zsh doesn't interpret `-n` correctly in POSIX mode.
```

Here's how to list all functions defined:

```bash
declare -F
```

POSIX sh tricks:
http://www.etalabs.net/sh_tricks.html
