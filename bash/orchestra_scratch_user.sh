# Create a user folder on the Orchestra scratch disk
# Requires an eCommons user identifier
userDir=/n/scratch2/$(whoami)
mkdir -p "$userDir"
chmod 700 "$userDir"
ln -s "$userDir" ~/scratch
