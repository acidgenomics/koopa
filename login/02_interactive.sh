# Load interactive profile scripts
if [[ -n "$PS1" ]]; then
    where="${SEQCLOUD_DIR}/profile/interactive"
    for file in $(find "$where" -type f -name "*.sh" | sort); do
        . "$file"
    done
    unset -v file where
fi
