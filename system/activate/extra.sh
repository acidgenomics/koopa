#!/bin/sh



# Readline                                                                  {{{1
# ==============================================================================

# Currently uses emacs by default.
# https://unix.stackexchange.com/questions/30454

# > case "$EDITOR" in
# >     emacs)
# >         set -o emacs
# >         ;;
# >     vi|vim)
# >         set -o vi
# >         ;;
# > esac



# umask                                                                     {{{1
# ==============================================================================

# Set default file permissions.
#
# - `umask`: Files and directories.
# - `fmask`: Only files.
# - `dmask`: Only directories.
#
# Use `umask -S` to return `u,g,o` values.
#
# - 0022: u=rwx,g=rx,o=rx
#         User can write, others can read. Usually default.
# - 0002: u=rwx,g=rwx,o=rx
#         User and group can write, others can read.
#         Recommended setting in a shared coding environment.
# - 0077: u=rwx,g=,o=
#         User alone can read/write. More secure.
#
# Access control lists (ACLs) are sometimes preferable to umask.
# Here's how to use ACLs with setfacl.
# setfacl -d -m group:name:rwx /dir
#
# See also:
# - https://stackoverflow.com/questions/13268796
# - https://askubuntu.com/questions/44534
umask 0002

