# https://bioconda.github.io/
# Python 3 version

# Linux
if [[ $(uname -s) = "Linux" ]]; then
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
# macOS
elif [[ $(uname -s) = "Darwin" ]]; then
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
else
    echo "$(uname -s) operating system not supported"
    exit 1
fi

bash Miniconda3-*.sh
rm Miniconda3-*.sh

conda config --add channels conda-forge
conda config --add channels defaults
conda config --add channels r
conda config --add channels bioconda
conda update conda
