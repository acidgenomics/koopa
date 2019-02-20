#!/bin/sh

# Check that platform is supported.

[ -z "$HOSTNAME" ] && HOSTNAME="$(uname -n)" && export HOSTNAME
[ -z "$OSNAME" ] && OSNAME="$(uname -s)" && export OSNAME

case "$OSNAME" in
    Darwin) export MACOS=1 && export UNIX=1;;
     Linux) export LINUX=1 && export UNIX=1;;
         *) echo "Unsupported operating system."; exit 1;;
esac

case "$HOSTNAME" in
                  azlabapp*) export AZURE=1;;
    *.o2.rc.hms.harvard.edu) export HARVARD_O2=1;;
       *.rc.fas.harvard.edu) export HARVARD_ODYSSEY=1;;
                          *) ;;
esac

KOOPA_PLATFORM="$(python -mplatform)" && export KOOPA_PLATFORM
