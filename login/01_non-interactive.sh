# Load non-interactive profile scripts
for file in $(find "$SEQCLOUD_DIR"/profile/non-interactive \
    -type f -name "*.sh" ! -name ".*" | sort); do
    . "$file"
done
unset -v file

# Export PATH environment variable
. "$SEQCLOUD_DIR"/profile/path.sh
