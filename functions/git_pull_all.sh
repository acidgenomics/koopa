wd=$(pwd)
for repo in $(find ${HOME}/git -type d -name ".git"); do
    repo=$(dirname "$repo")
    cd "$repo"
    pwd
    git pull --all
    git status
done
cd $wd
