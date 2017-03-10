find . -type d -name $2 -print0 | xargs -0 -I {} rm -rf {}
