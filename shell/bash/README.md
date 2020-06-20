# Bash reference

Argument parsing:
- https://stackoverflow.com/questions/192249
- https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f

Arrays:
- http://mywiki.wooledge.org/BashFAQ/020
- http://mywiki.wooledge.org/ParsingLs
- https://stackoverflow.com/a/23357277/3911732
- https://stackoverflow.com/questions/8213328
- https://unix.stackexchange.com/questions/263883
- https://github.com/koalaman/shellcheck/wiki/SC2206
- https://stackoverflow.com/questions/1951506

Array sorting:
- https://stackoverflow.com/questions/7442417
- https://stackoverflow.com/a/7442583/3911732

## Reading lines into an array

`readarray` / `mapfile` (they're equivalent) was introduced in Bash 4.

```bash
readarray -t man_dirs <<< "$( \
    find "$KOOPA_PREFIX" \
        -mindepth 1 \
        -type d \
        -name "man" \
        -not -path "${KOOPA_PREFIX}/.git/*" \
        -not -path "${KOOPA_PREFIX}/dotfiles/*" \
        -not -path "${KOOPA_PREFIX}/shunit2-*" \
        -print \
    | sort \
)"
```

or

```bash
readarray -t filelist < <(ls -A)
```

or

```bash
array=()
while IFS= read -r -d $'\0'
do
    array+=("$REPLY")
done < <( \
    find "$HOME" \
        -mindepth 1 \
        -type d \
        -print0 \
    | sort -z \
)
```

# Re-sort an array

```bash
readarray -t array <<< "$(printf '%s\0' "${array[@]}" | sort -z | xargs -0n1)"
```

or

```bash
IFS=$'\n' array=($(sort <<<"${array[*]}"))
unset IFS
```

See also:
- How to use `BASH_REMATCH`.
  https://unix.stackexchange.com/questions/349686
- Renaming hundreds of files at once.
  https://askubuntu.com/questions/473236
- Zero padding in bash.
  https://stackoverflow.com/questions/55754
- zeropad by Michael Metz.
  https://github.com/Michael-Metz/zeropad
- Perl `rename` isn't portable.
  This ships by default with some Linux distros, but not Red Hat.
  https://techblog.jeppson.org/2016/08/add-prefix-filenames-bash/
  rename 's/\d+/sprintf("%03d", $&)/e' *.fastq.gz
