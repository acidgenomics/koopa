#!/usr/bin/env bash


echo "WOOO HOOO"



# FIXME NEED POSIX

# Add local builds to PATH (e.g. '/usr/local').
# This will recurse through the local library and find 'bin/' subdirs.
# Note: read `-a` flag doesn't work on macOS. zsh related?
# Modified 2019-06-20.
add_local_bins_to_path() {
    local dir
    local dirs
    local prefix="$KOOPA_BUILD_PREFIX"
    add_to_path_start "${prefix}/bin"
    
    IFS=$'\n'
    read -r -d '' dirs <<< "$(find_local_bin_dirs)"
    unset IFS
    for dir in "${dirs[@]}"
    do
        add_to_path_start "$dir"
    done
}



# FIXME NEED POSIX

# Find local bin directories.
#
# See also:
# - https://stackoverflow.com/questions/23356779
# - https://stackoverflow.com/questions/7442417
#
# Modified 2019-06-17.
find_local_bin_dirs() {
    local array=()
    local tmp_file="${KOOPA_TMP_DIR}/find"

    find "$KOOPA_BUILD_PREFIX" \
        -mindepth 2 \
        -maxdepth 3 \
        -name "bin" \
        ! -path "*/Caskroom/*" \
        ! -path "*/Cellar/*" \
        ! -path "*/Homebrew/*" \
        ! -path "*/anaconda3/*" \
        ! -path "*/bcbio/*" \
        ! -path "*/lib/*" \
        ! -path "*/miniconda3/*" \
        -print0 > "$tmp_file"

    while IFS=  read -r -d $'\0'
    do
        array+=("$REPLY")
    done < "$tmp_file"
    rm -f "$tmp_file"

    # Sort the array.
    IFS=$'\n'
    local sorted=($(sort <<<"${array[*]}"))
    unset IFS

    printf "%s\n" "${sorted[@]}"
}



