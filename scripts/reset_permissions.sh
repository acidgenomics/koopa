sudo find . -mindepth 1 -exec chown 501:20 {} \;
sudo find . -type f -mindepth 1 -exec chmod 644 {} \;
sudo find . -type d -mindepth 1 -exec chmod 755 {} \;
