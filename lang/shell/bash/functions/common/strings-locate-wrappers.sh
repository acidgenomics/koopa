#!/usr/bin/env bash

koopa::locate_7z() { # {{{1
    koopa::locate_app \
        --app-name='7z' \
        --opt='p7zip'
}

koopa::locate_anaconda() { # {{{1
    koopa::locate_app "$(koopa::anaconda_prefix)/bin/conda"
}

koopa::locate_ascp() { # {{{1
    koopa::locate_app \
        --app-name='ascp' \
        --macos-app="${HOME}/Applications/Aspera Connect.app/\
Contents/Resources/ascp" \
        --opt='aspera-connect'
}

koopa::locate_awk() { # {{{1
    koopa::locate_app \
        --app-name='awk' \
        --gnubin \
        --opt='gawk'
}

koopa::locate_aws() { # {{{1
    koopa::locate_app 'aws'
}

koopa::locate_basename() { # {{{1
    koopa::locate_gnu_coreutils_app 'basename'
}

koopa::locate_bash() { # {{{1
    koopa::locate_app 'bash'
}

koopa::locate_bc() { # {{{1
    koopa::locate_app 'bc'
}

koopa::locate_bpytop() { # {{{1
    koopa::locate_app \
        --app-name='bpytop' \
        --koopa-opt='python-packages'
}

koopa::locate_brew() { # {{{1
    koopa::locate_app 'brew'
}

koopa::locate_bundle() { # {{{1
    koopa::locate_app \
        --app-name='bundle' \
        --brew-opt='ruby' \
        --koopa-opt='ruby-packages'
}

koopa::locate_bunzip2() { # {{{1
    koopa::locate_app \
        --app-name='bunzip2' \
        --opt='bzip2'
}

koopa::locate_cargo() { # {{{1
    koopa::locate_app \
        --app-name='cargo' \
        --brew-opt='rust' \
        --koopa-opt='rust-packages'
}

koopa::locate_cat() { # {{{1
    koopa::locate_gnu_coreutils_app 'cat'
}

koopa::locate_chgrp() { # {{{1
    koopa::locate_app '/usr/bin/chgrp'
}

koopa::locate_chmod() { # {{{1
    koopa::locate_app '/bin/chmod'
}

koopa::locate_chown() { # {{{1
    local os_id str
    os_id="$(koopa::os_id)"
    case "$os_id" in
        'macos')
            str='/usr/sbin/chown'
            ;;
        *)
            str='/bin/chown'
            ;;
    esac
    koopa::locate_app "$str"
}

koopa::locate_cmake() { # {{{1
    koopa::locate_app 'cmake'
}

koopa::locate_conda() { # {{{1
    koopa::locate_app "$(koopa::conda_prefix)/bin/conda"
}

koopa::locate_conda_bedtools() { # {{{1
    koopa::locate_conda_app 'bedtools'
}

koopa::locate_conda_kallisto() { # {{{1
    koopa::locate_conda_app 'kallisto'
}

koopa::locate_conda_mashmap() { # {{{1
    koopa::locate_conda_app 'mashmap'
}

koopa::locate_conda_salmon() { # {{{1
    koopa::locate_conda_app 'salmon'
}

koopa::locate_convmv() { # {{{1
    koopa::locate_app 'convmv'
}

koopa::locate_cp() { # {{{1
    koopa::locate_app '/bin/cp'
}

koopa::locate_cpan() { # {{{1
    koopa::locate_app 'cpan'
}

koopa::locate_cpanm() { # {{{1
    koopa::locate_app \
        --app-name='cpanm' \
        --koopa-opt='perl-packages'
}

koopa::locate_curl() { # {{{1
    koopa::locate_app 'curl'
}

koopa::locate_cut() { # {{{1
    koopa::locate_gnu_coreutils_app 'cut'
}

koopa::locate_date() { # {{{1
    koopa::locate_gnu_coreutils_app 'date'
}

koopa::locate_df() { # {{{1
    koopa::locate_gnu_coreutils_app 'df'
}

koopa::locate_dig() { # {{{1
    koopa::locate_app \
        --app-name='dig' \
        --opt='bind'
}

koopa::locate_dirname() { # {{{1
    koopa::locate_gnu_coreutils_app 'dirname'
}

koopa::locate_docker() { # {{{1
    koopa::locate_app 'docker'
}

koopa::locate_doom() { # {{{1
    koopa::locate_app "$(koopa::doom_emacs_prefix)/bin/doom"
}

koopa::locate_du() { # {{{1
    koopa::locate_gnu_coreutils_app 'du'
}

koopa::locate_emacs() { # {{{1
    koopa::locate_app 'emacs'
}

koopa::locate_fd() { # {{{1
    koopa::locate_app \
        --app-name='fd' \
        --brew-opt='fd' \
        --koopa-opt='rust-packages'
}

koopa::locate_find() { # {{{1
    koopa::locate_app \
        --app-name='find' \
        --gnubin \
        --opt='findutils'
}

koopa::locate_fish() { # {{{1
    koopa::locate_app 'fish'
}

koopa::locate_gcc() { # {{{1
    local dict
    declare -A dict=(
        [version]="$(koopa::variable 'gcc')"
    )
    dict[maj_ver]="$(koopa::major_version "${dict[version]}")"
    koopa::locate_app \
        --app-name="gcc-${dict[maj_ver]}" \
        --opt="gcc@${dict[maj_ver]}"
}

koopa::locate_gcloud() { # {{{1
    koopa::locate_app 'gcloud'
}

koopa::locate_gem() { # {{{1
    koopa::locate_app \
        --app-name='gem' \
        --opt='ruby'
}

koopa::locate_git() { # {{{1
    koopa::locate_app 'git'
}

koopa::locate_go() { # {{{1
    koopa::locate_app 'go'
}

koopa::locate_gpg() { # {{{1
    koopa::locate_app \
        --app-name='gpg' \
        --macos-app='/usr/local/MacGPG2/bin/gpg' \
        --opt='gnupg'
}

koopa::locate_gpg_agent() { # {{{1
    koopa::locate_app \
        --app-name='gpg-agent' \
        --macos-app='/usr/local/MacGPG2/bin/gpg-agent' \
        --opt='gnupg'
}

koopa::locate_gpgconf() { # {{{1
    koopa::locate_app \
        --app-name='gpgconf' \
        --macos-app='/usr/local/MacGPG2/bin/gpgconf' \
        --opt='gnupg'
}

koopa::locate_grep() { # {{{1
    koopa::locate_app \
        --app-name='grep' \
        --gnubin
}

koopa::locate_groups() { # {{{1
    koopa::locate_gnu_coreutils_app 'groups'
}

koopa::locate_gunzip() { # {{{1
    koopa::locate_app \
        --app-name='gunzip' \
        --opt='gzip'
}

koopa::locate_gzip() { # {{{1
    koopa::locate_app 'gzip'
}

koopa::locate_h5cc() { # {{{1
    koopa::locate_app \
        --app-name='h5cc' \
        --opt='hdf5'
}

koopa::locate_head() { # {{{1
    koopa::locate_gnu_coreutils_app 'head'
}

koopa::locate_hostname() {
    koopa::locate_app '/bin/hostname'
}

koopa::locate_id() { # {{{1
    koopa::locate_gnu_coreutils_app 'id'
}

koopa::locate_java() { # {{{1
    koopa::locate_app \
        --app-name='java' \
        --opt='openjdk'
}

koopa::locate_julia() { # {{{1
    koopa::locate_app \
        --app-name='julia' \
        --macos-app="$(koopa::macos_julia_prefix)/bin/julia"
}

koopa::locate_lesspipe() { # {{{1
    koopa::locate_app \
        --app-name='lesspipe.sh' \
        --opt='lesspipe'
}

koopa::locate_lua() { # {{{1
    koopa::locate_app 'lua'
}

koopa::locate_luarocks() { # {{{1
    koopa::locate_app 'luarocks'
}

koopa::locate_llvm_config() { # {{{1
    local app dict
    declare -A app=(
        [brew]="$(koopa::locate_brew 2>/dev/null || true)"
        [llvm_config]="${LLVM_CONFIG:-}"
    )
    if [[ ! -x "${app[llvm_config]}" ]] && \
        [[ ! -x "${app[brew]}" ]]
    then
        app[tail]="$(koopa::locate_tail)"
        app[llvm_config]="$( \
            koopa::find \
                --glob='llvm-config-*' \
                --prefix='/usr/bin' \
                --sort \
            | "${app[tail]}" -n 1 \
        )"
    fi
    [[ ! -x "${app[llvm_config]}" ]] && app[llvm_config]='llvm-config'
    koopa::locate_app \
        --app-name="${app[llvm_config]}" \
        --opt='llvm'
}

koopa::locate_ln() { # {{{1
    koopa::locate_app '/bin/ln'
}

koopa::locate_locale() { # {{{1
    koopa::locate_app '/usr/bin/locale'
}

koopa::locate_localedef() { # {{{1
    # """
    # Locate 'localedef'.
    # @note Updated 2022-01-25.
    # """
    if koopa::is_alpine
    then
        koopa::alpine_locate_localedef
    else
        koopa::locate_app '/usr/bin/localedef'
    fi
}

koopa::locate_ls() { # {{{1
    # """
    # Locate GNU 'ls'.
    # @note Updated 2021-11-04.
    # """
    koopa::locate_gnu_coreutils_app 'ls'
}

koopa::locate_make() { # {{{1
    # """
    # Locate GNU 'make'.
    # @note Updated 2021-09-15.
    # """
    koopa::locate_app \
        --app-name='make' \
        --gnubin
}

koopa::locate_mamba() { # {{{1
    # """
    # Locate 'mamba' inside Miniconda install.
    # @note Updated 2022-01-17.
    #
    # @seealso
    # - https://github.com/mamba-org/mamba
    # - https://github.com/conda-forge/miniforge
    # """
    koopa::locate_app "$(koopa::conda_prefix)/bin/mamba"
}

koopa::locate_mamba_or_conda() { # {{{1
    # """
    # Attempt to locate mamba first, and fall back to conda if not installed.
    # @note Updated 2022-01-17.
    # """
    local str
    str="$(koopa::locate_mamba 2>/dev/null || true)"
    if [[ ! -x "$str" ]]
    then
        str="$(koopa::locate_conda 2>/dev/null || true)"
    fi
    if [[ ! -x "$str" ]]
    then
        koopa::warning 'Failed to locate mamba or conda.'
        return 1
    fi
    koopa::print "$str"
    return 0
}

koopa::locate_man() { # {{{1
    # """
    # Locate GNU 'man'.
    # @note Updated 2022-01-10.
    # """
    koopa::locate_app \
        --app-name='man' \
        --gnubin \
        --opt='man-db'
}

koopa::locate_md5sum() { # {{{1
    # """
    # Locate GNU 'md5sum'.
    # @note Updated 2021-11-04.
    # """
    koopa::locate_gnu_coreutils_app 'md5sum'
}

koopa::locate_mkdir() { # {{{1
    # """
    # Locate GNU 'mkdir'.
    # @note Updated 2021-11-04.
    # """
    koopa::locate_gnu_coreutils_app 'mkdir'
}

koopa::locate_mktemp() { # {{{1
    # """
    # Locate GNU 'mktemp'.
    # @note Updated 2021-11-04.
    # """
    koopa::locate_app 'mktemp'
}

koopa::locate_mv() { # {{{1
    # """
    # Locate GNU 'mv'.
    # @note Updated 2021-10-22.
    #
    # macOS gmv currently has issues on NFS shares.
    # """
    koopa::locate_app '/bin/mv'
}

koopa::locate_neofetch() { # {{{1
    # """
    # Locate 'neofetch'.
    # @note Updated 2021-11-18.
    # """
    koopa::locate_app 'neofetch'
}

koopa::locate_newgrp() { # {{{1
    # """
    # Locate GNU 'newgrp'.
    # @note Updated 2022-01-25.
    # """
    koopa::locate_app '/usr/bin/newgrp'
}

koopa::locate_nim() { # {{{1
    # """
    # Locate 'nim'.
    # @note Updated 2021-09-29.
    # """
    koopa::locate_app 'nim'
}

koopa::locate_node() { # {{{1
    # """
    # Locate 'node'.
    # @note Updated 2021-09-16.
    # """
    koopa::locate_app 'node'
}

koopa::locate_npm() { # {{{1
    # """
    # Locate node package manager ('npm').
    # @note Updated 2022-01-10.
    # """
    koopa::locate_app \
        --app-name='npm' \
        --brew-opt='node' \
        --koopa-opt='node-packages'
}

koopa::locate_openssl() { # {{{1
    # """
    # Locate 'openssl'.
    # @note Updated 2021-09-15.
    # """
    koopa::locate_app 'openssl'
}

koopa::locate_parallel() { # {{{1
    # """
    # Locate GNU 'parallel'.
    # @note Updated 2021-09-15.
    # """
    koopa::locate_app 'parallel'
}

koopa::locate_passwd() { # {{{1
    # """
    # Locate 'passwd'.
    # @note Updated 2021-11-01.
    # """
    koopa::locate_app '/usr/bin/passwd'
}

koopa::locate_paste() { # {{{1
    # """
    # Locate GNU 'paste'.
    # @note Updated 2021-11-4.
    # """
    koopa::locate_gnu_coreutils_app 'paste'
}

koopa::locate_patch() { # {{{1
    # """
    # Locate GNU 'patch'.
    # @note Updated 2022-01-10.
    # """
    koopa::locate_app \
        --app-name='patch' \
        --opt='gpatch'
}

koopa::locate_pcregrep() { # {{{1
    # """
    # Locate 'pcregrep'.
    # @note Updated 2022-01-10.
    # """
    koopa::locate_app \
        --app-name='pcregrep' \
        --opt='pcre'
}

koopa::locate_perl() { # {{{1
    # """
    # Locate 'perl'.
    # @note Updated 2021-09-15.
    # """
    koopa::locate_app 'perl'
}

koopa::locate_perlbrew() { # {{{1
    # """
    # Locate 'perlbrew'.
    # @note Updated 2021-09-17.
    # """
    koopa::locate_app 'perlbrew'
}

koopa::locate_pkg_config() { # {{{1
    # """
    # Locate 'pkg-config'.
    # @note Updated 2021-09-15.
    # """
    koopa::locate_app 'pkg-config'
}

koopa::locate_python() { # {{{1
    # """
    # Locate Python.
    # @note Updated 2022-01-10.
    # """
    local app name version
    name='python'
    version="$(koopa::variable "$name")"
    version="$(koopa::major_version "$version")"
    app="${name}${version}"
    koopa::locate_app \
        --app-name="$app" \
        --macos-app="$(koopa::macos_python_prefix)/bin/${app}"
}

koopa::locate_r() { # {{{1
    # """
    # Locate R.
    # @note Updated 2022-01-10.
    # """
    koopa::locate_app \
        --app-name='R' \
        --macos-app="$(koopa::macos_r_prefix)/bin/R"
}

koopa::locate_rscript() { # {{{1
    # """
    # Locate Rscript.
    # @note Updated 2022-01-10.
    # """
    local r rscript
    r="$(koopa::locate_r)"
    rscript="${r}script"
    if [[ ! -x "$rscript" ]]
    then
        koopa::warn "Not executable: '${rscript}'."
        return 1
    fi
    koopa::print "$rscript"
    return 0
}

koopa::locate_readlink() { # {{{1
    # """
    # Locate GNU 'readlink'.
    # @note Updated 2021-11-04.
    # """
    koopa::locate_gnu_coreutils_app 'readlink'
}

koopa::locate_realpath() { # {{{1
    # """
    # Locate GNU 'realpath'.
    # @note Updated 2021-11-04.
    # """
    koopa::locate_gnu_coreutils_app 'realpath'
}

koopa::locate_rename() { # {{{1
    # """
    # Locate Perl 'rename'.
    # @note Updated 2021-09-15.
    # """
    koopa::locate_app "$(koopa::perl_packages_prefix)/bin/rename"
}

koopa::locate_rg() { # {{{1
    # """
    # Locate 'ripgrep'.
    # @note Updated 2022-01-10.
    # """
    koopa::locate_app \
        --app-name='rg' \
        --opt='ripgrep'
}

koopa::locate_rm() { # {{{1
    # """
    # Locate GNU 'rm'.
    # @note Updated 2021-10-22.
    # """
    koopa::locate_app '/bin/rm'
}

koopa::locate_rsync() { # {{{1
    # """
    # Locate 'rsync'.
    # @note Updated 2021-09-15.
    # """
    koopa::locate_app 'rsync'
}

koopa::locate_ruby() { # {{{1
    # """
    # Locate 'ruby'.
    # @note Updated 2021-09-15.
    # """
    koopa::locate_app 'ruby'
}

koopa::locate_rustc() { # {{{1
    # """
    # Locate Rust compiler ('rustc').
    # @note Updated 2022-01-10.
    # """
    koopa::locate_app \
        --app-name='rustc' \
        --brew-opt='rust' \
        --koopa-opt='rust-packages'
}

koopa::locate_rustup() { # {{{1
    # """
    # Locate Rust compiler ('rustc').
    # @note Updated 2021-11-19.
    # """
    koopa::locate_app \
        --app-name='rustup' \
        --brew-opt='rustup' \
        --koopa-opt='rust-packages'
}

koopa::locate_sed() { # {{{1
    # """
    # Locate GNU 'sed'.
    # @note Updated 2022-01-10.
    # """
    koopa::locate_app \
        --app-name='sed' \
        --gnubin \
        --opt='gnu-sed'
}

koopa::locate_sort() { # {{{1
    # """
    # Locate GNU 'sort'.
    # @note Updated 2021-11-04.
    # """
    koopa::locate_gnu_coreutils_app 'sort'
}

koopa::locate_sqlplus() { # {{{1
    # """
    # Locate Oracle 'sqlplus'.
    # @note Updated 2021-10-27.
    # """
    koopa::locate_app 'sqlplus'
}

koopa::locate_ssh() { # {{{1
    # """
    # Locate 'ssh'.
    # @note Updated 2022-01-10.
    # """
    koopa::locate_app \
        --app-name='ssh' \
        --opt='openssh'
}

koopa::locate_ssh_keygen() { # {{{1
    # """
    # Locate 'ssh'.
    # @note Updated 2022-01-10.
    # """
    koopa::locate_app \
        --app-name='ssh-keygen' \
        --opt='openssh'
}

koopa::locate_stat() { # {{{1
    # """
    # Locate GNU 'stat'.
    # @note Updated 2021-11-04.
    # """
    koopa::locate_gnu_coreutils_app 'stat'
}

koopa::locate_sudo() { # {{{1
    # """
    # Locate 'sudo'.
    # @note Updated 2021-10-27.
    # """
    koopa::locate_app '/usr/bin/sudo'
}

koopa::locate_svn() { # {{{1
    # """
    # Locate 'svn'.
    # @note Updated 2021-09-15.
    # """
    koopa::locate_app 'svn'
}

koopa::locate_tac() { # {{{1
    # """
    # Locate GNU 'tac'.
    # @note Updated 2021-11-04.
    # """
    koopa::locate_gnu_coreutils_app 'tac'
}

koopa::locate_tail() { # {{{1
    # """
    # Locate GNU 'tail'.
    # @note Updated 2021-11-04.
    # """
    koopa::locate_gnu_coreutils_app 'tail'
}

koopa::locate_tar() { # {{{1
    # """
    # Locate GNU 'tar'.
    # @note Updated 2022-01-10.
    # """
    koopa::locate_app \
        --app-name='tar' \
        --gnubin \
        --opt='gnu-tar'
}

koopa::locate_tee() { # {{{1
    # """
    # Locate GNU 'tee'.
    # @note Updated 2021-11-04.
    # """
    koopa::locate_gnu_coreutils_app 'tee'
}

koopa::locate_tex() { # {{{1
    # """
    # Locate TeX.
    # @note Updated 2021-10-27.
    # """
    koopa::locate_app \
        --app-name='tex' \
        --macos-app='/Library/TeX/texbin/tex'
}

koopa::locate_tlmgr() { # {{{1
    # """
    # Locate Tex 'tlmgr'.
    # @note Updated 2022-01-10.
    # """
    koopa::locate_app \
        --app-name='tlmgr' \
        --macos-app='/Library/TeX/texbin/tlmgr'
}

koopa::locate_touch() { # {{{1
    # """
    # Locate GNU 'touch'.
    # @note Updated 2021-11-04.
    # """
    koopa::locate_gnu_coreutils_app 'touch'
}

koopa::locate_tr() { # {{{1
    # """
    # Locate GNU 'tr'.
    # @note Updated 2021-11-04.
    # """
    koopa::locate_gnu_coreutils_app 'tr'
}

koopa::locate_uncompress() { # {{{1
    # """
    # Locate GNU 'uncompress'.
    # @note Updated 2022-01-10.
    # """
    koopa::locate_app \
        --app-name='uncompress' \
        --gnubin \
        --opt='gzip'
}

koopa::locate_uname() { # {{{1
    # """
    # Locate GNU 'uname'.
    # @note Updated 2021-11-04.
    # """
    koopa::locate_gnu_coreutils_app 'uname'
}

koopa::locate_uniq() { # {{{1
    # """
    # Locate GNU 'uniq'.
    # @note Updated 2021-11-04.
    # """
    koopa::locate_gnu_coreutils_app 'uniq'
}

koopa::locate_unzip() { # {{{1
    # """
    # Locate 'unzip'.
    # @note Updated 2021-09-15.
    # """
    koopa::locate_app 'unzip'
}

koopa::locate_vim() { # {{{1
    # """
    # Locate 'vim'.
    # @note Updated 2021-10-27.
    # """
    koopa::locate_app 'vim'
}

koopa::locate_wc() { # {{{1
    # """
    # Locate GNU 'wc'.
    # @note Updated 2021-11-04.
    # """
    koopa::locate_gnu_coreutils_app 'wc'
}

koopa::locate_wget() { # {{{1
    # """
    # Locate 'wget'.
    # @note Updated 2021-09-15.
    # """
    koopa::locate_app 'wget'
}

koopa::locate_whoami() { # {{{1
    # """
    # Locate GNU 'whoami'.
    # @note Updated 2021-11-04.
    # """
    koopa::locate_gnu_coreutils_app 'whoami'
}

koopa::locate_xargs() { # {{{1
    # """
    # Locate GNU 'xargs'.
    # @note Updated 2022-01-10.
    # """
    koopa::locate_app \
        --app-name='xargs' \
        --gnubin \
        --opt='findutils'
}

koopa::locate_yes() { # {{{1
    # """
    # Locate GNU 'yes'.
    # @note Updated 2021-11-04.
    # """
    koopa::locate_gnu_coreutils_app 'yes'
}

koopa::locate_zcat() { # {{{1
    # """
    # Locate GNU 'zcat'.
    # @note Updated 2022-01-10.
    # """
    koopa::locate_app \
        --app-name='zcat' \
        --opt='gzip'
}
