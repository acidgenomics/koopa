#!/usr/bin/env bash

main() {
    # """
    # Install Node.js.
    # @note Updated 2025-08-21.
    #
    # Corepack configuration gets saved to '~/.cache/node/corepack'.
    #
    # @seealso
    # - https://github.com/nodejs/release#release-schedule
    # - https://github.com/nodejs/node/blob/main/BUILDING.md
    # - https://github.com/nodejs/node/blob/main/doc/contributing/
    #     building-node-with-ninja.md
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/node.rb
    # - https://code.google.com/p/v8/wiki/BuildingWithGYP
    # - https://chromium.googlesource.com/external/github.com/v8/v8.wiki/+/
    #     c62669e6c70cc82c55ced64faf44804bd28f33d5/Building-with-Gyp.md
    # - https://v8.dev/docs/build-gn
    # - https://code.google.com/archive/p/pyv8/
    # - https://stackoverflow.com/questions/29773160/
    # - https://stackoverflow.com/questions/16215082/
    # - https://bugs.chromium.org/p/gyp/adminIntro
    # - https://github.com/nodejs/node-gyp
    # - https://github.com/conda-forge/nodejs-feedstock/blob/main/
    #     recipe/build.sh
    # - https://github.com/nodejs/gyp-next/actions/runs/711098809/workflow
    # - https://github.com/nodejs/corepack
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/nodejs.html
    # """
    local -A app dict
    local -a build_deps conf_args
    build_deps=('make' 'ninja' 'pkg-config' 'python')
    koopa_activate_app --build-only "${build_deps[@]}"
    app['make']="$(koopa_locate_make)"
    app['python']="$(koopa_locate_python --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--ninja'
        "--prefix=${dict['prefix']}"
        '--verbose'
    )
    # Ensure that subprocesses spawned by make are using our Python.
    export PYTHON="${app['python']}"
    # This is needed to put sysctl into PATH.
    if koopa_is_macos
    then
        koopa_add_to_path_end '/usr/sbin'
    fi
    dict['url']="https://nodejs.org/dist/v${dict['version']}/\
node-v${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    # Create 'yarn' symlink in 'bin'.
    (
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln \
            '../lib/node_modules/corepack/dist/yarn.js' \
            'yarn'
    )
    # Create 'npm.1' and 'npx.1' symlinks in 'man1'.
    (
        koopa_cd "${dict['prefix']}/share/man/man1"
        koopa_ln \
            '../../../lib/node_modules/npm/man/man1/npm.1' \
            'npm.1'
        koopa_ln \
            '../../../lib/node_modules/npm/man/man1/npx.1' \
            'npx.1'
    )
    return 0
}
