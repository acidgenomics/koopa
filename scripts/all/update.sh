wd=$(pwd)
cd "$KOOPA_BASEDIR"
git pull
cd "$wd"

cat << EOF
koopa updated successfully.
Login shell must be reloaded for changes to take effect.
EOF
