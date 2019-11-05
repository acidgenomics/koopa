#!/bin/sh

version="$(_koopa_variable "python")"
major_version="$(_koopa_major_version "$version")"
py_dir="/Library/Frameworks/Python.framework/Versions/${major_version}/bin"

if [ -z "${VIRTUAL_ENV:-}" ]
then
    _koopa_add_to_path_start "$py_dir"
fi

unset -v major_version py_dir version
