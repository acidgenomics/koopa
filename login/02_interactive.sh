# Load interactive profile scripts
if [[ -n "$PS1" ]]; then
    for file in $(find "$SEQCLOUD_DIR"/profile/interactive \
        -type f -name "*.sh" ! -name ".*" | sort); do
        . "$file"
    done
    unset -v file
fi

# Alternate early return
# [[ -z "$PS1" ]] && return
