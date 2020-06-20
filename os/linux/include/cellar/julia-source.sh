#!/usr/bin/env bash
# shellcheck disable=SC2154

_koopa_coffee_time

# If set, this will interfere with internal LLVM build required for
# Julia. See 'build.md' file for LLVM details.
unset LLVM_CONFIG

# > file="v${version}.tar.gz"
# > url="https://github.com/JuliaLang/julia/archive/${file}"
file="${name}-${version}-full.tar.gz"
url="https://github.com/JuliaLang/${name}/releases/download/v${version}/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
# Customize the 'Make.user' file.
# Need to ensure we configure internal LLVM build here.
cat > Make.user << EOL
prefix=${prefix}
# > LLVM_ASSERTIONS=1
# > LLVM_DEBUG=Release
# > USE_BINARYBUILDER=0
USE_LLVM_SHLIB=0
USE_SYSTEM_LLVM=0
EOL
make --jobs="$jobs"
# > make test
make install
