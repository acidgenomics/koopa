# Export PATH environment variable
# Don't re-export inside interactive session
if [[ -z "$INTERACTIVE_QUEUE" ]]; then
    . "${KOOPA_DIR}/profile/path.sh"
fi
