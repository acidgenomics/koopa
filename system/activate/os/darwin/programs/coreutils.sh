#!/bin/sh

# GNU coreutils.
# Updated 2019-10-11.

# Linked using "g*" prefix by default.
# > brew info coreutils

if _koopa_is_installed brew
then
    coreutils_dir="/usr/local/opt/coreutils/libexec"
    _koopa_force_add_to_path_start "${coreutils_dir}/gnubin"
    _koopa_force_add_to_manpath_start "${coreutils_dir}/gnuman"
    unset -v coreutils_dir
fi
