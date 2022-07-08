#!/usr/bin/env bash

koopa_uninstall_coreutils() {
    local uninstall_args
    uninstall_args=(
        '--name=coreutils'
        '--unlink-in-bin=['
        '--unlink-in-bin=b2sum'
        '--unlink-in-bin=base32'
        '--unlink-in-bin=base64'
        '--unlink-in-bin=basename'
        '--unlink-in-bin=basenc'
        '--unlink-in-bin=cat'
        '--unlink-in-bin=chcon'
        '--unlink-in-bin=chgrp'
        '--unlink-in-bin=chmod'
        '--unlink-in-bin=chown'
        '--unlink-in-bin=chroot'
        '--unlink-in-bin=cksum'
        '--unlink-in-bin=comm'
        '--unlink-in-bin=cp'
        '--unlink-in-bin=csplit'
        '--unlink-in-bin=cut'
        '--unlink-in-bin=date'
        '--unlink-in-bin=dd'
        '--unlink-in-bin=df'
        '--unlink-in-bin=dir'
        '--unlink-in-bin=dircolors'
        '--unlink-in-bin=dirname'
        '--unlink-in-bin=du'
        '--unlink-in-bin=echo'
        '--unlink-in-bin=env'
        '--unlink-in-bin=expand'
        '--unlink-in-bin=expr'
        '--unlink-in-bin=factor'
        '--unlink-in-bin=false'
        '--unlink-in-bin=fmt'
        '--unlink-in-bin=fold'
        '--unlink-in-bin=groups'
        '--unlink-in-bin=head'
        '--unlink-in-bin=hostid'
        '--unlink-in-bin=id'
        '--unlink-in-bin=install'
        '--unlink-in-bin=join'
        '--unlink-in-bin=kill'
        '--unlink-in-bin=link'
        '--unlink-in-bin=ln'
        '--unlink-in-bin=logname'
        '--unlink-in-bin=ls'
        '--unlink-in-bin=md5sum'
        '--unlink-in-bin=mkdir'
        '--unlink-in-bin=mkfifo'
        '--unlink-in-bin=mknod'
        '--unlink-in-bin=mktemp'
        '--unlink-in-bin=mv'
        '--unlink-in-bin=nice'
        '--unlink-in-bin=nl'
        '--unlink-in-bin=nohup'
        '--unlink-in-bin=nproc'
        '--unlink-in-bin=numfmt'
        '--unlink-in-bin=od'
        '--unlink-in-bin=paste'
        '--unlink-in-bin=pathchk'
        '--unlink-in-bin=pinky'
        '--unlink-in-bin=pr'
        '--unlink-in-bin=printenv'
        '--unlink-in-bin=printf'
        '--unlink-in-bin=ptx'
        '--unlink-in-bin=pwd'
        '--unlink-in-bin=readlink'
        '--unlink-in-bin=realpath'
        '--unlink-in-bin=rm'
        '--unlink-in-bin=rmdir'
        '--unlink-in-bin=runcon'
        '--unlink-in-bin=seq'
        '--unlink-in-bin=sha1sum'
        '--unlink-in-bin=sha224sum'
        '--unlink-in-bin=sha256sum'
        '--unlink-in-bin=sha384sum'
        '--unlink-in-bin=sha512sum'
        '--unlink-in-bin=shred'
        '--unlink-in-bin=shuf'
        '--unlink-in-bin=sleep'
        '--unlink-in-bin=sort'
        '--unlink-in-bin=split'
        '--unlink-in-bin=stat'
        '--unlink-in-bin=stty'
        '--unlink-in-bin=sum'
        '--unlink-in-bin=sync'
        '--unlink-in-bin=tac'
        '--unlink-in-bin=tail'
        '--unlink-in-bin=tee'
        '--unlink-in-bin=test'
        '--unlink-in-bin=timeout'
        '--unlink-in-bin=touch'
        '--unlink-in-bin=tr'
        '--unlink-in-bin=true'
        '--unlink-in-bin=truncate'
        '--unlink-in-bin=tsort'
        '--unlink-in-bin=tty'
        '--unlink-in-bin=uname'
        '--unlink-in-bin=unexpand'
        '--unlink-in-bin=uniq'
        '--unlink-in-bin=unlink'
        '--unlink-in-bin=uptime'
        '--unlink-in-bin=users'
        '--unlink-in-bin=vdir'
        '--unlink-in-bin=wc'
        '--unlink-in-bin=who'
        '--unlink-in-bin=whoami'
        '--unlink-in-bin=yes'
    )
    koopa_uninstall_app "${uninstall_args[@]}" "$@"
}
