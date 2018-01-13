# Load non-interactive profile scripts
for file in $(find "$SEQCLOUD_DIR"/profile/non-interactive \
    -type f -name "*.sh" ! -name ".*" | sort); do
    . "$file"
done
unset -v file

# Export PATH environment variable
# Don't re-export for interactive queue process
if [[ -z "$INTERACTIVE_QUEUE" ]]; then
    . "$SEQCLOUD_DIR"/profile/path.sh
fi
