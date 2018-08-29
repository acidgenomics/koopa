wd=$(pwd)
# Using `-L` flag here in case `~/git` is a symlink
for repo in $(find -L ${HOME}/git -type d -name ".git"); do
    repo=$(dirname "$repo")
    cd "$repo"
    pwd
    git pull --all
    git status
done
cd $wd

