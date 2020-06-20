#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# Emacs currently fails to build from source reliably inside Docker images.
#
# For example:
#
# Finding pointers to doc strings...
# Finding pointers to doc strings...done
# Dumping under the name emacs
# **************************************************
# Warning: Your system has a gap between BSS and the
# heap (29024367 bytes).  This usually means that exec-shield
# or something similar is in effect.  The dump may
# fail because of this.  See the section about
# exec-shield in etc/PROBLEMS for more information.
# **************************************************
# 12816512 of 33554432 static heap bytes used
# /bin/bash: line 1:  7508 Segmentation fault      (core dumped) 
#     ./temacs --batch --load loadup bootstrap
# make[1]: *** [bootstrap-emacs] Error 139
# Makefile:740: recipe for target 'bootstrap-emacs' failed
# make[1]: Leaving directory '/tmp/tmp.Os2bIejEX7/emacs/emacs-26.3/src'
# Makefile:421: recipe for target 'src' failed
# make: *** [src] Error 2
#
# The 'etc/PROBLEMS' file has some details on this issue.
# https://fossies.org/linux/emacs/etc/PROBLEMS
#
# 2877 *** Segfault during 'make'
# 2878 
# 2879 If Emacs segfaults when 'make' executes one of these commands:
# 2880 
# 2881   LC_ALL=C ./temacs -batch -l loadup bootstrap
# 2882   LC_ALL=C ./temacs -batch -l loadup dump
# 2883 
# 2884 the problem may be due to inadequate workarounds for address space
# 2885 layout randomization (ASLR), an operating system feature that
# 2886 randomizes the virtual address space of a process.  ASLR is commonly
# 2887 enabled in Linux and NetBSD kernels, and is intended to deter exploits
# 2888 of pointer-related bugs in applications.  If ASLR is enabled, the
# 2889 command:
# 2890 
# 2891    cat /proc/sys/kernel/randomize_va_space  # GNU/Linux
# 2892    sysctl security.pax.aslr.global          # NetBSD
# 2893 
# 2894 outputs a nonzero value.
# 2895 
# 2896 These segfaults should not occur on most modern systems, because the
# 2897 Emacs build procedure uses the command 'setfattr' or 'paxctl' to mark
# 2898 the Emacs executable as requiring non-randomized address space, and
# 2899 Emacs uses the 'personality' system call to disable address space
# 2900 randomization when dumping.  However, older kernels may not support
# 2901 'setfattr', 'paxctl', or 'personality', and newer Linux kernels have a
# 2902 secure computing mode (seccomp) that can be configured to disable the
# 2903 'personality' call.
# 2904 
# 2905 It may be possible to work around the 'personality' problem in a newer
# 2906 Linux kernel by configuring seccomp to allow the 'personality' call.
# 2907 For example, if you are building Emacs under Docker, you can run the
# 2908 Docker container with a security profile that allows 'personality' by
# 2909 using Docker's --security-opt option with an appropriate profile; see
# 2910 <https://docs.docker.com/engine/security/seccomp/>.
#
# See also:
# - https://askubuntu.com/questions/837306
# - http://debbugs.gnu.org/24682
# - https://github.com/travis-ci/travis-ci/issues/9073
# - https://github.com/flycheck/emacs-travis/issues/13
# - https://github.com/moby/moby/issues/22801
# """

_koopa_exit_if_docker
_koopa_assert_is_installed tee


file="emacs-${version}.tar.xz"
url="${gnu_mirror}/emacs/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "emacs-${version}" || exit 1
./configure \
    --prefix="$prefix" \
    --with-x-toolkit="no" \
    --with-xpm="no"
make --jobs="$jobs"
make install
