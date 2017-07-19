# Fix default permissions
chown -R $USER *
find . -type f -print0 | xargs -0 -I {} chmod u=rw,g=rw,o=r {}
find . -type d -print0 | xargs -0 -I {} chmod u=rwx,g=rws,o=rx {}
