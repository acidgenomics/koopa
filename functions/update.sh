wd=$(pwd)
cd "$KOOPA_DIR"
git pull
cd "$wd"
echo "Login shell must be reloaded for changes to take effect"
return 0
