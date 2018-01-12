if [[ "$SEQCLOUD_PATH" != false ]]; then
    for file in $(find "$SEQCLOUD_DIR"/profile/path \
        -type f -name "*.sh" ! -name ".*" | sort); do
        . "$file"
    done
    unset -v file
fi
