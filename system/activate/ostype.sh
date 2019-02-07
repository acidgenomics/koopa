#!/bin/sh

# Detect operating system environment using uname.

OSNAME=$(uname -s)
export OSNAME

HOSTNAME=$(uname -n)
export HOSTNAME



case "$(uname -s)" in
    Darwin) export MACOS=1 && export UNIX=1;;
     Linux) export LINUX=1 && export UNIX=1;;
         *) echo "Unsupported operating system."; return 1;;
esac



case "$(uname -n)" in
                 azlabapp) export AZURE=1;;
    o2.rc.hms.harvard.edu) export HARVARD_O2=1;;
       rc.fas.harvard.edu) export HARVARD_ODYSSEY=1;;
                        *) ;;
esac
