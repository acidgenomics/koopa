#!/usr/bin/env bash

koopa::assert_is_linux
koopa::alert_coffee_time
# If set, this will interfere with internal LLVM build required for
# Julia. See 'build.md' file for LLVM details.
unset LLVM_CONFIG
# > file="v${version}.tar.gz"
# > url="https://github.com/JuliaLang/julia/archive/${file}"
file="${name}-${version}-full.tar.gz"
url="https://github.com/JuliaLang/${name}/releases/download/v${version}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
# Customize the 'Make.user' file.
# Need to ensure we configure internal LLVM build here.
cat > 'Make.user' << END
prefix=${prefix}
# > LLVM_ASSERTIONS=1
# > LLVM_DEBUG=Release
# > USE_BINARYBUILDER=0
USE_LLVM_SHLIB=0
USE_SYSTEM_LLVM=0
END
make --jobs="$jobs"
# > make test
make install
