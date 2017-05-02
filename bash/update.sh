wd=$(pwd)
cd "$seqcloud_dir"
git pull
cd "$wd"
echo "must log back in for changes to take effect"
exit 0
