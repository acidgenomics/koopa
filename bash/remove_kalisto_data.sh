find . -type d -name "kallisto" -print0 | xargs -0 -I {} rm -rf {}
