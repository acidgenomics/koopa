find . -mindepth 1 -maxdepth 1 -type d -exec tar -zcvf {}.tar.gz {} \;
