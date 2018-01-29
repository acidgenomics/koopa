if [[ -n "$PS1" && -n "$HPC" && -z "$INTERACTIVE_QUEUE" ]]; then
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
fi

# Alternate methods:
# https://www.gnu.org/software/bash/manual/html_node/Is-this-Shell-Interactive_003f.html
# case "$-" in
# *i*)	echo This shell is interactive ;;
# *)	echo This shell is not interactive ;;
# esac
#
# if [[ -z "$PS1" ]]; then
#         echo This shell is not interactive
# else
#         echo This shell is interactive
# fi
