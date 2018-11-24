# HPC functions.
if [[ -n ${HPC_SCHEDULER+x} ]]; then
    for file in "${KOOPA_SYS_DIR}/functions/hpc/"*; do
        source "$file"
    done
    unset -v file
fi
