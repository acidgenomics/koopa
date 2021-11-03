#!/usr/bin/env bash

# FIXME This is incorrectly unlinking current 17.0 release back to 16.10.
# FIXME Need to debug the steps here, seems to be detecting incorrect node
# or npm somewhere, linked to 16.10.

# FIXME Now seeing a weird 'npm audit' / 'npm audit fix' issue on macOS
# with node 17.0.1 and npm 8.1.2:
# 28 verbose stack Error: loadVirtual requires existing shrinkwrap file
# 28 verbose stack     at Arborist.loadVirtual (/opt/koopa/app/node-packages/17.0/lib/node_modules/npm/node_modules/@npmcli/arborist/lib/arborist/load-virtual.js:62:18)
# 28 verbose stack     at async Arborist.audit (/opt/koopa/app/node-packages/17.0/lib/node_modules/npm/node_modules/@npmcli/arborist/lib/arborist/audit.js:25:18)
# 28 verbose stack     at async Audit.audit (/opt/koopa/app/node-packages/17.0/lib/node_modules/npm/lib/audit.js:66:5)
# 29 verbose cwd /Users/mike
# 30 verbose Darwin 21.1.0
# 31 verbose argv "/usr/local/Cellar/node/17.0.1/bin/node" "/opt/koopa/opt/node-packages/bin/npm" "audit" "fix"
# 32 verbose node v17.0.1
# 33 verbose npm  v8.1.2
# 34 error code ENOLOCK
# 35 error audit This command requires an existing lockfile.
# 36 error audit Try creating one first with: npm i --package-lock-only
# 37 error audit Original error: loadVirtual requires existing shrinkwrap file

# FIXME Potentially relevant:
# https://stackoverflow.com/questions/65573579/how-to-fix-npm-audit-error-with-loadvirtual-and-enolock

# Debugging, here's what the values return:
# > ❯ npm config get package-lock
# true
# > ❯ npm config get shrinkwrap
# true

koopa::install_node_packages() { # {{{1
    koopa:::install_app_packages \
        --name-fancy='Node' \
        --name='node' \
        "$@"
}

# FIXME Use dict approach here and harden location of node / npm in calls.
koopa:::install_node_packages() { # {{{1
    # """
    # Install Node.js packages using npm.
    # @note Updated 2021-10-05.
    # @seealso
    # - npm help config
    # - npm help install
    # - npm config get prefix
    # """
    local node npm npm_version pkg pkg_lower pkgs prefix version
    koopa::assert_has_no_args "$#"
    prefix="${INSTALL_PREFIX:?}"
    koopa::configure_node
    # FIXME May need to debug this step, seems like activation is putting
    # wrong node / npm in path?
    koopa::activate_node
    node="$(koopa::locate_node)"
    npm="$(koopa::locate_npm)"
    # The npm install step will fail unless 'node' is in 'PATH'.
    koopa::add_to_path_start "$(koopa::dirname "$node")"
    # Ensure npm is configured to desired version.
    npm_version="$(koopa::variable 'node-npm')"
    "$npm" install -g "npm@${npm_version}"
    npm="${prefix}/bin/npm"
    koopa::assert_is_executable "$npm"
    pkgs=("$@")
    if [[ "${#pkgs[@]}" -eq 0 ]]
    then
        # NOTE 'tldr' conflicts with Rust 'tealdeer'.
        pkgs=(
            'gtop'
        )
        for i in "${!pkgs[@]}"
        do
            pkg="${pkgs[$i]}"
            pkg_lower="$(koopa::lowercase "$pkg")"
            version="$(koopa::variable "node-${pkg_lower}")"
            pkgs[$i]="${pkg}@${version}"
        done
    fi
    "$npm" install -g "${pkgs[@]}"
    return 0
}

koopa::uninstall_node_packages() { # {{{1
    # """
    # Uninstall Node.js packages.
    # @note Updated 2021-06-17.
    # """
    koopa:::uninstall_app \
        --name='node-packages' \
        --name-fancy='Node.js packages' \
        --no-link \
        "$@"
    }

koopa::update_node_packages() { # {{{1
    # """
    # Update Node.js packages.
    # @note Updated 2021-08-31.
    # """
    koopa::install_node_packages "$@"
}
