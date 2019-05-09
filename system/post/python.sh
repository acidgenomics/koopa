#!/bin/sh

# Check for supported Python version.

python_version="$(python --version 2>&1 | head -n 1 | cut -d " " -f 2)"
python_major_version="$(printf '%s' $python_version | cut -c 1)"

if [ "$python_major_version" -lt 3 ]
then
    echo "Python version: $python_version"
    echo "Koopa requires Python >= 3 to be installed."
    echo "Consider using a virtualenv or conda."
    return 1
fi
