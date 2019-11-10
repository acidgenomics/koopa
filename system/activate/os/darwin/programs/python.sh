#!/bin/sh

version="$(_acid_variable "python")"
major_version="$(_acid_major_version "$version")"
py_dir="/Library/Frameworks/Python.framework/Versions/${major_version}/bin"

if [ -z "${VIRTUAL_ENV:-}" ]
then
    # Note that MANPATH ('../share/man') will be set automatically.
    _acid_add_to_path_start "$py_dir"
fi

unset -v major_version py_dir version
