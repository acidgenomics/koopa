#!/bin/sh



# LLVM                                                                      {{{1
# ==============================================================================

# Note that LLVM 7 specifically is now required to install umap-learn.
# Current version LLVM 9 isn't supported by numba > llvmlite yet.
llvm_config=
if _acid_is_rhel7
then
    llvm_config="/usr/bin/llvm-config-7.0-64"
elif _acid_is_darwin
then
    # Homebrew LLVM 7
    # > brew install llvm@7
    llvm_config="/usr/local/opt/llvm@7/bin/llvm-config"
fi
[ -x "$llvm_config" ] && export LLVM_CONFIG="$llvm_config"
unset -v llvm_config
