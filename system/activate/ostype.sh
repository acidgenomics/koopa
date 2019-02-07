#!/bin/sh

# Operating system variables defined in uname.

# Operating system name.
OSNAME=$(uname -s)
export OSNAME

# Host name.
HOSTNAME=$(uname -n)
export HOSTNAME

case "$(uname -s)" in
    Darwin) export MACOS=1 && export UNIX=1;;
     Linux) export LINUX=1 && export UNIX=1;;
         *) echo "Unsupported operating system."; return 1;;
esac

# Microsoft Azure.
if quiet_expr "$HOSTNAME" "azlabapp"
then
    export AZURE=1
fi
