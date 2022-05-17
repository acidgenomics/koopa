#!/usr/bin/env bash

koopa_is_recent() {
    # """
    # If the file exists and is more recent than 2 weeks old.
    # @note Updated 2022-02-24.
    #
    # Current approach uses find to filter based on modification date.
    #
    # Alternatively, can we use 'stat' to compare the modification time to Unix
    # epoch in seconds or with GNU date.
    #
    # NB Don't attempt to use 'koopa_find' here, as this is acting directly
    # on a file rather than directory input.
    #
    # @seealso
    # - https://stackoverflow.com/a/32019461
    # - fd using '--changed-before <DAYS>d' argument.
    #
    # @examples
    # > koopa_is_recent ~/hello-world.txt
    # """
    local app dict file
    koopa_assert_has_args "$#"
    declare -A app=(
        [find]="$(koopa_locate_find)"
    )
    declare -A dict=(
        [days]=14
    )
    for file in "$@"
    do
        local exists
        [[ -e "$file" ]] || return 1
        exists="$( \
            "${app[find]}" "$file" \
                -mindepth 0 \
                -maxdepth 0 \
                -mtime "-${dict[days]}" \
            2>/dev/null \
        )"
        [[ -n "$exists" ]] || return 1
    done
    return 0
}
