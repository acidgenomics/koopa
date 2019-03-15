# Install gsl
# This is required for some single-cell RNA-seq R packages.

PREFIX="/usr/local"
VERSION="2.5"

wget "http://mirror.keystealth.org/gnu/gsl/gsl-${VERSION}.tar.gz"
tar xzvf "gsl-${VERSION}.tar.gz"
cd "gsl-${VERSION}"

./configure --prefix="$PREFIX"

make
make check
sudo make install

# Inspect /usr/local/gsl
