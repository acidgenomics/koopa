if [[ -n "$PS1" && -n "$HPC" ]]; then
    echo ""
    echo "==== seqcloud ============================================================="
    # bcbio
    if [[ ! -z $BCBIO_DIR ]]; then
        echo "# bcbio"
        echo $BCBIO_DIR
        echo ""
    fi

    # Conda
    if [[ ! -z $CONDA_DIR ]]; then
        echo "# conda"
        echo $CONDA_DIR
        echo ""
    fi

    # Date
    echo "Last updated"
    wd="$PWD"
    cd "$SEQCLOUD_DIR"
    git log -1 --format=%cd
    cd "$wd"
    unset -v wd
    echo "==========================================================================="
    echo ""
fi

# Alternate methods:
# https://www.gnu.org/software/bash/manual/html_node/Is-this-Shell-Interactive_003f.html
# case "$-" in
# *i*)	echo This shell is interactive ;;
# *)	echo This shell is not interactive ;;
# esac
#
# if [ -z "$PS1" ]; then
#         echo This shell is not interactive
# else
#         echo This shell is interactive
# fi
