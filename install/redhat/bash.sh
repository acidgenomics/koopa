# Bash
# https://www.gnu.org/software/bash/

build_dir="/tmp/bash"
prefix="/usr/local"
version="5.0"

sudo yum install -y yum-utils
sudo yum-builddep -y bash

(
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    cd "$build_dir"
    wget http://ftpmirror.gnu.org/bash/bash-${version}.tar.gz
    tar -xzvf "bash-${version}"
    ./configure --build="x86_64-redhat-linux-gnu" --prefix="$prefix"
    make
    make test
    sudo make install
    rm -rf "$build_dir"
)

# Consider adding a check in /etc/shells.
# grep "${prefix}/bin/bash" /etc/shells
# And then if there's no match, append the file automatically.

echo "Updating default shell."
chsh -s /usr/local/bin/bash

cat << EOF
bash installed successfully.
Reload the shell and check version.
command -v bash
bash --version
EOF
