#!/bin/sh

# Check that Python is installed.

command -v python >/dev/null 2>&1 || {
    echo >&2 "koopa requires Python."
    return 1
}
