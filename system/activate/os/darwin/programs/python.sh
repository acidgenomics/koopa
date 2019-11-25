#!/bin/sh

version="$(_koopa_variable "python")"
minor_version="$(_koopa_minor_version "$version")"
py_dir="/Library/Frameworks/Python.framework/Versions/${minor_version}/bin"

if [ -z "${VIRTUAL_ENV:-}" ]
then
    # Note that MANPATH ('../share/man') will be set automatically.
    _koopa_add_to_path_start "$py_dir"
fi

unset -v minor_version py_dir version
