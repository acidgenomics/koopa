#!/usr/bin/env bash
set -Eeuxo pipefail

# Install Anaconda
# https://www.anaconda.com/download
# https://docs.anaconda.com/anaconda/install/

VERSION="5.3.0"

if [[ "$OSTYPE" == "linux-gnu" ]]
then
    script="Anaconda3-${VERSION}-Linux-x86_64.sh"
elif [[ "$OSTYPE" == "darwin"* ]]
then
    script="Anaconda3-${VERSION}-MacOSX-x86_64.sh"
else
    echo "${OSTYPE} operating system not supported"
    exit 1
fi

echo "Downloading Anaconda installer..."
curl -O "https://repo.anaconda.com/archive/${script}"

cat << EOF
koopa is able to load conda automatically.
Don't allow conda to modify bashrc.
Instead, export "CONDA_EXE" in bashrc to point to the conda binary.
This must be included prior to sourcing koopa.
EOF

bash "$script"

cat << EOF

conda installed successfully.
Export "CONDA_EXE" in bashrc and reload the shell.
Use "which conda" to check the path.
EOF
