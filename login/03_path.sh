# Export PATH environment variable
# Don't re-export inside interactive session
if [[ -z "$INTERACTIVE_QUEUE" ]]; then
    . "${SEQCLOUD_DIR}/profile/path.sh"
fi
