#!/bin/sh

koopa_is_rhel_ubi() { # {{{
    # """
    # Is the operating system a RHEL universal base image (UBI)?
    # @note Updated 2020-08-06.
    # """
    [ -f '/etc/yum.repos.d/ubi.repo' ]
}
