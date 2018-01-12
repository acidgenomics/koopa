aspera_dir="$HOME/.aspera/connect/bin"
if [[ -d $aspera_dir ]]; then
    export ASPERA_DIR="$aspera_dir"
    export PATH="$ASPERA_DIR:$PATH"
fi
unset -v aspera_dir
