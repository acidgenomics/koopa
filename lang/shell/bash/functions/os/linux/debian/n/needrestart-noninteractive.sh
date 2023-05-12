#!/usr/bin/env bash

koopa_debian_needrestart_noninteractive() {
    # """
    # Ensure that needrestart runs non-interactively, so that apt-get doesn't
    # error in non-interactive subshells.
    # @note Updated 2023-05-12.
    #
    # @seealso
    # - https://bugs.launchpad.net/ubuntu/+source/ubuntu-advantage-tools/
    #     +bug/2004203
    # - https://bugs.launchpad.net/ubuntu/+source/needrestart/+bug/1941716
    # - https://stackoverflow.com/questions/73397110/
    # - https://github.com/liske/needrestart/issues/129
    # - https://askubuntu.com/questions/1367139/
    # """
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['file']='/etc/needrestart/needrestart.conf'
    [[ -f "${dict['file']}" ]] || return 0
    if koopa_file_detect_regex \
        --file="${dict['file']}" \
        --pattern="^\$nrconf\{restart\} = 'a';"
    then
        return 0
    fi
    koopa_assert_is_admin
    koopa_alert "Replacing '${dict['pattern']}' with '${dict['replacement']}' \
in '${dict['file']}'."
    koopa_find_and_replace_in_file \
        --regex \
        --pattern="^#\$nrconf\{restart\}.+$" \
        --replacement="\$nrconf{restart} = \'a\';" \
        --sudo \
        "${dict['file']}"
    return 0
}

