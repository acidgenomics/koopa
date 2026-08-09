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

## Offline / pinned install (restricted networks)

The install script above fetches and executes code from
`koopa.acidgenomics.com` in one step. On a corporate build that requires every
artifact to be reviewed and sourced from an approved host before it runs,
install from a pinned release tarball instead.

**What this secures:** ingress. The artifact is pinned to a specific tag (an
immutable commit, not a moving branch), mirrorable through an internal proxy,
and reviewable before it ever runs, unlike `curl | sh`, which fetches and
executes in the same step.

**What this does not secure:** the ~500 third-party apps koopa can install
(compilers, language runtimes, CLI tools). Those are downloaded and, in many
cases, compiled at `koopa install` time from their own upstream hosts. Use the
[internal mirror](#internal-mirror-restricted-networks) below, with
`pull_priority` set to `"vendor_only"`, to route those through the same
review gate.

```sh
# Fetch a specific tagged release (or pull the same tarball from an internal
# mirror that proxies GitHub tag archives). GitHub's codeload URLs are
# content-addressed by tag, so re-fetching the same tag always returns the
# same bytes -- this is what makes the artifact reviewable ahead of use.
version=0.25.0
curl -LSs -o "koopa-${version}.tar.gz" \
    "https://github.com/acidgenomics/koopa/archive/refs/tags/v${version}.tar.gz"

# Extract into the standard koopa data directory.
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
mkdir -p "$data_home"
tar -xzf "koopa-${version}.tar.gz" -C "$data_home"
mv "${data_home}/koopa-${version}" "${data_home}/koopa"

# Activate, e.g. by adding this line to the shell profile.
. "${data_home}/koopa/activate.sh"
```

This is a pinned, non-git release: `koopa install`/`uninstall`/`configure`
work normally against it, but `koopa update` recognizes the tree as a pinned
release and reports as much instead of attempting a `git pull`. To update,
fetch and extract the next tagged release the same way.

The first `koopa` invocation needs a Python 3.12 interpreter to run its own
CLI. It looks for one at `/usr/bin/python3` first; if that isn't exactly
3.12, it runs `bootstrap.sh`, which downloads a Python 3.12 build directly
from `python.org` or `koopa.acidgenomics.com/src` into
`~/.local/share/koopa-bootstrap`. `bootstrap.sh` does not consult the
internal mirror described below, so on a `vendor_only` network this
download will fail. Install a system Python 3.12 at `/usr/bin/python3`
before activating koopa on such a network; there is currently no way to
route the bootstrap download itself through the mirror.

## Internal mirror (restricted networks)

Installing apps normally downloads source tarballs and prebuilt binaries from
upstream hosts (GitHub, GNU/Savannah mirrors, `koopa.acidgenomics.com/src`, and
similar) directly. On a network that restricts outbound traffic to an approved
allowlist, or where every artifact must be reviewed before it reaches a host,
route these downloads through an internal mirror instead: a JFrog Artifactory
repository or an S3 bucket that you control and populate.

Copy the example config and edit it in place:

```sh
cp etc/koopa/vendor.json.example etc/koopa/vendor.json
```

```json
{
  "enabled": true,
  "backend": "artifactory",
  "artifactory": {
    "base_url": "https://artifacts.example.com",
    "src_repo": "generic-team-koopa-src",
    "binary_repo": "generic-team-koopa-binaries",
    "token_env_var": "JFROG_ACCESS_TOKEN"
  },
  "pull_priority": "vendor_only"
}
```

Fields:

- `backend`: `"artifactory"` or `"s3"`. Only one backend section (`artifactory`
  or `s3`) is read, matching `backend`.
- `artifactory.token_env_var`: the name of an environment variable holding a
  Bearer token, read at request time. Never put the token itself in
  `vendor.json` — anonymous read access needs no token at all.
- `s3.profile`: a named AWS CLI profile used for `aws s3 cp` /
  `aws s3api head-object` calls. Requires the `aws` CLI on `PATH`.
- `pull_priority`: `"vendor_first"` (the default) tries the mirror before
  falling back to the public host, useful while the mirror is still being
  populated. `"vendor_only"` never contacts a public host: only the mirror is
  tried, and the install fails outright if an artifact is missing from it —
  this is what a genuinely airgapped or allowlisted network needs.

`vendor.json` is read from `etc/koopa/vendor.json` relative to the koopa
prefix and is gitignored; it is not something you commit alongside the koopa
checkout. Populating the mirror with the app versions your team needs is an
operational task outside koopa itself — `koopa develop push-app-build <name>`
uploads a locally built app to the configured backend once credentials are
present.

If you are behind a corporate proxy rather than (or in addition to) a vendor
mirror, see [Troubleshooting](troubleshooting.md) for the `http_proxy`
variable koopa and its bootstrap dependencies honor.
