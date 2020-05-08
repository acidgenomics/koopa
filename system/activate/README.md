# Bash

List all environment variables:

```bash
declare -p
```

Exported environment variables:

```bash
declare -px
env
```

List all function names:

```bash
declare -F
```

# ZSH

```zsh
# k: keys
# o: ordering
print -l ${(ok)functions}
```

```zsh
alias
```

# References

- https://superuser.com/questions/681575
