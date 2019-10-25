#!/bin/sh

llvm_config="${LLVM_CONFIG:-llvm-config}"
"$llvm_config" --version
