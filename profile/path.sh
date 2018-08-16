# conda
if [[ -n "$CONDA_VERSION" ]]; then
    if echo "$CONDA_VERSION" | grep -q "conda 4.3"; then
        export PATH="${CONDA_DIR}/bin:${PATH}"
    fi
fi

# User specific environment and startup programs
# ~/.local/bin
if [[ -d "${HOME}/.local/bin" ]]; then
    export PATH="${PATH}:${HOME}/.local/bin"
fi
# ~/bin
if [[ -d "${HOME}/.local/bin" ]]; then
    export PATH="${PATH}:${HOME}/bin"
fi
