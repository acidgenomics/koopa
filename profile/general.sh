alias e="exit"
alias i="seqcloud interactive"
alias la="ls -a"
alias lF="ls -F"
alias ll="ls -lh"

# rsync
# -a, --archive               archive mode; equals -rlptgoD (no -H,-A,-X)
# -z, --compress              compress file data during the transfer
# -L, --copy-links            transform symlink into referent file/dir
#     --delete-before         receiver deletes before xfer, not during
# -h, --human-readable        output numbers in a human-readable format
#     --iconv=CONVERT_SPEC    request charset conversion of filenames
#     --progress              show progress during transfer
# -r, --recursive             recurse into directories
# -t, --times                 preserve modification times
rsync_flags="--archive --human-readable --progress --recursive --times"

today=$(date +%Y-%m-%d)
