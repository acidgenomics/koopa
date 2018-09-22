dir="$1"

# Check that directory exists
if [[ ! -d "$dir" ]]; then
    echo "${dir} directory does not exist"
    return 1
fi

# Create disk image from directory.
# -ov = overwrite
hdiutil create -volname "$dir" -srcfolder "$dir" -ov "$dir".dmg
