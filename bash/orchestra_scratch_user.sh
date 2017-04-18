# Create a user folder on the Orchestra scratch disk
# Requires an eCommons user identifier
user_dir=/n/scratch2/$(whoami)
mkdir -p "$user_dir"
chmod 700 "$user_dir"
ln -s "$user_dir" ~/scratch
