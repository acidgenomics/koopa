if [[ -d "$HOME/bin" ]]; then
    export PATH="$HOME/bin:$PATH"
fi

if [[ -d "$HOME/lib" ]]; then
    export LD_LIBRARY_PATH="$HOME/lib:$LD_LIBRARY_PATH"
fi
