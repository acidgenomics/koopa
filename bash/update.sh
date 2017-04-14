wd=$(pwd)
cd "$seqcloudDir"
git pull
cd "$wd"
echo "must log back in for changes to take effect"
exit 0
