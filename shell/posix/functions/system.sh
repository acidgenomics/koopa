#!/bin/sh
# shellcheck disable=SC2039

koopa::_id() { # {{{1
    # """
    # Return ID string.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    local x
    x="$(id "$@")"
    koopa::print "$x"
    return 0
}

koopa::cd() { # {{{1
    # """
    # Change directory quietly.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args_eq "$#" 1
    cd "${1:?}" >/dev/null || return 1
    return 0
}

koopa::cd_tmp_dir() { # {{{1
    # """
    # Prepare and navigate (cd) to temporary directory.
    # @note Updated 2020-06-30.
    #
    # Used primarily for cellar build scripts.
    # """
    koopa::assert_has_args_le "$#" 1
    local dir
    dir="${1:-$(koopa::tmp_dir)}"
    rm -fr "$dir"
    mkdir -p "$dir"
    koopa::cd "$dir"
    return 0
}

koopa::check_system() { # {{{1
    # """
    # Check system.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed Rscript
    local koopa_prefix
    koopa_prefix="$(koopa::prefix)"
    export KOOPA_FORCE=1
    set +u
    # shellcheck disable=SC1090
    source "${koopa_prefix}/activate"
    set -u
    Rscript --vanilla "$(koopa::include_prefix)/check-system.R"
    koopa::disk_check
    return 0
}

koopa::cp() { # {{{1
    # """
    # Hardened version of coreutils copy.
    # @note Updated 2020-07-04.
    #
    # getopts info:
    # - http://mywiki.wooledge.org/BashFAQ/035#getopts
    # - https://wiki.bash-hackers.org/howto/getopts_tutorial
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_installed cp
    local OPTIND target_dir
    target_dir=
    OPTIND=1
    while getopts 't:' opt
    do
        case "$opt" in
            t)
                target_dir="$OPTARG"
                ;;
            \?)
                koopa::stop "Invalid option: -${OPTARG}"
            ;;
        esac
    done
    shift "$((OPTIND-1))"
    if [ -n "$target_dir" ]
    then
        koopa::assert_is_existing "$@"
        koopa::mkdir "$target_dir"
        cp -af -t "$target_dir" "$@"
    else
        koopa::assert_has_args_eq "$#" 2
        source_file="${1:?}"
        koopa::assert_is_existing "$source_file"
        target_file="${2:?}"
        [ -e "$target_file" ] && koopa::rm "$target_file"
        koopa::mkdir "$(dirname "$target_file")"
        cp -af "$source_file" "$target_file"
    fi
    return 0
}

koopa::cpu_count() { # {{{1
    # """
    # Return a usable number of CPU cores.
    # @note Updated 2020-06-30.
    #
    # Dynamically assigns 'n-1' or 'n-2' depending on the machine power.
    # """
    koopa::assert_has_no_args "$#"
    local n
    if koopa::is_installed nproc
    then
        n="$(nproc)"
    elif koopa::is_macos
    then
        n="$(sysctl -n hw.ncpu)"
    elif koopa::is_linux
    then
        n="$(getconf _NPROCESSORS_ONLN)"
    else
        # Otherwise assume single threaded.
        n=1
    fi
    # Subtract some cores for login use on powerful machines.
    if [ "$n" -ge 17 ]
    then
        # For 17+ cores, use 'n-2'.
        n=$((n - 2))
    elif [ "$n" -ge 5 ] && [ "$n" -le 16 ]
    then
        # For 5-16 cores, use 'n-1'.
        n=$((n - 1))
    fi
    koopa::print "$n"
    return 0
}

koopa::date() { # {{{1
    # """
    # Koopa date.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::variable "koopa-date"
    return 0
}

koopa::datetime() { # {{{
    # """
    # Datetime string.
    # @note Updated 2020-07-04.
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed date
    local x
    x="$(date "+%Y%m%d-%H%M%S")"
    koopa::print "$x"
    return 0
}

koopa::dotfiles_config_link() { # {{{1
    # """
    # Dotfiles directory.
    # @note Updated 2019-11-04.
    #
    # Note that we're not checking for existence here, which is handled inside
    # 'link-dotfile' script automatically instead.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::config_prefix)/dotfiles"
    return 0
}

koopa::dotfiles_private_config_link() { # {{{1
    # """
    # Private dotfiles directory.
    # @note Updated 2019-11-04.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::dotfiles_config_link)-private"
    return 0
}

koopa::download() { # {{{1
    # """
    # Download a file.
    # @note Updated 2020-06-30.
    #
    # Potentially useful curl flags:
    # * --connect-timeout <seconds>
    # * --silent
    # * --stderr
    # * --verbose
    #
    # Note that '--fail-early' flag is useful, but not supported on old versions
    # of curl (e.g. 7.29.0; RHEL 7).
    #
    # Alternatively, can use wget instead of curl:
    # > wget -O file url
    # > wget -q -O - url (piped to stdout)
    # > wget -qO-
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_installed curl
    local bn file url wd
    url="${1:?}"
    file="${2:-}"
    if [ -z "$file" ]
    then
        wd="$(pwd)"
        bn="$(basename "$url")"
        file="${wd}/${bn}"
    fi
    file="$(realpath "$file")"
    koopa::info "Downloading '${url}' to '${file}'."
    curl \
        --create-dirs \
        --fail \
        --location \
        --output "$file" \
        --progress-bar \
        --retry 5 \
        --show-error \
        "$url"
    return 0
}

koopa::expr() { # {{{1
    # """
    # Quiet regular expression matching that is POSIX compliant.
    # @note Updated 2020-06-30.
    #
    # Avoid using '[[ =~ ]]' in sh config files.
    # 'expr' is faster than using 'case'.
    #
    # See also:
    # - https://stackoverflow.com/questions/21115121
    # """
    koopa::assert_has_args_eq "$#" 2
    expr "${1:?}" : "${2:?}" 1>/dev/null
}

koopa::extract() { # {{{1
    # """
    # Extract compressed files automatically.
    # @note Updated 2020-06-30.
    #
    # As suggested by Mendel Cooper in "Advanced Bash Scripting Guide".
    #
    # See also:
    # - https://github.com/stephenturner/oneliners
    # """
    koopa::assert_has_args "$#"
    local file
    for file in "$@"
    do
        koopa::assert_is_file "$file"
        file="$(realpath "$file")"
        koopa::info "Extracting '${file}'."
        case "$file" in
            *.tar.bz2)
                tar -xj -f "$file"
                ;;
            *.tar.gz)
                tar -xz -f "$file"
                ;;
            *.tar.xz)
                tar -xJ -f "$file"
                ;;
            *.bz2)
                koopa::assert_is_installed bunzip2
                bunzip2 "$file"
                ;;
            *.gz)
                gunzip "$file"
                ;;
            *.rar)
                koopa::assert_is_installed unrar
                unrar -x "$file"
                ;;
            *.tar)
                tar -x -f "$file"
                ;;
            *.tbz2)
                tar -xj -f "$file"
                ;;
            *.tgz)
                tar -xz -f "$file"
                ;;
            *.xz)
                koopa::assert_is_installed xz
                xz --decompress "$file"
                ;;
            *.zip)
                koopa::assert_is_installed unzip
                unzip -qq "$file"
                ;;
            *.Z)
                uncompress "$file"
                ;;
            *.7z)
                koopa::assert_is_installed 7z
                7z -x "$file"
                ;;
            *)
                koopa::stop "Unsupported extension: '${file}'."
                ;;
        esac
    done
    return 0
}

koopa::find_local_bin_dirs() { # {{{1
    # """
    # Find local bin directories.
    # @note Updated 2020-06-30.
    #
    # Should we exclude koopa from this search?
    #
    # See also:
    # - https://stackoverflow.com/questions/23356779
    # - https://stackoverflow.com/questions/7442417
    # """
    koopa::assert_has_no_args "$#"
    local prefix
    prefix="$(koopa::make_prefix)"
    local x
    x="$( \
        find "$prefix" \
            -mindepth 2 \
            -maxdepth 3 \
            -type d \
            -name "bin" \
            -not -path "*/Caskroom/*" \
            -not -path "*/Cellar/*" \
            -not -path "*/Homebrew/*" \
            -not -path "*/anaconda3/*" \
            -not -path "*/bcbio/*" \
            -not -path "*/conda/*" \
            -not -path "*/lib/*" \
            -not -path "*/miniconda3/*" \
            -not -path "*/opt/*" \
            -print | sort \
    )"
    koopa::print "$x"
    return 0
}

koopa::fix_sudo_setrlimit_error() { # {{{1
    # """
    # Fix bug in recent version of sudo.
    # @note Updated 2020-06-30.
    #
    # This is popping up on Docker builds:
    # sudo: setrlimit(RLIMIT_CORE): Operation not permitted
    #
    # @seealso
    # - https://ask.fedoraproject.org/t/
    #       sudo-setrlimit-rlimit-core-operation-not-permitted/4223
    # - https://bugzilla.redhat.com/show_bug.cgi?id=1773148
    # """
    koopa::assert_has_no_args "$#"
    local target_file
    target_file="/etc/sudo.conf"
    # Ensure we always overwrite for Docker images.
    # Note that Fedora base image contains this file by default.
    if ! koopa::is_docker
    then
        [ -e "$target_file" ] && return 0
    fi
    local source_file
    source_file="$(koopa::prefix)/os/linux/etc/sudo.conf"
    sudo cp -v "$source_file" "$target_file"
    return 0
}

koopa::github_url() { # {{{1
    # """
    # Koopa GitHub URL.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::variable "koopa-github-url"
    return 0
}

koopa::gnu_mirror() { # {{{1
    # """
    # Get GNU FTP mirror URL.
    # @note Updated 2020-04-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::variable "gnu-mirror"
    return 0
}

koopa::group() { # {{{1
    # """
    # Current user's default group.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::_id -gn
    return 0
}

koopa::group_id() { # {{{1
    # """
    # Current user's default group ID.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::_id -g
    return 0
}

koopa::header() { # {{{1
    # """
    # Source script header.
    # @note Updated 2020-06-30.
    #
    # Useful for private scripts using koopa code outside of package.
    # """
    koopa::assert_has_args_eq "$#" 1
    local file header_type koopa_prefix
    header_type="${1:?}"
    koopa_prefix="$(koopa::prefix)"
    case "$header_type" in
        # shell ----------------------------------------------------------------
        bash)
            file="${koopa_prefix}/shell/bash/include/header.sh"
            ;;
        zsh)
            file="${koopa_prefix}/shell/zsh/include/header.sh"
            ;;
        # os -------------------------------------------------------------------
        amzn)
            file="${koopa_prefix}/os/amzn/include/header.sh"
            ;;
        centos)
            file="${koopa_prefix}/os/centos/include/header.sh"
            ;;
        darwin)
            file="${koopa_prefix}/os/darwin/include/header.sh"
            ;;
        debian)
            file="${koopa_prefix}/os/debian/include/header.sh"
            ;;
        fedora)
            file="${koopa_prefix}/os/fedora/include/header.sh"
            ;;
        linux)
            file="${koopa_prefix}/os/linux/include/header.sh"
            ;;
        macos)
            file="${koopa_prefix}/os/macos/include/header.sh"
            ;;
        rhel)
            file="${koopa_prefix}/os/rhel/include/header.sh"
            ;;
        ubuntu)
            file="${koopa_prefix}/os/ubuntu/include/header.sh"
            ;;
        # host -----------------------------------------------------------------
        aws)
            file="${koopa_prefix}/host/aws/include/header.sh"
            ;;
        azure)
            file="${koopa_prefix}/host/azure/include/header.sh"
            ;;
        *)
            koopa::invalid_arg "$1"
            ;;
    esac
    koopa::print "$file"
    return 0
}

koopa::hostname() { # {{{1
    # """
    # Host name.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed uname
    local x
    x="$(uname -n)"
    x="${x//.*/}"
    koopa::print "$x"
    return 0
}

koopa::host_id() { # {{{1
    # """
    # Simple host ID string to load up host-specific scripts.
    # @note Updated 2020-06-30.
    #
    # Currently intended to support AWS, Azure, and Harvard clusters.
    #
    # Returns useful host type matching either:
    # - VMs: "aws", "azure".
    # - HPCs: "harvard-o2", "harvard-odyssey".
    #
    # Returns empty for local machines and/or unsupported types.
    #
    # Alternatively, can use 'hostname -d' for reverse lookups.
    # """
    local id
    if [ -r /etc/hostname ]
    then
        id="$(cat /etc/hostname)"
    else
        koopa::assert_is_installed hostname
        id="$(hostname -f)"
    fi
    case "$id" in
        # VMs {{{2
        # ----------------------------------------------------------------------
        *.ec2.internal)
            id="aws"
            ;;
        awslab*)
            id="aws"
            ;;
        azlab*)
            id="azure"
            ;;
        # HPCs {{{2
        # ----------------------------------------------------------------------
        *.o2.rc.hms.harvard.edu)
            id="harvard-o2"
            ;;
        *.rc.fas.harvard.edu)
            id="harvard-odyssey"
            ;;
    esac
    koopa::print "$id"
    return 0
}

koopa::list() { # {{{1
    # """
    # List exported koopa scripts.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed Rscript
    Rscript --vanilla "$(koopa::include_prefix)/list.R"
    return 0
}

koopa::ln() { # {{{1
    # """
    # Create a symlink quietly.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_args_eq "$#" 2
    koopa::assert_is_installed ln
    local source_file target_file
    source_file="${1:?}"
    target_file="${2:?}"
    koopa::rm "$target_file"
    ln -fns "$source_file" "$target_file"
    return 0
}

koopa::local_ip_address() { # {{{1
    # """
    # Local IP address.
    # @note Updated 2020-06-18.
    #
    # Some systems (e.g. macOS) will return multiple IP address matches for
    # Ethernet and WiFi. Here we're simplying returning the first match, which
    # corresponds to the default on macOS.
    # """
    koopa::assert_has_no_args "$#"
    local x
    if koopa::is_macos
    then
        x="$( \
            ifconfig \
            | grep "inet " \
            | grep "broadcast" \
            | awk '{print $2}' \
            | tail -n 1
        )"
    else
        x="$( \
            hostname -I \
            | awk '{print $1}' \
            | head -n 1
        )"
    fi
    [ -n "$x" ] || return 1
    koopa::print "$x"
    return 0
}

koopa::make_build_string() { # {{{1
    # """
    # OS build string for 'make' configuration.
    # @note Updated 2020-03-04.
    #
    # Use this for 'configure --build' flag.
    #
    # - macOS: x86_64-darwin15.6.0
    # - Linux: x86_64-linux-gnu
    # """
    koopa::assert_has_no_args "$#"
    local mach os_type string
    if koopa::is_macos
    then
        mach="$(uname -m)"
        os_type="${OSTYPE:?}"
        string="${mach}-${os_type}"
    else
        string="x86_64-linux-gnu"
    fi
    koopa::print "$string"
    return 0
}

koopa::mktemp() { # {{{1
    # """
    # Wrapper function for system 'mktemp'.
    # @note Updated 2020-07-04.
    #
    # Traditionally, many shell scripts take the name of the program with the
    # pid as a suffix and use that as a temporary file name. This kind of
    # naming scheme is predictable and the race condition it creates is easy for
    # an attacker to win. A safer, though still inferior, approach is to make a
    # temporary directory using the same naming scheme. While this does allow
    # one to guarantee that a temporary file will not be subverted, it still
    # allows a simple denial of service attack. For these reasons it is
    # suggested that mktemp be used instead.
    #
    # Note that old version of mktemp (e.g. macOS) only supports '-t' instead of
    # '--tmpdir' flag for prefix.
    #
    # See also:
    # - https://stackoverflow.com/questions/4632028
    # - https://stackoverflow.com/a/10983009/3911732
    # - https://gist.github.com/earthgecko/3089509
    # """
    koopa::assert_is_installed mktemp
    local date_id template user_id
    user_id="$(koopa::user_id)"
    date_id="$(koopa::datetime)"
    template="koopa-${user_id}-${date_id}-XXXXXXXXXX"
    mktemp "$@" -t "$template"
    return 0
}

koopa::mkdir() { # {{{1
    # """
    # Create directories with parents automatically.
    # @note Updated 2020-07-04.
    koopa::assert_has_args "$#"
    mkdir -pv "$@"
    return 0
}

koopa::mv() { # {{{1
    # """
    # Move a file or directory.
    # @note Updated 2020-07-04.
    #
    # This function works on 1 file or directory at a time.
    # It ensures that the target parent directory exists automatically.
    #
    # Useful GNU cp flags, for reference (non-POSIX):
    # - -T: no-target-directory
    # - --strip-trailing-slashes
    # """
    koopa::assert_has_args_eq "$#" 2
    local source_file target_file
    source_file="$(koopa::strip_trailing_slash "${1:?}")"
    koopa::assert_is_existing "$source_file"
    target_file="$(koopa::strip_trailing_slash "${2:?}")"
    [ -e "$target_file" ] && koopa::rm "$target_file"
    koopa::mkdir "$(dirname "$target_file")"
    mv -f "$source_file" "$target_file"
    return 0
}

koopa::os_codename() { # {{{1
    # """
    # Operating system code name.
    # @note Updated 2020-06-30.
    #
    # Alternate approach:
    # > awk -F= '$1=="VERSION_CODENAME" { print $2 ;}' /etc/os-release \
    # >     | tr -d '"'
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_debian
    koopa::assert_is_installed lsb_release
    local os_codename
    if koopa::is_kali
    then
        os_codename="buster"
    else
        os_codename="$(lsb_release -cs)"
    fi
    koopa::print "$os_codename"
    return 0
}

koopa::os_id() { # {{{1
    # """
    # Operating system ID.
    # @note Updated 2020-06-30.
    #
    # Just return the OS platform ID (e.g. "debian").
    # """
    koopa::assert_has_no_args "$#"
    local os_id
    if koopa::is_kali
    then
        os_id="debian"
    else
        os_id="$(koopa::os_string | cut -d '-' -f 1)"
    fi
    koopa::print "$os_id"
    return 0
}

koopa::os_string() { # {{{1
    # """
    # Operating system string.
    # @note Updated 2020-06-30.
    #
    # Returns 'ID' and major 'VERSION_ID' separated by a '-'.
    #
    # Always returns lowercase, with unique names for Linux distros
    # (e.g. "rhel-8").
    #
    # Alternatively, use hostnamectl.
    # https://linuxize.com/post/how-to-check-linux-version/
    koopa::assert_has_no_args "$#"
    local id string version
    if koopa::is_macos
    then
        # > id="$(uname -s | tr '[:upper:]' '[:lower:]')"
        id="macos"
        version="$(koopa::get_version "$id")"
        version="$(koopa::major_minor_version "$version")"
    elif koopa::is_linux
    then
        if [ -r /etc/os-release ]
        then
            id="$( \
                awk -F= '$1=="ID" { print $2 ;}' /etc/os-release \
                | tr -d '"' \
            )"
            # Include the major release version.
            version="$( \
                awk -F= '$1=="VERSION_ID" { print $2 ;}' /etc/os-release \
                | tr -d '"'
            )"
            if [ -n "$version" ]
            then
                version="$(koopa::major_version "$version")"
            else
                # This is the case for Arch Linux.
                version="rolling"
            fi
        else
            id="linux"
        fi
    fi
    if [ -z "$id" ]
    then
        koopa::stop "Failed to detect OS ID."
    fi
    string="$id"
    if [ -n "${version:-}" ]
    then
        string="${string}-${version}"
    fi
    koopa::print "$string"
    return 0
}

koopa::pager() {
    # """
    # Run less with support for colors (escape characters).
    # @note Updated 2020-07-03.
    #
    # Detail on handling escape sequences:
    # https://major.io/2013/05/21/
    #     handling-terminal-color-escape-sequences-in-less/
    # """
    local pager
    pager="${PAGER:-less}"
    koopa::assert_is_installed "$pager"
    "$pager" -R "$@"
    return 0
}

koopa::public_ip_address() { # {{{1
    # """
    # Public (remote) IP address.
    # @note Updated 2020-06-18.
    #
    # @seealso
    # https://www.cyberciti.biz/faq/
    #     how-to-find-my-public-ip-address-from-command-line-on-a-linux/
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed dig
    local x
    x="$(dig +short myip.opendns.com @resolver1.opendns.com)"
    # Fallback in case dig approach doesn't work.
    if [ -z "$x" ]
    then
        koopa::assert_is_installed curl
        x="$(curl -s ipecho.net/plain)"
    fi
    [ -n "$x" ] || return 1
    koopa::print "$x"
    return 0
}

koopa::python_remove_pycache() { # {{{1
    # """
    # Remove Python '__pycache__/' from site packages.
    # @note Updated 2020-06-30.
    #
    # These directories can create permission issues when attempting to rsync
    # installation across multiple VMs.
    # """
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed find
    local prefix python
    prefix="${1:-}"
    if [ -z "$prefix" ]
    then
        # e.g. /usr/local/cellar/python/3.8.1
        python="$(koopa::which_realpath "python3")"
        prefix="$(realpath "$(dirname "$python")/..")"
    fi
    koopa::info "Removing pycache in '${prefix}'."
    # > find "$prefix" \
    # >     -type d \
    # >     -name "__pycache__" \
    # >     -print0 \
    # >     -exec rm -frv "{}" \;
    find "$prefix" \
        -type d \
        -name "__pycache__" \
        -print0 \
        | xargs -0 -I {} rm -frv "{}"
    return 0
}

koopa::relink() { # {{{1
    # """
    # Re-create a symbolic link dynamically, if broken.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args_eq "$#" 2
    local dest_file source_file
    source_file="${1:?}"
    dest_file="${2:?}"
    # Keep this check relaxed, in case dotfiles haven't been cloned.
    [ -e "$source_file" ] || return 0
    [ -L "$dest_file" ] && return 0
    koopa::rm "$dest_file"
    ln -fns "$source_file" "$dest_file"
    return 0
}

koopa::rm() { # {{{1
    # """
    # Remove files/directories quietly.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    rm -fr "$@" >/dev/null 2>&1
    return 0
}

koopa::rsync_flags() { # {{{1
    # """
    # rsync flags.
    # @note Updated 2020-04-06.
    #
    #     --delete-before         receiver deletes before xfer, not during
    #     --iconv=CONVERT_SPEC    request charset conversion of filenames
    #     --numeric-ids           don't map uid/gid values by user/group name
    #     --partial               keep partially transferred files
    #     --progress              show progress during transfer
    # -A, --acls                  preserve ACLs (implies -p)
    # -H, --hard-links            preserve hard links
    # -L, --copy-links            transform symlink into referent file/dir
    # -O, --omit-dir-times        omit directories from --times
    # -P                          same as --partial --progress
    # -S, --sparse                handle sparse files efficiently
    # -X, --xattrs                preserve extended attributes
    # -a, --archive               archive mode; equals -rlptgoD (no -H,-A,-X)
    # -g, --group                 preserve group
    # -h, --human-readable        output numbers in a human-readable format
    # -n, --dry-run               perform a trial run with no changes made
    # -o, --owner                 preserve owner (super-user only)
    # -r, --recursive             recurse into directories
    # -x, --one-file-system       don't cross filesystem boundaries    
    # -z, --compress              compress file data during the transfer
    #
    # Use '--rsync-path="sudo rsync"' to sync across machines with sudo.
    #
    # See also:
    # - https://unix.stackexchange.com/questions/165423
    # """
    koopa::assert_has_no_args "$#"
    koopa::print "--archive --delete-before --human-readable --progress"
    return 0
}

koopa::run_if_installed() { # {{{1
    # """
    # Run program(s) if installed.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa::is_installed "$arg"
        then
            koopa::note "Skipping '${arg}'."
            continue
        fi
        local exe
        exe="$(koopa::which_realpath "$arg")"
        "$exe"
    done
    return 0
}

koopa::shell() { # {{{1
    # """
    # Current shell.
    # @note Updated 2020-03-28.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3327013
    # """
    koopa::assert_has_no_args "$#"
    local shell
    if [ -n "${BASH_VERSION:-}" ]
    then
        shell="bash"
    elif [ -n "${ZSH_VERSION:-}" ]
    then
        shell="zsh"
    elif [ -d "/proc" ]
    then
        # Standard approach on Linux.
        shell="$(basename "$(readlink /proc/$$/exe)")"
    else
        # This approach works on macOS.
        # The sed step converts '-zsh' to 'zsh', for example.
        # The basename step handles the case when ps returns full path.
        # This can happen inside of editors, such as vim.
        shell="$(basename "$(ps -p "$$" -o 'comm=' | sed 's/^-//g')")"
    fi
    koopa::print "$shell"
    return 0
}

koopa::sys_chgrp() { # {{{1
    # """
    # chgrp with dynamic sudo handling.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_args "$#"
    if koopa::is_shared_install
    then
        sudo chgrp "$@"
    else
        chgrp "$@"
    fi
    return 0
}

koopa::sys_chmod() { # {{{1
    # """
    # chmod with dynamic sudo handling.
    # @note Updated 2020-02-16.
    # """
    koopa::assert_has_args "$#"
    if koopa::is_shared_install
    then
        sudo chmod "$@"
    else
        chmod "$@"
    fi
    return 0
}

koopa::sys_chmod_flags() {
    # """
    # Default recommended flags for chmod.
    # @note Updated 2020-04-16.
    # """
    koopa::assert_has_no_args "$#"
    local flags
    if koopa::is_shared_install
    then
        flags='u+rw,g+rw'
    else
        flags='u+rw,g+r,g-w'
    fi
    koopa::print "$flags"
    return 0
}

koopa::sys_chown() { # {{{1
    # """
    # chown with dynamic sudo handling.
    # @note Updated 2020-02-16.
    # """
    koopa::assert_has_args "$#"
    if koopa::is_shared_install
    then
        sudo chown "$@"
    else
        chown "$@"
    fi
    return 0
}

# FIXME BROKEN
koopa::sys_cp() { # {{{1
    # """
    # Koopa copy.
    # @note Updated 2020-06-30.
    # """
    if koopa::is_shared_install
    then
        sudo -E "$(koopa::cp "$@")"
    else
        koopa::cp "$@"
    fi
    return 0
}

koopa::sys_group() { # {{{1
    # """
    # Return the appropriate group to use with koopa installation.
    # @note Updated 2020-07-04.
    #
    # Returns current user for local install.
    # Dynamically returns the admin group for shared install.
    #
    # Admin group priority: admin (macOS), sudo (Debian), wheel (Fedora).
    # """
    koopa::assert_has_no_args "$#"
    local group
    if koopa::is_shared_install
    then
        group="$(koopa::admin_group)"
    else
        group="$(koopa::group)"
    fi
    koopa::print "$group"
    return 0
}

# FIXME BROKEN
koopa::sys_ln() { # {{{1
    # """
    # Create a symlink quietly.
    # @note Updated 2020-07-04.
    # """
    if koopa::is_shared_install
    then
        sudo -E "$(koopa::ln "$@")"
    else
        koopa::ln "$@"
    fi
    return 0
}

# FIXME BROKEN
koopa::sys_mkdir() { # {{{1
    # """
    # mkdir with dynamic sudo handling.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_args "$#"
    if koopa::is_shared_install
    then
        sudo -E "$(koopa::mkdir "$@")"
    else
        koopa::mkdir "$@"
    fi
    koopa::sys_chmod "$(koopa::sys_chmod_flags)" "$@"
    koopa::sys_chgrp "$(koopa::sys_group)" "$@"
    return 0
}

# FIXME BROKEN
koopa::sys_mv() { # {{{1
    # """
    # Move a file or directory.
    # @note Updated 2020-07-04.
    # """
    if koopa::is_shared_install
    then
        sudo -E "$(koopa::mv "$@")"
    else
        koopa::mv "$@"
    fi
    return 0
}

# FIXME BROKEN
koopa::sys_rm() { # {{{1
    # """
    # Remove files/directories quietly.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    if koopa::is_shared_install
    then
        sudo -E "$(koopa::rm "$@")"
    else
        koopa::rm "$@"
    fi
    return 0
}

koopa::sys_user() { # {{{1
    # """
    # Set the koopa installation system user.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_no_args "$#"
    local user
    if koopa::is_shared_install
    then
        user='root'
    else
        user="$(koopa::user)"
    fi
    koopa::print "$user"
    return 0
}

koopa::test() { # {{{1
    # """
    # Run koopa unit tests.
    # @note Updated 2020-06-26.
    # """
    "$(koopa::tests_prefix)/tests" "$@"
    return 0
}

koopa::test_find_files() { # {{{1
    # """
    # Find relevant files for unit tests.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    local prefix x
    prefix="$(koopa::prefix)"
    x="$( \
        find "$prefix" \
            -mindepth 1 \
            -type f \
            -not -name "$(basename "$0")" \
            -not -name "*.md" \
            -not -name ".pylintrc" \
            -not -path "${prefix}/.git/*" \
            -not -path "${prefix}/cellar/*" \
            -not -path "${prefix}/coverage/*" \
            -not -path "${prefix}/dotfiles/*" \
            -not -path "${prefix}/opt/*" \
            -not -path "${prefix}/tests/*" \
            -not -path "*/etc/R/*" \
            -print | sort \
    )"
    koopa::print "$x"
}

koopa::test_true_color() { # {{{1
    # """
    # Test 24-bit true color support.
    # @note Updated 2020-02-15.
    #
    # @seealso
    # https://jdhao.github.io/2018/10/19/tmux_nvim_true_color/
    # """
    koopa::assert_has_no_args "$#"
    awk 'BEGIN{
        s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
        for (colnum = 0; colnum<77; colnum++) {
            r = 255-(colnum*255/76);
            g = (colnum*510/76);
            b = (colnum*255/76);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(s,colnum+1,1);
        }
        printf "\n";
    }'
    return 0
}

koopa::tmp_dir() { # {{{1
    # """
    # Create temporary directory.
    # @note Updated 2020-02-06.
    # """
    koopa::assert_has_no_args "$#"
    koopa::mktemp -d
    return 0
}

koopa::tmp_file() { # {{{1
    # """
    # Create temporary file.
    # @note Updated 2020-02-06.
    # """
    koopa::assert_has_no_args "$#"
    koopa::mktemp
    return 0
}

koopa::tmp_log_file() { # {{{1
    # """
    # Create temporary log file.
    # @note Updated 2020-02-27.
    #
    # Used primarily for debugging cellar make install scripts.
    #
    # Note that mktemp on macOS and BusyBox doesn't support '--suffix' flag.
    # Otherwise, we can use:
    # > koopa::mktemp --suffix=".log"
    # """
    koopa::assert_has_no_args "$#"
    koopa::tmp_file
    return 0
}

koopa::umask() { # {{{1
    # """
    # Set default file permissions.
    # @note Updated 2020-06-03.
    #
    # - 'umask': Files and directories.
    # - 'fmask': Only files.
    # - 'dmask': Only directories.
    #
    # Use 'umask -S' to return 'u,g,o' values.
    #
    # - 0022: u=rwx,g=rx,o=rx
    #         User can write, others can read. Usually default.
    # - 0002: u=rwx,g=rwx,o=rx
    #         User and group can write, others can read.
    #         Recommended setting in a shared coding environment.
    # - 0077: u=rwx,g=,o=
    #         User alone can read/write. More secure.
    #
    # Access control lists (ACLs) are sometimes preferable to umask.
    #
    # Here's how to use ACLs with setfacl.
    # > setfacl -d -m group:name:rwx /dir
    #
    # @seealso
    # - https://stackoverflow.com/questions/13268796
    # - https://askubuntu.com/questions/44534
    # """
    koopa::assert_has_no_args "$#"
    umask 0002
    return 0
}

koopa::uninstall() { # {{{1
    # """
    # Uninstall koopa.
    # @note Updated 2020-06-24.
    # """
    "$(koopa::prefix)/uninstall" "$@"
    return 0
}

koopa::url() { # {{{1
    # """
    # Koopa URL.
    # @note Updated 2020-04-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::variable "koopa-url"
    return 0
}

koopa::user() { # {{{1
    # """
    # Current user name.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::_id -un
    return 0
}

koopa::user_id() { # {{{1
    # """
    # Current user ID.
    # @note Updated 2020-04-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::_id -u
    return 0
}

koopa::variable() { # {{{1
    # """
    # Get version stored internally in versions.txt file.
    # @note Updated 2020-06-30.
    #
    # This approach handles inline comments.
    # """
    koopa::assert_has_args_eq "$#" 1
    local file key value
    key="${1:?}"
    file="$(koopa::include_prefix)/variables.txt"
    koopa::assert_is_file "$file"
    value="$( \
        grep -Eo "^${key}=\"[^\"]+\"" "$file" \
        || koopa::stop "'${key}' not defined in '${file}'." \
    )"
    value="$( \
        koopa::print "$value" \
            | head -n 1 \
            | cut -d "\"" -f 2 \
    )"
    [ -n "$value" ] || return 1
    koopa::print "$value"
    return 0
}

koopa::variables() { # {{{1
    # """
    # Edit koopa variables.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed vim
    vim "$(koopa::include_prefix)/variables.txt"
    return 0
}

koopa::view_latest_tmp_log_file() { # {{{1
    # """
    # View the latest temporary log file.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed find
    local dir log_file
    dir="${TMPDIR:-/tmp}"
    log_file="$( \
        find "$dir" \
            -mindepth 1 \
            -maxdepth 1 \
            -type f \
            -name "koopa-$(koopa::user_id)-*" \
            | sort \
            | tail -n 1 \
    )"
    [ -f "$log_file" ] || return 1
    koopa::info "Viewing '${log_file}'."
    # Note that this will skip to the end automatically.
    less +G "$log_file"
    return 0
}
