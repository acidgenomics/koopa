#!/usr/bin/env bash

# FIXME Need to rebuild with dylib

main() {
    # """
    # Install Lua.
    # @note Updated 2022-09-09.
    #
    # @seealso
    # - http://www.lua.org/manual/
    # - https://github.com/Homebrew/legacy-homebrew/pull/5043
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'pkg-config'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['name']='lua'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="http://www.lua.org/ftp/${dict['file']}"
    if koopa_is_macos
    then
        dict['platform']='macosx'
    elif koopa_is_linux
    then
        dict['platform']='linux'
    fi
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    "${app['make']}" "${dict['platform']}"
    "${app['make']}" test
    "${app['make']}" install INSTALL_TOP="${dict['prefix']}"


  # Be sure to build a dylib, or else runtime modules will pull in another static copy of liblua = crashy
  # See: https://github.com/Homebrew/legacy-homebrew/pull/5043
  #patch do
  #  on_macos do
  #    url "https://raw.githubusercontent.com/Homebrew/formula-patches/11c8360432f471f74a9b2d76e012e3b36f30b871/lua/lua-dylib.patch"
  #    sha256 "a39e2ae1066f680e5c8bf1749fe09b0e33a0215c31972b133a73d43b00bf29dc"
  #  end

    # Add shared library for linux. Equivalent to the mac patch above.
    # Inspired from https://www.linuxfromscratch.org/blfs/view/cvs/general/lua.html
   # on_linux do
   #   url "https://raw.githubusercontent.com/Homebrew/formula-patches/0dcd11880c7d63eb395105a5cdddc1ca05b40f4a/lua/lua-so.patch"
   #   sha256 "522dc63a0c1d87bf127c992dfdf73a9267890fd01a5a17e2bcf06f7eb2782942"
   # end
  #end

    # We ship our own pkg-config file as Lua no longer provide them upstream.
    #libs = %w[-llua -lm]
    #libs << "-ldl" if OS.linux?
    #(lib/"pkgconfig/lua.pc").write <<~EOS
    #  V= #{version.major_minor}
    #  R= #{version}
    #  prefix=#{HOMEBREW_PREFIX}
    #  INSTALL_BIN= ${prefix}/bin
    #  INSTALL_INC= ${prefix}/include/lua
    #  INSTALL_LIB= ${prefix}/lib
    #  INSTALL_MAN= ${prefix}/share/man/man1
    #  INSTALL_LMOD= ${prefix}/share/lua/${V}
    #  INSTALL_CMOD= ${prefix}/lib/lua/${V}
    #  exec_prefix=${prefix}
    #  libdir=${exec_prefix}/lib
    #  includedir=${prefix}/include/lua
    #  Name: Lua
    #  Description: An Extensible Extension Language
    #  Version: #{version}
    #  Requires:
    #  Libs: -L${libdir} #{libs.join(" ")}
    #  Cflags: -I${includedir}
    #EOS
    # Fix some software potentially hunting for different pc names.
    #bin.install_symlink "lua" => "lua#{version.major_minor}"
    #bin.install_symlink "lua" => "lua-#{version.major_minor}"
    #bin.install_symlink "luac" => "luac#{version.major_minor}"
    #bin.install_symlink "luac" => "luac-#{version.major_minor}"
    #(include/"lua#{version.major_minor}").install_symlink Dir[include/"lua/*"]
    #lib.install_symlink shared_library("liblua", version.major_minor) => shared_library("liblua#{version.major_minor}")
    #(lib/"pkgconfig").install_symlink "lua.pc" => "lua#{version.major_minor}.pc"
    #(lib/"pkgconfig").install_symlink "lua.pc" => "lua-#{version.major_minor}.pc"
    return 0
}
