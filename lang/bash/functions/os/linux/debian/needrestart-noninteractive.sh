#!/usr/bin/env bash

_koopa_debian_needrestart_noninteractive() {
    # """
    # Ensure that needrestart runs non-interactively.
    # @note Updated 2023-05-12.
    #
    # Alternatively, can wipe this annoying program with:
    # > apt purge needrestart
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
    _koopa_assert_has_no_args "$#"
    dict['file']='/etc/needrestart/needrestart.conf'
    [[ -f "${dict['file']}" ]] || return 0
    if ! _koopa_file_detect_fixed \
        --file="${dict['file']}" \
        --pattern="#\$nrconf{restart} = 'i';"
    then
        return 0
    fi
    _koopa_assert_is_admin
    _koopa_alert "Modifying '${dict['file']}'."
    _koopa_find_and_replace_in_file \
        --fixed \
        --pattern="#\$nrconf{restart} = \'i\';" \
        --replacement="\$nrconf{restart} = \'a\';" \
        --sudo \
        "${dict['file']}"
    return 0
}

