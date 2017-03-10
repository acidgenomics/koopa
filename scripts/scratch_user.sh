# Create a user folder on the Orchestra scratch disk
# Requires an eCommons user identifier
scratch="/n/scratch2"
mkdir -p "$scratch"/"$1"
chmod 700 "$scratch"/"$1"
ln -s "$scratch"/"$1" ~/scratch
