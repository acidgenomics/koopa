#!/usr/bin/env bash

main() {
    # """
    # Install GCC.
    # @note Updated 2023-10-09.
    #
    # Do not run './configure' from within the source directory.
    # Instead, you need to run configure from outside the source directory,
    # in a separate directory created for the build.
    #
    # Prerequisites:
    #
    # If you do not have the GMP, MPFR and MPC support libraries already
    # installed as part of your operating system then there are two simple ways
    # to proceed, and one difficult, error-prone way. For some reason most
    # people choose the difficult way. The easy ways are:
    #
    # If it provides sufficiently recent versions, use your OS package
    # management system to install the support libraries in standard system
    # locations.
    #
    # For Debian-based systems, including Ubuntu, you should install:
    # - libgmp-dev
    # - libmpc-dev
    # - libmpfr-dev
    #
    # For RPM-based systems, including Fedora and SUSE, you should install:
    # - gmp-devel
    # - libmpc-devel (or mpc-devel on SUSE)
    # - mpfr-devel
    #
    # The packages will install the libraries and headers in standard system
    # directories so they can be found automatically when building GCC.
    #
    # Alternatively, after extracting the GCC source archive, simply run the
    # './contrib/download_prerequisites' script in the GCC source directory.
    # That will download the support libraries and create symlinks, causing
    # them to be built automatically as part of the GCC build process.
    # Set 'GRAPHITE_LOOP_OPT=no' in the script if you want to build GCC without
    # ISL, which is only needed for the optional Graphite loop optimizations.
    #
    # The difficult way, which is not recommended, is to download the sources
    # for GMP, MPFR and MPC, then configure and install each of them in
    # non-standard locations.
    #
    # @seealso
    # - https://ftp.gnu.org/gnu/gcc/
    # - https://gcc.gnu.org/install/
    # - https://gcc.gnu.org/install/prerequisites.html
    # - https://gcc.gnu.org/wiki/InstallingGCC
    # - https://gcc.gnu.org/wiki/FAQ
    # - https://gcc.gnu.org/onlinedocs/gcc/Environment-Variables.html
    # - https://formulae.brew.sh/formula/gcc
    # - https://ports.macports.org/port/gcc13/
    # - https://github.com/fxcoudert/gfortran-for-macOS/blob/
    #     master/build_package.md
    # - https://solarianprogrammer.com/2019/10/12/compiling-gcc-macos/
    # - https://solarianprogrammer.com/2016/10/07/building-gcc-ubuntu-linux/
    # - https://medium.com/@darrenjs/building-gcc-from-source-dcc368a3bb70
    # - How to ensure @rpath gets baked correctly:
    #   https://www.linuxquestions.org/questions/linux-software-2/
    #     compiling-gcc-not-baking-rpath-correctly-4175661913/
    # """
    local -A app bool dict
    local -a build_deps conf_args deps langs
    build_deps=('make')
    deps=('gmp' 'mpfr' 'mpc' 'isl' 'zstd')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    bool['math_h_patch']=0
    dict['gmp']="$(koopa_app_prefix 'gmp')"
    dict['gnu_mirror']="$(koopa_gnu_mirror_url)"
    dict['isl']="$(koopa_app_prefix 'isl')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['mpc']="$(koopa_app_prefix 'mpc')"
    dict['mpfr']="$(koopa_app_prefix 'mpfr')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zstd']="$(koopa_app_prefix 'zstd')"
    dict['boot_ldflags']="-static-libstdc++ -static-libgcc ${LDFLAGS:?}"
    # Avoiding building:
    #  - Ada and D, which require a pre-existing GCC to bootstrap.
    #  - Go, currently not supported on macOS.
    #  - BRIG.
    # Consider adding 'jit' here, which is set in MacPorts.
    langs=('c' 'c++' 'fortran' 'objc' 'obj-c++')
    dict['langs']="$(koopa_paste0 --sep=',' "${langs[@]}")"
    conf_args=(
        # Can also define here:
        # > '--disable-tls'
        # > "--libiconv-prefix=XXX"
        # > "--program-suffix=-mp-${dict['maj_ver']}"
        # > "--with-ar=XXX"
        # > "--with-as=XXX"
        # > "--with-bugurl=XXX"
        # > "--with-ld=XXX"
        '-v'
        '--disable-nls'
        '--enable-checking=release'
        '--enable-host-shared'
        "--enable-languages=${dict['langs']}"
        '--enable-libstdcxx-time'
        '--enable-lto'
        "--prefix=${dict['prefix']}"
        '--with-build-config=bootstrap-debug'
        '--with-gcc-major-version-only'
        # Required dependencies.
        "--with-gmp=${dict['gmp']}"
        "--with-mpc=${dict['mpc']}"
        "--with-mpfr=${dict['mpfr']}"
        # Optional dependencies.
        "--with-isl=${dict['isl']}"
        "--with-zstd=${dict['zstd']}"
        # Ensure linkage is defined during bootstrap (stage 2).
        "--with-boot-ldflags=${dict['boot_ldflags']}"
    )
    if koopa_is_linux
    then
        conf_args+=(
            # Fix Linux error: gnu/stubs-32.h: No such file or directory.
            '--disable-multilib'
            # Enable to PIE by default to match what the host GCC uses.
            '--enable-default-pie'
        )
        dict['url']="${dict['gnu_mirror']}/gcc/gcc-${dict['version']}/\
gcc-${dict['version']}.tar.xz"
    elif koopa_is_macos
    then
        dict['clt_maj_ver']="$(koopa_macos_xcode_clt_major_version)"
        dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
        dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
        dict['maj_min_ver2']="${dict['maj_min_ver']//./-}"
        dict['sysroot']="$(koopa_macos_sdk_prefix)"
        koopa_assert_is_dir "${dict['sysroot']}"
        dict['url']="https://github.com/iains/gcc-${dict['maj_ver']}-branch/\
archive/refs/heads/gcc-${dict['maj_min_ver2']}-darwin.tar.gz"
        conf_args+=(
            '--with-native-system-header-dir=/usr/include'
            "--with-sysroot=${dict['sysroot']}"
            '--with-system-zlib'
        )
        if [[ "${dict['clt_maj_ver']}" -ge 15 ]]
        then
            bool['math_h_patch']=1
            app['ld']="$(koopa_macos_locate_ld_classic)"
            koopa_assert_is_executable "${app['ld']}"
            conf_args+=("--with-ld=${app['ld']}")
        fi
    fi
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    # Need to apply 'math.h' patch for macOS Sonoma CLT breaking changes.
    # See also:
    # - https://gcc.gnu.org/git/?p=gcc.git;a=commitdiff;
    #     h=93f803d53b5ccaabded9d7b4512b54da81c1c616
    # - https://github.com/Homebrew/homebrew-core/blob/
    #     57262c5e2233373537e8b32c00a2b03cec63e7a5/Formula/g/gcc.rb#L19
    # - https://github.com/Homebrew/brew/blob/master/Library/Homebrew/patch.rb
    # - https://www.gnu.org/software/diffutils/manual/html_node/
    #     Multiple-Patches.html
    # - fixincludes/fixincl.x
    #   https://gcc.gnu.org/git/?p=gcc.git;a=commitdiff;
    #     h=93f803d53b5ccaabded9d7b4512b54da81c1c616#patch1
    # - fixincludes/inclhack.def
    #   https://gcc.gnu.org/git/?p=gcc.git;a=commitdiff;
    #     h=93f803d53b5ccaabded9d7b4512b54da81c1c616#patch2
    # - fixincludes/tests/base/math.h
    #   https://gcc.gnu.org/git/?p=gcc.git;a=commitdiff;
    #     h=93f803d53b5ccaabded9d7b4512b54da81c1c616#patch3
    if [[ "${bool['math_h_patch']}" -eq 1 ]]
    then
        app['cat']="$(koopa_locate_cat --allow-system)"
        app['patch']="$(koopa_locate_patch)"
        koopa_assert_is_executable "${app[@]}"
        dict['patch_file']='patch-math-h.patch'
        (
            koopa_cd 'src'
            # Need to use cat here with quoted 'END' to avoid escaping of
            # backslashes. Attempting to read into string doesn't work right.
            "${app['cat']}" << 'END' > "${dict['patch_file']}"
diff --git a/fixincludes/fixincl.x b/fixincludes/fixincl.x
index 416d2c2e3a4ba5f84e9ec04d8e4fd4b13240cb2d..e52f11d8460f8ecf375a0949d2c2409a7854c5b3 100644 (file)
--- a/fixincludes/fixincl.x
+++ b/fixincludes/fixincl.x
@@ -2,11 +2,11 @@
  *
  * DO NOT EDIT THIS FILE   (fixincl.x)
  *
- * It has been AutoGen-ed  January 22, 2023 at 09:03:29 PM by AutoGen 5.18.12
+ * It has been AutoGen-ed  August 17, 2023 at 10:16:38 AM by AutoGen 5.18.12
  * From the definitions    inclhack.def
  * and the template file   fixincl
  */
-/* DO NOT SVN-MERGE THIS FILE, EITHER Sun Jan 22 21:03:29 CET 2023
+/* DO NOT SVN-MERGE THIS FILE, EITHER Thu Aug 17 10:16:38 CEST 2023
  *
  * You must regenerate it.  Use the ./genfixes script.
  *
@@ -3674,7 +3674,7 @@ tSCC* apzDarwin_Flt_Eval_MethodMachs[] = {
  *  content selection pattern - do fix if pattern found
  */
 tSCC zDarwin_Flt_Eval_MethodSelect0[] =
-       "^#if __FLT_EVAL_METHOD__ == 0$";
+       "^#if __FLT_EVAL_METHOD__ == 0( \\|\\| __FLT_EVAL_METHOD__ == -1)?$";
 
 #define    DARWIN_FLT_EVAL_METHOD_TEST_CT  1
 static tTestDesc aDarwin_Flt_Eval_MethodTests[] = {
@@ -3685,7 +3685,7 @@ static tTestDesc aDarwin_Flt_Eval_MethodTests[] = {
  */
 static const char* apzDarwin_Flt_Eval_MethodPatch[] = {
     "format",
-    "#if __FLT_EVAL_METHOD__ == 0 || __FLT_EVAL_METHOD__ == 16",
+    "%0 || __FLT_EVAL_METHOD__ == 16",
     (char*)NULL };
 
 /* * * * * * * * * * * * * * * * * * * * * * * * * *
diff --git a/fixincludes/inclhack.def b/fixincludes/inclhack.def
index 45e0cbc0c10b9666ce1e1a901ee4463ea0528d7e..19e0ea2df66270f015b867f2a67d7bc27c04d956 100644 (file)
--- a/fixincludes/inclhack.def
+++ b/fixincludes/inclhack.def
@@ -1819,10 +1819,11 @@ fix = {
     hackname  = darwin_flt_eval_method;
     mach      = "*-*-darwin*";
     files     = math.h;
-    select    = "^#if __FLT_EVAL_METHOD__ == 0$";
+    select    = "^#if __FLT_EVAL_METHOD__ == 0( \\|\\| __FLT_EVAL_METHOD__ == -1)?$";
     c_fix     = format;
-    c_fix_arg = "#if __FLT_EVAL_METHOD__ == 0 || __FLT_EVAL_METHOD__ == 16";
-    test_text = "#if __FLT_EVAL_METHOD__ == 0";
+    c_fix_arg = "%0 || __FLT_EVAL_METHOD__ == 16";
+    test_text = "#if __FLT_EVAL_METHOD__ == 0\n"
+		"#if __FLT_EVAL_METHOD__ == 0 || __FLT_EVAL_METHOD__ == -1";
 };
 
 /*
diff --git a/fixincludes/tests/base/math.h b/fixincludes/tests/base/math.h
index 29b67579748c5efbb88bc3285ee35ffe9800b55d..7b92f29a409f31ea05ca8141e15db70ea1b829a8 100644 (file)
--- a/fixincludes/tests/base/math.h
+++ b/fixincludes/tests/base/math.h
@@ -32,6 +32,7 @@
 
 #if defined( DARWIN_FLT_EVAL_METHOD_CHECK )
 #if __FLT_EVAL_METHOD__ == 0 || __FLT_EVAL_METHOD__ == 16
+#if __FLT_EVAL_METHOD__ == 0 || __FLT_EVAL_METHOD__ == -1 || __FLT_EVAL_METHOD__ == 16
 #endif  /* DARWIN_FLT_EVAL_METHOD_CHECK */
 
 
END
            "${app['patch']}" \
                --input="${dict['patch_file']}" \
                --strip=1 \
                --verbose
        )
    fi
    koopa_mkdir 'build'
    koopa_cd 'build'
    unset -v LIBRARY_PATH
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ../src/configure --help
    ../src/configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
