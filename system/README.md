# Shell built-ins

## Bash

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

## ZSH

```zsh
# k: keys
# o: ordering
print -l ${(ok)functions}
```

```zsh
alias
```

## References

- https://superuser.com/questions/681575

# Internal functions

## Version detection

Useful files to parse on Linux:
- `/etc/os-release`
- `/proc/version`

How to get OS name from `/etc/os-release`:
- `-F=`: Tell awk to use = as separator.
- `$1=="ID"`: Filter on ID.
- `{ print $2 ;}`: Print value.

Strip quotes:

```sh
sed 's/"//g'
tr -d \"
tr -cd '[:alnum:]'
```

macOS version: currently, use of `sw_vers` is recommended.
Alternatively, can parse this file directly instead:
`/System/Library/CoreServices/SystemVersion.plist`

See also:
- https://unix.stackexchange.com/questions/23833
- https://unix.stackexchange.com/questions/432816
- https://stackoverflow.com/questions/20007288
- https://gist.github.com/scriptingosx/670991d7ec2661605f4e3a40da0e37aa
- https://apple.stackexchange.com/questions/255546

## Redirecting console output

Redirect the console output to a file:

```sh
SomeCommand > SomeFile.txt
```

Or if you want to append data:

```sh
SomeCommand >> SomeFile.txt
```

If you want stderr as well use this:

```sh
SomeCommand &> SomeFile.txt
```

Or this to append:

```sh
SomeCommand &>> SomeFile.txt
```

If you want to have both stderr and output displayed on the console and in a
file use this:

```sh
SomeCommand 2>&1 | tee SomeFile.txt
```

If you want the output only, drop the `2` above.
