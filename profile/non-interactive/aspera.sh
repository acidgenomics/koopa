# Aspera Connect
if [[ -z "$ASPERA_DIR" ]]; then
    aspera_dir="${HOME}/.aspera/connect/bin"
    if [[ -d "$aspera_dir" ]]; then
        export ASPERA_DIR="$aspera_dir"
    fi
    unset -v aspera_dir
fi
if [[ -d "$ASPERA_DIR" ]]; then
    export PATH="${ASPERA_DIR}:${PATH}"
fi
