# Installation

## Requirements

- Linux (x86_64 or arm64) or macOS (Apple Silicon / arm64 only). Intel Macs (x86_64)
  are no longer supported. On Windows, consider using
  [Ubuntu for WSL](https://ubuntu.com/wsl/). [BusyBox](https://busybox.net/) is not
  supported.
- [POSIX](https://en.wikipedia.org/wiki/POSIX)-compliant login shell (bash, zsh, dash,
  ksh93), fish, elvish, nushell, or powershell. csh and tcsh have minimal support
  (`PATH` and environment variables only).
- [Python](https://www.python.org/) 3.12, which will be bootstrap installed into
  `~/.local/share/koopa-bootstrap` automatically when necessary.
- Core utilities: `curl`, `git`, `grep`, `mkdir`, `mktemp`, `rm`, `sed`, `tar`.

### macOS

Xcode Command Line Tools are required.

```sh
xcode-select --install
```

The command line tools will install into `/Library/Developer/CommandLineTools`.

### Debian / Ubuntu

```sh
if [ "$(id -u)" -eq 0 ]
then
    apt-get update
    apt-get --quiet --yes install sudo
fi
sudo apt-get update
sudo apt-get \
    --no-install-recommends \
    --quiet \
    --yes \
    install \
        bash \
        build-essential \
        ca-certificates \
        coreutils \
        curl \
        findutils \
        git \
        locales \
        lsb-release \
        procps \
        python3 \
        unzip
```

### Fedora / RHEL

```sh
if [ "$(id -u)" -eq 0 ]
then
    dnf -y install sudo
fi
sudo dnf -y install \
    automake \
    bash \
    coreutils \
    curl \
    findutils \
    gcc \
    git \
    make \
    procps \
    python3 \
    unzip
```

## Install koopa

The install script will prompt to determine whether you want a shared install for all
users, or for the current local user only. It will also ask about dotfile
configuration and whether your shell profile configuration file should be modified.

```sh
sh -c "$(curl -LSs https://koopa.acidgenomics.com/install)"
```

Alternatively, download the install script as a temporary file and then execute.

```sh
install="$(mktemp)"
curl -LSs -o "$install" https://koopa.acidgenomics.com/install
chmod +x "$install"
"$install"
```

Here's how to install koopa non-interactively, which is intended primarily for
building [Docker](https://www.docker.com/) images.

```sh
curl -LSs https://koopa.acidgenomics.com/install \
    | sh -s -- --non-interactive
```
