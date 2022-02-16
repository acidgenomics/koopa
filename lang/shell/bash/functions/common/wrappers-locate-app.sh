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

koopa::locate_bedtools() { # {{{1
    koopa::locate_conda_app 'bedtools'
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

koopa::locate_efetch() { # {{{1
    koopa::locate_conda_app \
        --app-name='efetch' \
        --env-name='entrez-direct'
}

koopa::locate_esearch() { # {{{1
    koopa::locate_conda_app \
        --app-name='esearch' \
        --env-name='entrez-direct'
}

koopa::locate_emacs() { # {{{1
    koopa::locate_app 'emacs'
}

koopa::locate_exiftool() { # {{{1
    koopa::locate_app 'exiftool'
}

koopa::locate_fasterq_dump() { # {{{1
    koopa::locate_app \
        --app-name='fasterq-dump' \
        --opt='sratoolkit'
}

koopa::locate_fd() { # {{{1
    koopa::locate_app \
        --app-name='fd' \
        --brew-opt='fd' \
        --koopa-opt='rust-packages'
}

koopa::locate_ffmpeg() { # {{{1
    koopa::locate_app 'ffmpeg'
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
        [name]='gcc'
    )
    dict[version]="$(koopa::variable "${dict[name]}")"
    dict[maj_ver]="$(koopa::major_version "${dict[version]}")"
    koopa::locate_app \
        --app-name="${dict[name]}-${dict[maj_ver]}" \
        --opt="${dict[name]}@${dict[maj_ver]}"
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

koopa::locate_gnu_mv() { # {{{1
    koopa::locate_app 'mv'
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

koopa::locate_jq() { # {{{1
    koopa::locate_app 'jq'
}

koopa::locate_julia() { # {{{1
    koopa::locate_app \
        --app-name='julia' \
        --macos-app="$(koopa::macos_julia_prefix)/bin/julia"
}

koopa::locate_kallisto() { # {{{1
    koopa::locate_conda_app 'kallisto'
}

koopa::locate_less() { # {{{1
    koopa::locate_app 'less'
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
    if koopa::is_alpine
    then
        koopa::alpine_locate_localedef
    else
        koopa::locate_app '/usr/bin/localedef'
    fi
}

koopa::locate_ls() { # {{{1
    koopa::locate_gnu_coreutils_app 'ls'
}

koopa::locate_make() { # {{{1
    koopa::locate_app \
        --app-name='make' \
        --gnubin
}

koopa::locate_mamba() { # {{{1
    koopa::locate_app "$(koopa::conda_prefix)/bin/mamba"
}

koopa::locate_mamba_or_conda() { # {{{1
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
    koopa::locate_app \
        --app-name='man' \
        --gnubin \
        --opt='man-db'
}

koopa::locate_mashmap() { # {{{1
    koopa::locate_conda_app 'mashmap'
}

koopa::locate_md5sum() { # {{{1
    koopa::locate_gnu_coreutils_app 'md5sum'
}

koopa::locate_mkdir() { # {{{1
    koopa::locate_gnu_coreutils_app 'mkdir'
}

koopa::locate_mktemp() { # {{{1
    koopa::locate_app 'mktemp'
}

koopa::locate_mv() { # {{{1
    # """
    # @note macOS gmv currently has issues on NFS shares.
    # """
    koopa::locate_app '/bin/mv'
}

koopa::locate_neofetch() { # {{{1
    koopa::locate_app 'neofetch'
}

koopa::locate_newgrp() { # {{{1
    koopa::locate_app '/usr/bin/newgrp'
}

koopa::locate_nim() { # {{{1
    koopa::locate_app 'nim'
}

koopa::locate_node() { # {{{1
    koopa::locate_app 'node'
}

koopa::locate_npm() { # {{{1
    koopa::locate_app \
        --app-name='npm' \
        --brew-opt='node' \
        --koopa-opt='node-packages'
}

koopa::locate_openssl() { # {{{1
    koopa::locate_app 'openssl'
}

koopa::locate_parallel() { # {{{1
    koopa::locate_app 'parallel'
}

koopa::locate_passwd() { # {{{1
    koopa::locate_app '/usr/bin/passwd'
}

koopa::locate_paste() { # {{{1
    koopa::locate_gnu_coreutils_app 'paste'
}

koopa::locate_patch() { # {{{1
    koopa::locate_app \
        --app-name='patch' \
        --opt='gpatch'
}

koopa::locate_pcregrep() { # {{{1
    koopa::locate_app \
        --app-name='pcregrep' \
        --opt='pcre'
}

koopa::locate_perl() { # {{{1
    koopa::locate_app 'perl'
}

koopa::locate_perlbrew() { # {{{1
    koopa::locate_app 'perlbrew'
}

koopa::locate_pkg_config() { # {{{1
    koopa::locate_app 'pkg-config'
}

koopa::locate_prefetch() { # {{{1
    koopa::locate_app \
        --app-name='prefetch' \
        --opt='sratoolkit'
}

koopa::locate_python() { # {{{1
    local app dict
    declare -A app
    declare -A dict=(
        [macos_python_prefix]="$(koopa::macos_python_prefix)"
        [name]='python'
    )
    dict[version]="$(koopa::variable "${dict[name]}")"
    dict[maj_ver]="$(koopa::major_version "${dict[version]}")"
    app[python]="${dict[name]}${dict[maj_ver]}"
    koopa::locate_app \
        --app-name="${app[python]}" \
        --macos-app="${dict[macos_python_prefix]}/bin/${app[python]}"
}

koopa::locate_r() { # {{{1
    koopa::locate_app \
        --app-name='R' \
        --macos-app="$(koopa::macos_r_prefix)/bin/R"
}

koopa::locate_rscript() { # {{{1
    local app
    declare -A app=(
        [r]="$(koopa::locate_r)"
    )
    app[rscript]="${app[r]}script"
    koopa::locate_app "${app[rscript]}"
}

koopa::locate_readlink() { # {{{1
    koopa::locate_gnu_coreutils_app 'readlink'
}

koopa::locate_realpath() { # {{{1
    koopa::locate_gnu_coreutils_app 'realpath'
}

koopa::locate_rename() { # {{{1
    koopa::locate_app "$(koopa::perl_packages_prefix)/bin/rename"
}

koopa::locate_rg() { # {{{1
    koopa::locate_app \
        --app-name='rg' \
        --opt='ripgrep'
}

koopa::locate_rm() { # {{{1
    koopa::locate_app '/bin/rm'
}

koopa::locate_rsync() { # {{{1
    koopa::locate_app 'rsync'
}

koopa::locate_ruby() { # {{{1
    koopa::locate_app 'ruby'
}

koopa::locate_rustc() { # {{{1
    koopa::locate_app \
        --app-name='rustc' \
        --brew-opt='rust' \
        --koopa-opt='rust-packages'
}

koopa::locate_rustup() { # {{{1
    koopa::locate_app \
        --app-name='rustup' \
        --brew-opt='rustup' \
        --koopa-opt='rust-packages'
}

koopa::locate_salmon() { # {{{1
    koopa::locate_conda_app 'salmon'
}

koopa::locate_scp() { # {{{1
    koopa::locate_app \
        --app-name='scp' \
        --opt='openssh'
}

koopa::locate_sed() { # {{{1
    koopa::locate_app \
        --app-name='sed' \
        --gnubin \
        --opt='gnu-sed'
}

koopa::locate_sshfs() { # {{{1
    koopa::locate_app 'sshfs'
}

koopa::locate_sort() { # {{{1
    koopa::locate_gnu_coreutils_app 'sort'
}

koopa::locate_sox() { # {{{1
    koopa::locate_app 'sox'
}

koopa::locate_sqlplus() { # {{{1
    koopa::locate_app 'sqlplus'
}

koopa::locate_ssh() { # {{{1
    koopa::locate_app \
        --app-name='ssh' \
        --opt='openssh'
}

koopa::locate_ssh_add() { # {{{1
    koopa::locate_app \
        --app-name='ssh-add' \
        --macos-app='/usr/bin/ssh-add' \
        --opt='openssh'
}

koopa::locate_ssh_keygen() { # {{{1
    koopa::locate_app \
        --app-name='ssh-keygen' \
        --opt='openssh'
}

koopa::locate_stat() { # {{{1
    koopa::locate_gnu_coreutils_app 'stat'
}

koopa::locate_sudo() { # {{{1
    koopa::locate_app '/usr/bin/sudo'
}

koopa::locate_svn() { # {{{1
    koopa::locate_app 'svn'
}

koopa::locate_tac() { # {{{1
    koopa::locate_gnu_coreutils_app 'tac'
}

koopa::locate_tail() { # {{{1
    koopa::locate_gnu_coreutils_app 'tail'
}

koopa::locate_tar() { # {{{1
    koopa::locate_app \
        --app-name='tar' \
        --gnubin \
        --opt='gnu-tar'
}

koopa::locate_tee() { # {{{1
    koopa::locate_gnu_coreutils_app 'tee'
}

koopa::locate_tex() { # {{{1
    koopa::locate_app \
        --app-name='tex' \
        --macos-app='/Library/TeX/texbin/tex'
}

koopa::locate_tlmgr() { # {{{1
    koopa::locate_app \
        --app-name='tlmgr' \
        --macos-app='/Library/TeX/texbin/tlmgr'
}

koopa::locate_touch() { # {{{1
    koopa::locate_gnu_coreutils_app 'touch'
}

koopa::locate_tr() { # {{{1
    koopa::locate_gnu_coreutils_app 'tr'
}

koopa::locate_uncompress() { # {{{1
    koopa::locate_app \
        --app-name='uncompress' \
        --gnubin \
        --opt='gzip'
}

koopa::locate_uname() { # {{{1
    koopa::locate_gnu_coreutils_app 'uname'
}

koopa::locate_uniq() { # {{{1
    koopa::locate_gnu_coreutils_app 'uniq'
}

koopa::locate_unzip() { # {{{1
    koopa::locate_app 'unzip'
}

koopa::locate_vim() { # {{{1
    koopa::locate_app 'vim'
}

koopa::locate_wc() { # {{{1
    koopa::locate_gnu_coreutils_app 'wc'
}

koopa::locate_wget() { # {{{1
    koopa::locate_app 'wget'
}

koopa::locate_whoami() { # {{{1
    koopa::locate_gnu_coreutils_app 'whoami'
}

koopa::locate_xargs() { # {{{1
    koopa::locate_app \
        --app-name='xargs' \
        --gnubin \
        --opt='findutils'
}

koopa::locate_yes() { # {{{1
    koopa::locate_gnu_coreutils_app 'yes'
}

koopa::locate_zcat() { # {{{1
    koopa::locate_app \
        --app-name='zcat' \
        --opt='gzip'
}
