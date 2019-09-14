#!/bin/sh

# Rust programming language.
# Updated 2019-09-14.

# Attempt to locate cargo home and source the env script.
# This will put the rust cargo programs defined in `bin/` in the PATH.

# Alternatively, can just add `${cargo_home}/bin` to PATH.

cargo_home="${HOME}/.cargo"

if [ -d "$cargo_home" ]
then
    # shellcheck source=/dev/null
    . "${cargo_home}/env"
fi

unset -v cargo_home
