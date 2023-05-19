#!/usr/bin/env bash

main() {
    # """
    # Install spdlog.
    # @note Updated 2023-04-04.
    #
    # @seealso
    # - https://github.com/gabime/spdlog/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/spdlog.rb
    # - https://github.com/conda-forge/spdlog-feedstock
    # - https://raw.githubusercontent.com/archlinux/svntogit-community/
    #     packages/spdlog/trunk/PKGBUILD
    # """
    local -A app cmake dict
    local -a cmake_args
    koopa_activate_app --build-only 'patch' 'pkg-config'
    koopa_activate_app 'fmt'
    app['cat']="$(koopa_locate_cat --allow-system)"
    app['ctest']="$(koopa_locate_ctest)"
    app['patch']="$(koopa_locate_patch)"
    koopa_assert_is_executable "${app[@]}"
    dict['fmt']="$(koopa_app_prefix 'fmt')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_assert_is_dir "${dict['fmt']}"
    cmake['fmt_dir']="${dict['fmt']}/lib/cmake/fmt"
    koopa_assert_is_dir "${cmake['fmt_dir']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DSPDLOG_BUILD_BENCH=OFF'
        '-DSPDLOG_BUILD_SHARED=ON'
        '-DSPDLOG_BUILD_TESTS=ON'
        '-DSPDLOG_FMT_EXTERNAL=ON'
        # Dependency paths -----------------------------------------------------
        "-Dfmt_DIR=${cmake['fmt_dir']}"
    )
    dict['url']="https://github.com/gabime/spdlog/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'

    # Patch support for fmt 10.0.0.
    # https://github.com/gabime/spdlog/commit/0ca574ae168820da0268b3ec7607ca7b33024d05.patch?full_index=1"
    "${app['cat']}" << END > 'patch-fmt.patch'
From 0ca574ae168820da0268b3ec7607ca7b33024d05 Mon Sep 17 00:00:00 2001
From: H1X4 <10332146+H1X4Dev@users.noreply.github.com>
Date: Fri, 31 Mar 2023 20:39:32 +0300
Subject: [PATCH] fix build for master fmt (non-bundled) (#2694)

* fix build for master fmt (non-bundled)

* update fmt_runtime_string macro

* fix build of updated macro
---
 include/spdlog/common.h | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/spdlog/common.h b/include/spdlog/common.h
index e69201a81d13380eb2858c7c1fcf9207aeacc8aa..5f671c5c608dab0070512059af87909ced444574 100644
--- a/include/spdlog/common.h
+++ b/include/spdlog/common.h
@@ -173,12 +173,19 @@ using format_string_t = fmt::format_string<Args...>;
 template<class T>
 using remove_cvref_t = typename std::remove_cv<typename std::remove_reference<T>::type>::type;
 
+template <typename Char>
+#if FMT_VERSION >= 90101
+using fmt_runtime_string = fmt::runtime_format_string<Char>;
+#else
+using fmt_runtime_string = fmt::basic_runtime<Char>;
+#endif
+
 // clang doesn't like SFINAE disabled constructor in std::is_convertible<> so have to repeat the condition from basic_format_string here,
 // in addition, fmt::basic_runtime<Char> is only convertible to basic_format_string<Char> but not basic_string_view<Char>
 template<class T, class Char = char>
 struct is_convertible_to_basic_format_string
     : std::integral_constant<bool,
-          std::is_convertible<T, fmt::basic_string_view<Char>>::value || std::is_same<remove_cvref_t<T>, fmt::basic_runtime<Char>>::value>
+          std::is_convertible<T, fmt::basic_string_view<Char>>::value || std::is_same<remove_cvref_t<T>, fmt_runtime_string<Char>>::value>
 {};
 
 #    if defined(SPDLOG_WCHAR_FILENAMES) || defined(SPDLOG_WCHAR_TO_UTF8_SUPPORT)
END
    "${app['patch']}" \
        --unified \
        --verbose \
        'include/spdlog/common.h' \
        'patch-fmt.patch'
    # Patch diff created with:
    # > diff -u 'tweakme.h' 'tweakme.h-1' > 'patch-tweakme.patch'
    "${app['cat']}" << END > 'patch-tweakme.patch'
--- tweakme.h	2022-12-06 16:50:30
+++ tweakme.h-1	2022-12-06 16:51:32
@@ -80,6 +80,9 @@
 //
 // #define SPDLOG_FMT_EXTERNAL
 ///////////////////////////////////////////////////////////////////////////////
+#ifndef SPDLOG_FMT_EXTERNAL
+#define SPDLOG_FMT_EXTERNAL
+#endif
 
 ///////////////////////////////////////////////////////////////////////////////
 // Uncomment to use C++20 std::format instead of fmt. This removes compile
END
    "${app['patch']}" \
        --unified \
        --verbose \
        'include/spdlog/tweakme.h' \
        'patch-tweakme.patch'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
