# HPC functions.
if [[ -n ${HPC_SCHEDULER+x} ]]; then
    for file in "${KOOPA_BASE_DIR}/functions/hpc/"*; do
        source "$file"
    done
    unset -v file
fi
