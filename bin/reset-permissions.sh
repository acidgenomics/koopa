#!/usr/bin/env bash
set -Eeuo pipefail

# Reset file permissions to match umask.
# Currently recommending umask 0002.

find . -type d -print0 | \
    xargs -0 -I {} chmod u=rwx,g=rwx,o=rx {}
find . -type f -print0 | \
    xargs -0 -I {} chmod u=rw,g=rw,o=r {}
find . -name "*.sh" -type f -print0 | \
    xargs -0 -I {} chmod u=rwx,g=rwx,o=rx {}
