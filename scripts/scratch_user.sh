# Create a user folder on the O2 scratch disk.
# Requires an eCommons user identifier.
if [[ $HPC == "HMS RC O2" ]]; then
    user_dir=/n/scratch2/$(whoami)
    mkdir -p "$user_dir"
    chmod 700 "$user_dir"
    ln -s "$user_dir" ~/scratch
else
    echo "HMS RC O2 cluster required"
    return 1
fi
unset -v user_dir
