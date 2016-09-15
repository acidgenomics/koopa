wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
conda update conda
conda config --add channels r
conda config --add channels bioconda
conda install salmon
conda update salmon
