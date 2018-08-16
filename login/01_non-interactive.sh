# Load non-interactive profile scripts
where="${KOOPA_DIR}/profile/non-interactive"
for file in $(find "$where" -type f -name "*.sh" ! -name ".*" | sort); do
    . "$file"
done
unset -v file where
