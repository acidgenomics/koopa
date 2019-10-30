#!/bin/sh



# LLVM                                                                      {{{1
# ==============================================================================

# Note that LLVM 7+ is now required to install umap-learn.
if _koopa_is_rhel7 && [ -x "/usr/bin/llvm-config-7.0-64" ]
then
    export LLVM_CONFIG="/usr/bin/llvm-config-7.0-64"
fi

