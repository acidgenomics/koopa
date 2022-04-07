#!/usr/bin/env bash

# FIXME Need to add support for (see common/locate-wrappers.sh for details):
# - gnupg (gpg, gpg_agent, gpgconf)

# FIXME Need to link components from:
#        koopa_activate_homebrew_opt_prefix 'curl'
#        koopa_activate_homebrew_opt_libexec_prefix 'man-db'
#        koopa_activate_homebrew_opt_gnu_prefix \
#            'coreutils' \
#            'findutils' \
#            'gnu-sed' \
#            'gnu-tar' \
#            'gnu-which' \
#            'grep'

koopa_macos_link_homebrew_opt() { # {{{1
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [brew_opt]="$(koopa_homebrew_opt_prefix)"
    )
    dict[coreutils]="${dict[brew_opt]}/coreutils/libexec/gnubin"
    dict[findutils]="${dict[brew_opt]}/findutils/libexec/gnubin"
    koopa_link_in_bin \
        "${dict[coreutils]}/[" '[' \
        "${dict[coreutils]}/b2sum" 'b2sum' \
        "${dict[coreutils]}/base32" 'base32' \
        "${dict[coreutils]}/base64" 'base64' \
        "${dict[coreutils]}/basename" 'basename' \
        "${dict[coreutils]}/basenc" 'basenc' \
        "${dict[coreutils]}/cat" 'cat' \
        "${dict[coreutils]}/chcon" 'chcon' \
        "${dict[coreutils]}/chgrp" 'chgrp' \
        "${dict[coreutils]}/chmod" 'chmod' \
        "${dict[coreutils]}/chown" 'chown' \
        "${dict[coreutils]}/chroot" 'chroot' \
        "${dict[coreutils]}/cksum" 'cksum' \
        "${dict[coreutils]}/comm" 'comm' \
        "${dict[coreutils]}/cp" 'cp' \
        "${dict[coreutils]}/csplit" 'csplit' \
        "${dict[coreutils]}/cut" 'cut' \
        "${dict[coreutils]}/date" 'date' \
        "${dict[coreutils]}/dd" 'dd' \
        "${dict[coreutils]}/df" 'df' \
        "${dict[coreutils]}/dir" 'dir' \
        "${dict[coreutils]}/dircolors" 'dircolors' \
        "${dict[coreutils]}/dirname" 'dirname' \
        "${dict[coreutils]}/du" 'du' \
        "${dict[coreutils]}/echo" 'echo' \
        "${dict[coreutils]}/env" 'env' \
        "${dict[coreutils]}/expand" 'expand' \
        "${dict[coreutils]}/expr" 'expr' \
        "${dict[coreutils]}/factor" 'factor' \
        "${dict[coreutils]}/false" 'false' \
        "${dict[coreutils]}/fmt" 'fmt' \
        "${dict[coreutils]}/fold" 'fold' \
        "${dict[coreutils]}/groups" 'groups' \
        "${dict[coreutils]}/head" 'head' \
        "${dict[coreutils]}/hostid" 'hostid' \
        "${dict[coreutils]}/id" 'id' \
        "${dict[coreutils]}/install" 'install' \
        "${dict[coreutils]}/join" 'join' \
        "${dict[coreutils]}/kill" 'kill' \
        "${dict[coreutils]}/link" 'link' \
        "${dict[coreutils]}/ln" 'ln' \
        "${dict[coreutils]}/logname" 'logname' \
        "${dict[coreutils]}/ls" 'ls' \
        "${dict[coreutils]}/md5sum" 'md5sum' \
        "${dict[coreutils]}/mkdir" 'mkdir' \
        "${dict[coreutils]}/mkfifo" 'mkfifo' \
        "${dict[coreutils]}/mknod" 'mknod' \
        "${dict[coreutils]}/mktemp" 'mktemp' \
        "${dict[coreutils]}/mv" 'mv' \
        "${dict[coreutils]}/nice" 'nice' \
        "${dict[coreutils]}/nl" 'nl' \
        "${dict[coreutils]}/nohup" 'nohup' \
        "${dict[coreutils]}/nproc" 'nproc' \
        "${dict[coreutils]}/numfmt" 'numfmt' \
        "${dict[coreutils]}/od" 'od' \
        "${dict[coreutils]}/paste" 'paste' \
        "${dict[coreutils]}/pathchk" 'pathchk' \
        "${dict[coreutils]}/pinky" 'pinky' \
        "${dict[coreutils]}/pr" 'pr' \
        "${dict[coreutils]}/printenv" 'printenv' \
        "${dict[coreutils]}/printf" 'printf' \
        "${dict[coreutils]}/ptx" 'ptx' \
        "${dict[coreutils]}/pwd" 'pwd' \
        "${dict[coreutils]}/readlink" 'readlink' \
        "${dict[coreutils]}/realpath" 'realpath' \
        "${dict[coreutils]}/rm" 'rm' \
        "${dict[coreutils]}/rmdir" 'rmdir' \
        "${dict[coreutils]}/runcon" 'runcon' \
        "${dict[coreutils]}/seq" 'seq' \
        "${dict[coreutils]}/sha1sum" 'sha1sum' \
        "${dict[coreutils]}/sha224sum" 'sha224sum' \
        "${dict[coreutils]}/sha256sum" 'sha256sum' \
        "${dict[coreutils]}/sha384sum" 'sha384sum' \
        "${dict[coreutils]}/sha512sum" 'sha512sum' \
        "${dict[coreutils]}/shred" 'shred' \
        "${dict[coreutils]}/shuf" 'shuf' \
        "${dict[coreutils]}/sleep" 'sleep' \
        "${dict[coreutils]}/sort" 'sort' \
        "${dict[coreutils]}/split" 'split' \
        "${dict[coreutils]}/stat" 'stat' \
        "${dict[coreutils]}/stdbuf" 'stdbuf' \
        "${dict[coreutils]}/stty" 'stty' \
        "${dict[coreutils]}/sum" 'sum' \
        "${dict[coreutils]}/sync" 'sync' \
        "${dict[coreutils]}/tac" 'tac' \
        "${dict[coreutils]}/tail" 'tail' \
        "${dict[coreutils]}/tee" 'tee' \
        "${dict[coreutils]}/test" 'test' \
        "${dict[coreutils]}/timeout" 'timeout' \
        "${dict[coreutils]}/touch" 'touch' \
        "${dict[coreutils]}/tr" 'tr' \
        "${dict[coreutils]}/true" 'true' \
        "${dict[coreutils]}/truncate" 'truncate' \
        "${dict[coreutils]}/tsort" 'tsort' \
        "${dict[coreutils]}/tty" 'tty' \
        "${dict[coreutils]}/uname" 'uname' \
        "${dict[coreutils]}/unexpand" 'unexpand' \
        "${dict[coreutils]}/uniq" 'uniq' \
        "${dict[coreutils]}/unlink" 'unlink' \
        "${dict[coreutils]}/uptime" 'uptime' \
        "${dict[coreutils]}/users" 'users' \
        "${dict[coreutils]}/vdir" 'vdir' \
        "${dict[coreutils]}/wc" 'wc' \
        "${dict[coreutils]}/who" 'who' \
        "${dict[coreutils]}/whoami" 'whoami' \
        "${dict[coreutils]}/yes" 'yes' \
        "${dict[findutils]}/find" 'find' \
        "${dict[findutils]}/locate" 'locate' \
        "${dict[findutils]}/updatedb" 'updatedb' \
        "${dict[findutils]}/xargs" 'xargs'
}

koopa_macos_link_bbedit() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_link_in_bin \
        '/Applications/BBEdit.app/Contents/Helpers/bbedit_tool' \
        'bbedit'
    return 0
}

koopa_macos_link_emacs() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_link_in_bin \
        '/Applications/Emacs.app/Contents/MacOS/Emacs' \
        'emacs'
    return 0
}

koopa_macos_link_google_cloud_sdk() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_link_in_bin \
        "$(koopa_homebrew_prefix)/Caskroom/google-cloud-sdk/latest/\
google-cloud-sdk/bin/gcloud" \
        'gcloud'
    return 0
}

koopa_macos_link_julia() { # {{{1
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [julia_prefix]="$(koopa_macos_julia_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
    )
    koopa_link_in_bin \
        "${dict[julia_prefix]}/bin/julia" \
        'julia'
    return 0
}

koopa_macos_link_r() { # {{{1
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [r_prefix]="$(koopa_macos_r_prefix)"
    )
    koopa_link_in_bin \
        "${dict[r_prefix]}/bin/R" 'R' \
        "${dict[r_prefix]}/bin/Rscript" 'Rscript'
    return 0
}

koopa_macos_link_visual_studio_code() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_link_in_bin \
        '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code' \
        'code'
    return 0
}

koopa_macos_unlink_bbedit() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_unlink_in_bin 'bbedit'
    return 0
}

koopa_macos_unlink_homebrew_opt() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_unlink_in_bin \
        '['
        'b2sum' \
        'base32' \
        'base64' \
        'basename' \
        'basenc' \
        'cat' \
        'chcon' \
        'chgrp' \
        'chmod' \
        'chown' \
        'chroot' \
        'cksum' \
        'comm' \
        'cp' \
        'csplit' \
        'cut' \
        'date' \
        'dd' \
        'df' \
        'dir' \
        'dircolors' \
        'dirname' \
        'du' \
        'echo' \
        'env' \
        'expand' \
        'expr' \
        'factor' \
        'false' \
        'find' \
        'fmt' \
        'fold' \
        'groups' \
        'head' \
        'hostid' \
        'id' \
        'install' \
        'join' \
        'kill' \
        'link' \
        'ln' \
        'locate' \
        'logname' \
        'ls' \
        'md5sum' \
        'mkdir' \
        'mkfifo' \
        'mknod' \
        'mktemp' \
        'mv' \
        'nice' \
        'nl' \
        'nohup' \
        'nproc' \
        'numfmt' \
        'od' \
        'paste' \
        'pathchk' \
        'pinky' \
        'pr' \
        'printenv' \
        'printf' \
        'ptx' \
        'pwd' \
        'readlink' \
        'realpath' \
        'rm' \
        'rmdir' \
        'runcon' \
        'seq' \
        'sha1sum' \
        'sha224sum' \
        'sha256sum' \
        'sha384sum' \
        'sha512sum' \
        'shred' \
        'shuf' \
        'sleep' \
        'sort' \
        'split' \
        'stat' \
        'stdbuf' \
        'stty' \
        'sum' \
        'sync' \
        'tac' \
        'tail' \
        'tee' \
        'test' \
        'timeout' \
        'touch' \
        'tr' \
        'true' \
        'truncate' \
        'tsort' \
        'tty' \
        'uname' \
        'unexpand' \
        'uniq' \
        'unlink' \
        'updatedb' \
        'uptime' \
        'users' \
        'vdir' \
        'wc' \
        'who' \
        'whoami' \
        'xargs' \
        'yes'
    return 0
}
