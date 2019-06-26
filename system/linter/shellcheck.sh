#!/usr/bin/env bash
set -Eeu -o pipefail

# Recursively run shellcheck on all scripts in a directory.
# Modified 2019-06-26.

path="${1:-$PWD}"

# Legacy method:
# > find "$path" -name "*.sh" -exec shellcheck {} \;

# This step recursively grep matches files with regular expressions.
# Here we're checking for the shebang, rather than relying on file extension.
grep -Elr \
    --binary-files="without-match" \
    --exclude-dir={cellar,conda} \
    '#!/usr/bin/env (ba)?sh' \
    "$path" | \
    xargs -I {} shellcheck -x {}
