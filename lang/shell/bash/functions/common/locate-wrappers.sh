#!/usr/bin/env bash

koopa_locate_7z() { # {{{1
    koopa_locate_app \
        --app-name='7z' \
        --opt-name='p7zip'
}

koopa_locate_anaconda() { # {{{1
    koopa_locate_app "$(koopa_anaconda_prefix)/bin/conda"
}

koopa_locate_ascp() { # {{{1
    koopa_locate_app \
        --app-name='ascp' \
        --macos-app="${HOME}/Applications/Aspera Connect.app/\
Contents/Resources/ascp" \
        --opt-name='aspera-connect'
}

koopa_locate_awk() { # {{{1
    koopa_locate_app \
        --app-name='awk' \
        --homebrew-gnubin \
        --opt-name='gawk'
}

koopa_locate_aws() { # {{{1
    koopa_locate_app 'aws'
}

koopa_locate_basename() { # {{{1
    koopa_locate_gnu_coreutils_app 'basename'
}

koopa_locate_bash() { # {{{1
    koopa_locate_app 'bash'
}

koopa_locate_bc() { # {{{1
    koopa_locate_app 'bc'
}

koopa_locate_bedtools() { # {{{1
    koopa_locate_conda_app 'bedtools'
}

koopa_locate_bpytop() { # {{{1
    koopa_locate_app \
        --app-name='bpytop' \
        --koopa-opt-name='python-packages'
}

koopa_locate_brew() { # {{{1
    koopa_locate_app 'brew'
}

koopa_locate_bundle() { # {{{1
    koopa_locate_app \
        --app-name='bundle' \
        --homebrew-opt-name='ruby' \
        --koopa-opt-name='ruby-packages'
}

koopa_locate_bzip2() { # {{{1
    koopa_locate_app 'bzip2'
}

koopa_locate_cargo() { # {{{1
    koopa_locate_app \
        --app-name='cargo' \
        --homebrew-opt-name='rust' \
        --koopa-opt-name='rust-packages'
}

koopa_locate_cat() { # {{{1
    koopa_locate_gnu_coreutils_app 'cat'
}

koopa_locate_chgrp() { # {{{1
    koopa_locate_app '/usr/bin/chgrp'
}

koopa_locate_chmod() { # {{{1
    koopa_locate_app '/bin/chmod'
}

koopa_locate_chown() { # {{{1
    local os_id str
    os_id="$(koopa_os_id)"
    case "$os_id" in
        'macos')
            str='/usr/sbin/chown'
            ;;
        *)
            str='/bin/chown'
            ;;
    esac
    koopa_locate_app "$str"
}

koopa_locate_cmake() { # {{{1
    koopa_locate_app 'cmake'
}

koopa_locate_conda() { # {{{1
    koopa_locate_app "$(koopa_conda_prefix)/bin/conda"
}

koopa_locate_convmv() { # {{{1
    koopa_locate_app 'convmv'
}

koopa_locate_cp() { # {{{1
    koopa_locate_app '/bin/cp'
}

koopa_locate_cpan() { # {{{1
    koopa_locate_app 'cpan'
}

koopa_locate_cpanm() { # {{{1
    koopa_locate_app \
        --app-name='cpanm' \
        --koopa-opt-name='perl-packages'
}

koopa_locate_curl() { # {{{1
    koopa_locate_app 'curl'
}

koopa_locate_cut() { # {{{1
    koopa_locate_gnu_coreutils_app 'cut'
}

koopa_locate_date() { # {{{1
    koopa_locate_gnu_coreutils_app 'date'
}

koopa_locate_df() { # {{{1
    koopa_locate_gnu_coreutils_app 'df'
}

koopa_locate_dig() { # {{{1
    koopa_locate_app \
        --app-name='dig' \
        --opt-name='bind'
}

koopa_locate_dirname() { # {{{1
    koopa_locate_gnu_coreutils_app 'dirname'
}

koopa_locate_docker() { # {{{1
    koopa_locate_app 'docker'
}

koopa_locate_doom() { # {{{1
    koopa_locate_app "$(koopa_doom_emacs_prefix)/bin/doom"
}

koopa_locate_du() { # {{{1
    koopa_locate_gnu_coreutils_app 'du'
}

koopa_locate_efetch() { # {{{1
    koopa_locate_conda_app \
        --app-name='efetch' \
        --env-name='entrez-direct'
}

koopa_locate_esearch() { # {{{1
    koopa_locate_conda_app \
        --app-name='esearch' \
        --env-name='entrez-direct'
}

koopa_locate_emacs() { # {{{1
    koopa_locate_app 'emacs'
}

koopa_locate_exiftool() { # {{{1
    koopa_locate_app 'exiftool'
}

koopa_locate_fasterq_dump() { # {{{1
    koopa_locate_app \
        --app-name='fasterq-dump' \
        --opt-name='sratoolkit'
}

koopa_locate_fd() { # {{{1
    koopa_locate_app \
        --app-name='fd' \
        --homebrew-opt-name='fd' \
        --koopa-opt-name='rust-packages'
}

koopa_locate_ffmpeg() { # {{{1
    koopa_locate_app 'ffmpeg'
}

koopa_locate_find() { # {{{1
    koopa_locate_app \
        --app-name='find' \
        --homebrew-gnubin \
        --opt-name='findutils'
}

koopa_locate_fish() { # {{{1
    koopa_locate_app 'fish'
}

koopa_locate_gcc() { # {{{1
    local dict
    declare -A dict=(
        [name]='gcc'
    )
    dict[version]="$(koopa_variable "${dict[name]}")"
    dict[maj_ver]="$(koopa_major_version "${dict[version]}")"
    koopa_locate_app \
        --app-name="${dict[name]}-${dict[maj_ver]}" \
        --opt-name="${dict[name]}@${dict[maj_ver]}"
}

koopa_locate_gcloud() { # {{{1
    koopa_locate_app 'gcloud'
}

koopa_locate_gdal_config() { # {{{1
    koopa_locate_app \
        --app-name='gdal-config' \
        --opt-name='gdal'
}

koopa_locate_gem() { # {{{1
    koopa_locate_app \
        --app-name='gem' \
        --opt-name='ruby'
}

koopa_locate_geos_config() { # {{{1
    koopa_locate_app \
        --app-name='geos-config' \
        --opt-name='geos'
}

koopa_locate_git() { # {{{1
    koopa_locate_app 'git'
}

koopa_locate_go() { # {{{1
    koopa_locate_app 'go'
}

koopa_locate_gpg() { # {{{1
    koopa_locate_app \
        --app-name='gpg' \
        --macos-app='/usr/local/MacGPG2/bin/gpg' \
        --opt-name='gnupg'
}

koopa_locate_gpg_agent() { # {{{1
    koopa_locate_app \
        --app-name='gpg-agent' \
        --macos-app='/usr/local/MacGPG2/bin/gpg-agent' \
        --opt-name='gnupg'
}

koopa_locate_gpgconf() { # {{{1
    koopa_locate_app \
        --app-name='gpgconf' \
        --macos-app='/usr/local/MacGPG2/bin/gpgconf' \
        --opt-name='gnupg'
}

koopa_locate_grep() { # {{{1
    koopa_locate_app \
        --app-name='grep' \
        --homebrew-gnubin
}

koopa_locate_groups() { # {{{1
    koopa_locate_gnu_coreutils_app 'groups'
}

koopa_locate_gs() { # {{{1
    koopa_locate_app \
        --app-name='gs' \
        --opt-name='ghostscript'
}

koopa_locate_gzip() { # {{{1
    koopa_locate_app 'gzip'
}

koopa_locate_h5cc() { # {{{1
    koopa_locate_app \
        --app-name='h5cc' \
        --opt-name='hdf5'
}

koopa_locate_head() { # {{{1
    koopa_locate_gnu_coreutils_app 'head'
}

koopa_locate_hostname() {
    koopa_locate_app '/bin/hostname'
}

koopa_locate_id() { # {{{1
    koopa_locate_gnu_coreutils_app 'id'
}

koopa_locate_java() { # {{{1
    koopa_locate_app \
        --app-name='java' \
        --opt-name='openjdk'
}

koopa_locate_jq() { # {{{1
    koopa_locate_app 'jq'
}

koopa_locate_julia() { # {{{1
    koopa_locate_app \
        --app-name='julia' \
        --macos-app="$(koopa_macos_julia_prefix)/bin/julia"
}

koopa_locate_kallisto() { # {{{1
    koopa_locate_conda_app 'kallisto'
}

koopa_locate_less() { # {{{1
    koopa_locate_app 'less'
}

koopa_locate_lesspipe() { # {{{1
    koopa_locate_app \
        --app-name='lesspipe.sh' \
        --opt-name='lesspipe'
}

koopa_locate_lua() { # {{{1
    koopa_locate_app 'lua'
}

koopa_locate_luarocks() { # {{{1
    koopa_locate_app 'luarocks'
}

koopa_locate_llvm_config() { # {{{1
    local app dict
    declare -A app=(
        [brew]="$(koopa_locate_brew 2>/dev/null || true)"
        [llvm_config]="${LLVM_CONFIG:-}"
    )
    if [[ ! -x "${app[llvm_config]}" ]] && \
        [[ ! -x "${app[brew]}" ]]
    then
        app[tail]="$(koopa_locate_tail)"
        app[llvm_config]="$( \
            koopa_find \
                --pattern='llvm-config-*' \
                --prefix='/usr/bin' \
                --sort \
            | "${app[tail]}" --lines=1 \
        )"
    fi
    [[ ! -x "${app[llvm_config]}" ]] && app[llvm_config]='llvm-config'
    koopa_locate_app \
        --app-name="${app[llvm_config]}" \
        --opt-name='llvm'
}

koopa_locate_ln() { # {{{1
    koopa_locate_app '/bin/ln'
}

koopa_locate_locale() { # {{{1
    koopa_locate_app '/usr/bin/locale'
}

koopa_locate_localedef() { # {{{1
    if koopa_is_alpine
    then
        koopa_alpine_locate_localedef
    else
        koopa_locate_app '/usr/bin/localedef'
    fi
}

koopa_locate_ls() { # {{{1
    koopa_locate_gnu_coreutils_app 'ls'
}

koopa_locate_magick_core_config() { # {{{1
    koopa_locate_app \
        --app-name='MagickCore-config' \
        --opt-name='imagemagick'
}

koopa_locate_make() { # {{{1
    koopa_locate_app \
        --app-name='make' \
        --homebrew-gnubin
}

koopa_locate_mamba() { # {{{1
    koopa_locate_app "$(koopa_conda_prefix)/bin/mamba"
}

koopa_locate_mamba_or_conda() { # {{{1
    local str
    str="$(koopa_locate_mamba 2>/dev/null || true)"
    if [[ ! -x "$str" ]]
    then
        str="$(koopa_locate_conda 2>/dev/null || true)"
    fi
    if [[ ! -x "$str" ]]
    then
        koopa_warn 'Failed to locate mamba or conda.'
        return 1
    fi
    koopa_print "$str"
    return 0
}

koopa_locate_man() { # {{{1
    koopa_locate_app \
        --app-name='man' \
        --homebrew-gnubin \
        --opt-name='man-db'
}

koopa_locate_mashmap() { # {{{1
    koopa_locate_conda_app 'mashmap'
}

koopa_locate_md5sum() { # {{{1
    koopa_locate_gnu_coreutils_app 'md5sum'
}

koopa_locate_meson() { # {{{1
    koopa_locate_app 'meson'
}

koopa_locate_mkdir() { # {{{1
    koopa_locate_gnu_coreutils_app 'mkdir'
}

koopa_locate_mktemp() { # {{{1
    koopa_locate_app 'mktemp'
}

koopa_locate_mv() { # {{{1
    # """
    # @note macOS gmv currently has issues on NFS shares.
    # """
    koopa_locate_app '/bin/mv'
}

koopa_locate_neofetch() { # {{{1
    koopa_locate_app 'neofetch'
}

koopa_locate_newgrp() { # {{{1
    koopa_locate_app '/usr/bin/newgrp'
}

koopa_locate_nim() { # {{{1
    koopa_locate_app 'nim'
}

koopa_locate_nimble() { # {{{1
    koopa_locate_app \
        --app-name='nimble' \
        --opt-name='nim'
}

koopa_locate_ninja() { # {{{1
    koopa_locate_app 'ninja'
}

koopa_locate_node() { # {{{1
    koopa_locate_app 'node'
}

koopa_locate_npm() { # {{{1
    koopa_locate_app \
        --app-name='npm' \
        --homebrew-opt-name='node' \
        --koopa-opt-name='node-packages'
}

koopa_locate_od() { # {{{1
    koopa_locate_gnu_coreutils_app 'od'
}

koopa_locate_openssl() { # {{{1
    koopa_locate_app 'openssl'
}

koopa_locate_parallel() { # {{{1
    koopa_locate_app 'parallel'
}

koopa_locate_passwd() { # {{{1
    koopa_locate_app '/usr/bin/passwd'
}

koopa_locate_paste() { # {{{1
    koopa_locate_gnu_coreutils_app 'paste'
}

koopa_locate_patch() { # {{{1
    koopa_locate_app \
        --app-name='patch' \
        --opt-name='gpatch'
}

koopa_locate_pcregrep() { # {{{1
    koopa_locate_app \
        --app-name='pcregrep' \
        --opt-name='pcre'
}

koopa_locate_perl() { # {{{1
    koopa_locate_app 'perl'
}

koopa_locate_perlbrew() { # {{{1
    koopa_locate_app 'perlbrew'
}

koopa_locate_pkg_config() { # {{{1
    koopa_locate_app 'pkg-config'
}

koopa_locate_prefetch() { # {{{1
    koopa_locate_app \
        --app-name='prefetch' \
        --opt-name='sratoolkit'
}

koopa_locate_proj() { # {{{1
    koopa_locate_app 'proj'
}

koopa_locate_pyenv() { # {{{1
    koopa_locate_app 'pyenv'
}

koopa_locate_python() { # {{{1
    local app dict
    declare -A app
    declare -A dict=(
        [macos_python_prefix]="$(koopa_macos_python_prefix)"
        [name]='python'
    )
    dict[version]="$(koopa_variable "${dict[name]}")"
    dict[maj_ver]="$(koopa_major_version "${dict[version]}")"
    app[python]="${dict[name]}${dict[maj_ver]}"
    koopa_locate_app \
        --app-name="${app[python]}" \
        --macos-app="${dict[macos_python_prefix]}/bin/${app[python]}"
}

koopa_locate_r() { # {{{1
    koopa_locate_app \
        --app-name='R' \
        --macos-app="$(koopa_macos_r_prefix)/bin/R"
}

koopa_locate_rbenv() { # {{{1
    koopa_locate_app 'rbenv'
}

koopa_locate_rscript() { # {{{1
    local app
    declare -A app=(
        [r]="$(koopa_locate_r)"
    )
    app[rscript]="${app[r]}script"
    koopa_locate_app "${app[rscript]}"
}

koopa_locate_readlink() { # {{{1
    koopa_locate_gnu_coreutils_app 'readlink'
}

koopa_locate_realpath() { # {{{1
    koopa_locate_gnu_coreutils_app 'realpath'
}

koopa_locate_rename() { # {{{1
    koopa_locate_app "$(koopa_perl_packages_prefix)/bin/rename"
}

koopa_locate_rg() { # {{{1
    koopa_locate_app \
        --app-name='rg' \
        --opt-name='ripgrep'
}

koopa_locate_rm() { # {{{1
    koopa_locate_app '/bin/rm'
}

koopa_locate_rsync() { # {{{1
    koopa_locate_app 'rsync'
}

koopa_locate_ruby() { # {{{1
    koopa_locate_app 'ruby'
}

koopa_locate_rustc() { # {{{1
    koopa_locate_app \
        --app-name='rustc' \
        --homebrew-opt-name='rust' \
        --koopa-opt-name='rust-packages'
}

koopa_locate_rustup() { # {{{1
    koopa_locate_app \
        --app-name='rustup' \
        --homebrew-opt-name='rustup' \
        --koopa-opt-name='rust-packages'
}

koopa_locate_salmon() { # {{{1
    koopa_locate_conda_app 'salmon'
}

koopa_locate_scp() { # {{{1
    koopa_locate_app \
        --app-name='scp' \
        --opt-name='openssh'
}

koopa_locate_sed() { # {{{1
    koopa_locate_app \
        --app-name='sed' \
        --homebrew-gnubin \
        --opt-name='gnu-sed'
}

koopa_locate_shellcheck() { # {{{1
    koopa_locate_app 'shellcheck'
}

koopa_locate_shunit2() { # {{{1
    koopa_locate_app 'shunit2'
}

koopa_locate_sshfs() { # {{{1
    koopa_locate_app 'sshfs'
}

koopa_locate_sort() { # {{{1
    koopa_locate_gnu_coreutils_app 'sort'
}

koopa_locate_sox() { # {{{1
    koopa_locate_app 'sox'
}

koopa_locate_sqlplus() { # {{{1
    koopa_locate_app 'sqlplus'
}

koopa_locate_ssh() { # {{{1
    koopa_locate_app \
        --app-name='ssh' \
        --opt-name='openssh'
}

koopa_locate_ssh_add() { # {{{1
    koopa_locate_app \
        --app-name='ssh-add' \
        --macos-app='/usr/bin/ssh-add' \
        --opt-name='openssh'
}

koopa_locate_ssh_keygen() { # {{{1
    koopa_locate_app \
        --app-name='ssh-keygen' \
        --opt-name='openssh'
}

koopa_locate_stack() { # {{{1
    koopa_locate_app \
        --app-name='stack' \
        --opt-name='haskell-stack'
}

koopa_locate_star() { # {{{1
    koopa_locate_conda_app \
        --app-name='STAR' \
        --env-name='star'
}

koopa_locate_stat() { # {{{1
    koopa_locate_gnu_coreutils_app 'stat'
}

koopa_locate_sudo() { # {{{1
    koopa_locate_app '/usr/bin/sudo'
}

koopa_locate_svn() { # {{{1
    koopa_locate_app 'svn'
}

koopa_locate_tac() { # {{{1
    koopa_locate_gnu_coreutils_app 'tac'
}

koopa_locate_tail() { # {{{1
    koopa_locate_gnu_coreutils_app 'tail'
}

koopa_locate_tar() { # {{{1
    koopa_locate_app \
        --app-name='tar' \
        --homebrew-gnubin \
        --opt-name='gnu-tar'
}

koopa_locate_tee() { # {{{1
    koopa_locate_gnu_coreutils_app 'tee'
}

koopa_locate_tex() { # {{{1
    koopa_locate_app \
        --app-name='tex' \
        --macos-app='/Library/TeX/texbin/tex'
}

koopa_locate_tlmgr() { # {{{1
    koopa_locate_app \
        --app-name='tlmgr' \
        --macos-app='/Library/TeX/texbin/tlmgr'
}

koopa_locate_touch() { # {{{1
    koopa_locate_gnu_coreutils_app 'touch'
}

koopa_locate_tr() { # {{{1
    koopa_locate_gnu_coreutils_app 'tr'
}

koopa_locate_uncompress() { # {{{1
    koopa_locate_app \
        --app-name='uncompress' \
        --homebrew-gnubin \
        --opt-name='gzip'
}

koopa_locate_uname() { # {{{1
    koopa_locate_gnu_coreutils_app 'uname'
}

koopa_locate_uniq() { # {{{1
    koopa_locate_gnu_coreutils_app 'uniq'
}

koopa_locate_unzip() { # {{{1
    koopa_locate_app 'unzip'
}

koopa_locate_vim() { # {{{1
    koopa_locate_app 'vim'
}

koopa_locate_wc() { # {{{1
    koopa_locate_gnu_coreutils_app 'wc'
}

koopa_locate_wget() { # {{{1
    koopa_locate_app 'wget'
}

koopa_locate_whoami() { # {{{1
    koopa_locate_gnu_coreutils_app 'whoami'
}

koopa_locate_xargs() { # {{{1
    koopa_locate_app \
        --app-name='xargs' \
        --homebrew-gnubin \
        --opt-name='findutils'
}

koopa_locate_yes() { # {{{1
    koopa_locate_gnu_coreutils_app 'yes'
}

koopa_locate_zcat() { # {{{1
    koopa_locate_app \
        --app-name='zcat' \
        --opt-name='gzip'
}
