#!/usr/bin/env bash

koopa::install_python() { # {{{1
    if koopa::is_macos
    then
        koopa::macos_install_python_framework
        return 0
    fi
    koopa::install_app \
        --name='python' \
        --name-fancy='Python' \
        "$@"
}

# FIXME Seeing this install error now on Ubuntu 20:
# Looking in links: /tmp/tmpxosyzu70
# Processing /tmp/tmpxosyzu70/setuptools-56.0.0-py3-none-any.whl
# Processing /tmp/tmpxosyzu70/pip-21.1.1-py3-none-any.whl
# Installing collected packages: setuptools, pip
#   WARNING: The scripts pip3 and pip3.9 are installed in '/opt/koopa/app/python/3.9.5/bin' which is not on PATH.
#   Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.
# Successfully installed pip-21.1.1 setuptools-56.0.0
# /opt/koopa/app/python/3.9.5/bin/python3.9: error while loading shared libraries: libpython3.9.so.1.0: cannot open shared object file: No such file or directory
# → Adding '/koopa.pth' path file in ''.
# /opt/koopa/lang/shell/bash/functions/common/system/write.sh: line 78: /koopa.pth: Permission denied


koopa:::install_python() { # {{{1
    # """
    # Install Python.
    # @note Updated 2021-05-05.
    #
    # Check config with:
    # > ldd /usr/local/bin/python3
    #
    # Warning: 'make install' can overwrite or masquerade the python3 binary.
    # 'make altinstall' is therefore recommended instead of make install since
    # it only installs 'exec_prefix/bin/pythonversion'.
    #
    # Ubuntu 18 LTS requires LDFLAGS to be set, otherwise we hit:
    # ## python3: error while loading shared libraries: libpython3.8.so.1.0:
    # ## cannot open shared object file: No such file or directory
    # This alone works, but I've set other paths, as recommended.
    # # > LDFLAGS="-Wl,-rpath ${prefix}/lib"
    #
    # To customize g++ path, specify `CXX` environment variable
    # or use `--with-cxx-main=/usr/bin/g++`.
    #
    # See also:
    # - https://docs.python.org/3/using/unix.html
    # - https://stackoverflow.com/questions/43333207
    # """
    local conf_args file jobs name name2 prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='python'
    name2="$(koopa::capitalize "$name")"
    minor_version="$(koopa::major_minor_version "$version")"
    jobs="$(koopa::cpu_count)"
    file="${name2}-${version}.tar.xz"
    url="https://www.${name}.org/ftp/${name}/${version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name2}-${version}"
    conf_args=(
        "--prefix=${prefix}"
        #"LDFLAGS=-Wl,-rpath=${prefix}/lib"
        #'--enable-optimizations'
        #'--enable-shared'
    )
    ./configure "${conf_args[@]}"
    make --jobs="$jobs"
    # > make test
    # > Use 'make altinstall' here instead?
    make install
    python="${prefix}/bin/${name}${minor_version}"
    koopa::assert_is_file "$python"
    # FIXME This step is erroring out on Ubuntu 20.
    koopa::python_add_site_packages_to_sys_path "$python"
    return 0
}

koopa::install_python_packages() { # {{{1
    # """
    # Install Python packages.
    # @note Updated 2021-04-30.
    # """
    local name_fancy pkg pkg_lower pkgs version
    python="$(koopa::python)"
    koopa::assert_has_no_envs
    koopa::assert_is_installed "$python"
    name_fancy='Python packages'
    pkgs=("$@")
    if [[ "${#pkgs[@]}" -eq 0 ]]
    then
        pkgs=(
            # > 'pynvim'
            'pip2pi'
            'psutil'
            'pyflakes'
            'pytaglib'
            'pytest'
            'setuptools'
            'six'
            'wheel'
        )
        if ! koopa::is_installed brew
        then
            pkgs+=(
                'black'
                'bpytop'
                'flake8'
                'pipx'
                'pylint'
                'ranger-fm'
            )
        fi
        for i in "${!pkgs[@]}"
        do
            pkg="${pkgs[$i]}"
            pkg_lower="$(koopa::lowercase "$pkg")"
            version="$(koopa::variable "python-${pkg_lower}")"
            pkgs[$i]="${pkg}==${version}"
        done
    fi
    koopa::install_start "$name_fancy"
    koopa::pip_install "${pkgs[@]}"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::update_python_packages() { # {{{1
    # """
    # Update all pip packages.
    # @note Updated 2021-04-30.
    # @seealso
    # - https://github.com/pypa/pip/issues/59
    # - https://stackoverflow.com/questions/2720014
    # """
    local name_fancy pkgs python
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    python="$(koopa::python)"
    koopa::is_installed "$python" || return 0
    name_fancy='Python packages'
    koopa::install_start "$name_fancy"
    pkgs="$(koopa::pip_outdated)"
    if [[ -z "$pkgs" ]]
    then
        koopa::alert_success 'All Python packages are current.'
        return 0
    fi
    readarray -t pkgs <<< "$( \
        koopa::print "$pkgs" \
        | cut -d '=' -f 1 \
    )"
    koopa::pip_install "${pkgs[@]}"
    koopa::install_success "$name_fancy"
    return 0
}
