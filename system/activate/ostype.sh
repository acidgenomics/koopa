#!/bin/ssh

# Check for supported operating system.
# Alternatively, can match against $OSTYPE.

case "$(uname -s)" in
    Darwin) export MACOS=1 && export UNIX=1;;
     Linux) export LINUX=1 && export UNIX=1;;
         *) echo "Unsupported operating system."; return 1;;
esac
