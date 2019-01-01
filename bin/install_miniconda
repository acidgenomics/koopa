#!/usr/bin/env bash
set -Eeuo pipefail

# Install Miniconda
# https://conda.io/miniconda.html

if [[ "$OSTYPE" == "linux-gnu" ]]
then
    script="Miniconda3-latest-Linux-x86_64.sh"
elif [[ "$OSTYPE" == "darwin"* ]]
then
    script="Miniconda3-latest-MacOSX-x86_64.sh"
else
    echo "${OSTYPE} operating system not supported"
    exit 1
fi

echo "Downloading Miniconda installer..."
curl -O "https://repo.continuum.io/miniconda/${script}"

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
