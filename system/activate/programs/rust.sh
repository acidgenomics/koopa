#!/bin/sh

# Rust programming language.
# Updated 2019-09-17.

# Attempt to locate cargo home and source the env script.
# This will put the rust cargo programs defined in `bin/` in the PATH.

# Alternatively, can just add `${cargo_home}/bin` to PATH.

cargo_home="${HOME}/.cargo"
env_exe="${cargo_home}/env"

if [ -x "$env_exe" ]
then
    # shellcheck source=/dev/null
    . "$env_exe"
fi

unset -v cargo_home env_exe
