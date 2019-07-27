# Internal functions

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
