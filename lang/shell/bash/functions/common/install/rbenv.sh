#!/usr/bin/env bash

koopa::install_rbenv() { # {{{1
    koopa::install_app \
        --name='rbenv' \
        "$@"
}

koopa:::install_rbenv() { # {{{1
    # """
    # Install rbenv.
    # @note Updated 2021-05-05.
    # """
    local name prefix
    prefix="${INSTALL_PREFIX:?}"
    name='rbenv'
    koopa::mkdir "$prefix"
    git clone \
        "https://github.com/sstephenson/${name}.git" \
        "$prefix"
    koopa::mkdir "${prefix}/plugins"
    git clone \
        'https://github.com/sstephenson/ruby-build.git' \
        "${prefix}/plugins/ruby-build"
    return 0
}

koopa::install_rbenv_ruby() { # {{{1
    # """
    # Install latest verison of Ruby in rbenv.
    # @note Updated 2020-07-08.
    #
    # > rbenv install -l
    # > rbenv versions
    #
    # Ensure installation uses system OpenSSL.
    # > export RUBY_CONFIGURE_OPTS=--with-openssl-dir=/usr
    # """
    local name_fancy version
    koopa::assert_is_installed rbenv
    version="$(koopa::variable ruby)"
    # Ensure '2.6.5p' becomes '2.6.5', for example.
    version="$(koopa::sanitize_version "$version")"
    name_fancy="Ruby ${version}"
    koopa::install_start "$name_fancy"
    # Ensure ruby-build is current.
    ruby_build_dir="$(koopa::rbenv_prefix)/plugins/ruby-build"
    if [[ -d "$ruby_build_dir" ]]
    then
        koopa::alert_note "Updating ruby-build plugin: '${ruby_build_dir}'."
        (
            koopa::cd "$ruby_build_dir"
            git pull --quiet
        )
    fi
    rbenv install "$version"
    rbenv global "$version"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::update_rbenv() { # {{{1
    # """
    # Update rbenv.
    # @note Updated 2021-05-05.
    # """
    local exe name name_fancy prefix
    koopa::assert_has_no_args "$#"
    name='rbenv'
    name_fancy="$name"
    prefix="$(koopa::rbenv_prefix)"
    exe="${prefix}/bin/${name}"
    if ! koopa::is_installed "$exe"
    then
        koopa::alert_note "${name_fancy} is not installed at '${prefix}'."
        return 0
    fi
    koopa::update_start "$name_fancy"
    (
        koopa::cd "$prefix"
        git pull
    )
    koopa::update_success "$name_fancy"
    return 0
}
