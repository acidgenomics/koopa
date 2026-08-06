# koopa admin

All commands in this section require sudo.

(koopa-admin-disable-passwordless-sudo)=
## `admin disable-passwordless-sudo`

Disable passwordless sudo for the current user.

(koopa-admin-enable-passwordless-sudo)=
## `admin enable-passwordless-sudo`

Enable passwordless sudo for the current user.

(koopa-admin-zsh-compaudit-set-permissions)=
## `admin zsh-compaudit-set-permissions`

Fix Zsh compaudit permissions.

## Linux-only

(koopa-admin-add-group)=
## `admin add-group name [--system]`

Add a system group.

(koopa-admin-add-user)=
## `admin add-user name [--home DIR] [--shell SHELL] [--system] [--sudo]`

Add a system user.

(koopa-admin-apk-install)=
## `admin apk-install packages...`

Install packages with apk (Alpine).

(koopa-admin-apk-remove)=
## `admin apk-remove packages...`

Remove packages with apk (Alpine).

(koopa-admin-apk-update)=
## `admin apk-update`

Update the apk package index (Alpine).

(koopa-admin-apt-install)=
## `admin apt-install packages...`

Install packages with apt (Debian/Ubuntu).

(koopa-admin-apt-list-installed)=
## `admin apt-list-installed`

List installed apt packages (Debian/Ubuntu).

(koopa-admin-apt-remove)=
## `admin apt-remove packages...`

Remove packages with apt (Debian/Ubuntu).

(koopa-admin-apt-update)=
## `admin apt-update`

Update the apt package index (Debian/Ubuntu).

(koopa-admin-apt-upgrade)=
## `admin apt-upgrade`

Upgrade installed packages with apt (Debian/Ubuntu).

(koopa-admin-configure-lmod)=
## `admin configure-lmod prefix`

Configure Lmod environment modules at a prefix.

(koopa-admin-configure-sshd)=
## `admin configure-sshd`

Configure sshd port and authentication settings.

(koopa-admin-delete-cache)=
## `admin delete-cache`

Delete cache, log, and temporary files (Docker images only).

(koopa-admin-delete-user)=
## `admin delete-user name [--remove-home]`

Delete a system user.

(koopa-admin-dnf-install)=
## `admin dnf-install packages...`

Install packages with dnf (Fedora/RHEL).

(koopa-admin-dnf-remove)=
## `admin dnf-remove packages...`

Remove packages with dnf (Fedora/RHEL).

(koopa-admin-dnf-update)=
## `admin dnf-update`

Update installed packages with dnf (Fedora/RHEL).

(koopa-admin-fix-sudo-setrlimit-error)=
## `admin fix-sudo-setrlimit-error`

Fix the sudo setrlimit error on Linux.

(koopa-admin-install-app)=
## `admin install-app name [--manager apt|dnf|apk|pacman|zypper]`

Install a package using the native OS package manager.

(koopa-admin-os-version)=
## `admin os-version`

Print the Linux OS version.

(koopa-admin-pacman-install)=
## `admin pacman-install packages...`

Install packages with pacman (Arch).

(koopa-admin-pacman-remove)=
## `admin pacman-remove packages...`

Remove packages with pacman (Arch).

(koopa-admin-pacman-update)=
## `admin pacman-update`

Update installed packages with pacman (Arch).

(koopa-admin-proc-cmdline)=
## `admin proc-cmdline`

Print the kernel boot command line (/proc/cmdline).

(koopa-admin-systemctl-disable)=
## `admin systemctl-disable service`

Disable a systemd service.

(koopa-admin-systemctl-restart)=
## `admin systemctl-restart service`

Restart a systemd service.

(koopa-admin-systemctl-status)=
## `admin systemctl-status service`

Print the status of a systemd service.

(koopa-admin-systemctl-stop)=
## `admin systemctl-stop service`

Stop a systemd service.

(koopa-admin-uninstall-app)=
## `admin uninstall-app name [--manager apt|dnf|apk|pacman|zypper]`

Uninstall a package using the native OS package manager.

(koopa-admin-zypper-install)=
## `admin zypper-install packages...`

Install packages with zypper (openSUSE).

(koopa-admin-zypper-remove)=
## `admin zypper-remove packages...`

Remove packages with zypper (openSUSE).

(koopa-admin-zypper-update)=
## `admin zypper-update`

Update installed packages with zypper (openSUSE).

## macOS-only

(koopa-admin-clean-launch-services)=
## `admin clean-launch-services`

Clean the macOS Launch Services database.

(koopa-admin-disable-touch-id-sudo)=
## `admin disable-touch-id-sudo`

Disable Touch ID for sudo authentication.

(koopa-admin-enable-touch-id-sudo)=
## `admin enable-touch-id-sudo`

Enable Touch ID for sudo authentication.

(koopa-admin-flush-dns)=
## `admin flush-dns`

Flush the DNS cache.

(koopa-admin-force-eject)=
## `admin force-eject volume-name`

Force eject a mounted volume.

(koopa-admin-reload-autofs)=
## `admin reload-autofs`

Reload the autofs automount daemon.

