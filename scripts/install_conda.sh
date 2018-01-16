# https://bioconda.github.io/
# Python 3 version

if [[ $(uname -s) = "Linux" ]]; then
    # Linux
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
elif [[ $(uname -s) = "Darwin" ]]; then
    # macOS
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
else
    echo "$(uname -s) operating system not supported"
    exit 1
fi

bash Miniconda3-latest-*-x86_64.sh

echo "conda install succeeded. Shell must be reloaded."
exit 1
