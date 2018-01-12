# Profile settings
. "$SEQCLOUD_DIR"/profile/general.sh
if [[ "$SEQCLOUD_CONSOLE" != false ]]; then
    for file in $(find "$SEQCLOUD_DIR"/profile/console \
        -type f -name "*.sh" ! -name ".*" | sort); do
        . "$file"
    done
    unset -v file
fi
