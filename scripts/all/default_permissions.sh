# Fix default permissions.

chown -R "$USER" *
find . -type f -print0 | xargs -0 -I {} chmod u=rw,g=rw,o=r {}
find . -type d -print0 | xargs -0 -I {} chmod u=rwx,g=rws,o=rx {}

# macOS mode
# sudo find . -mindepth 1 -exec chown 501:20 {} \;
# sudo find . -type f -mindepth 1 -exec chmod 644 {} \;
# sudo find . -type d -mindepth 1 -exec chmod 755 {} \;
