# https://www.anaconda.com/download

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    script="Anaconda3-5.2.0-Linux-x86_64.sh"
    wget https://repo.anaconda.com/archive/
elif [[ "$OSTYPE" == "darwin"* ]]; then
    script="Anaconda3-5.2.0-MacOSX-x86_64.sh"
else
    echo "${OSTYPE} operating system not supported"
    return 1
fi

echo "Downloading Anaconda installer..."
wget "https://repo.anaconda.com/archive/${script}"

cat << EOF
koopa is able to load conda automatically.
Don't allow conda to modify bashrc.
Instead, export "CONDA_DIR" in bashrc to point to the conda "bin" directory.
This must be included prior to sourcing koopa.
EOF

bash "$script"

cat << EOF
conda installed successfully.
Export "CONDA_DIR" in bashrc and reload the shell.
Use "which conda" to check the path.
EOF
