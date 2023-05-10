#!/usr/bin/env bash

# FIXME This is erroring out with Perl, argh.

koopa_debian_needrestart_noninteractive() {
    # """
    # Ensure that needrestart runs non-interactively, so that apt-get doesn't
    # error in non-interactive subshells.
    # @note Updated 2023-05-10.
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
    dict['pattern']="#\$nrconf{restart} = 'i';"
    dict['replacement']="\$nrconf{restart} = 'l';"
    [[ -f "${dict['file']}" ]] || return 0
    if koopa_file_detect_fixed \
        --file="${dict['file']}" \
        --pattern="${dict['replacement']}"
    then
        return 0
    fi
    koopa_assert_is_admin
    koopa_alert "Replacing '${dict['pattern']}' with '${dict['replacement']}' \
in '${dict['file']}'."
    koopa_find_and_replace_in_file \
        --fixed \
        --pattern="${dict['pattern']}" \
        --replacement="${dict['replacement']}" \
        --sudo \
        "${dict['file']}"
    return 0
}

