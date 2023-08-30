#!/usr/bin/env bash

# FIXME Can remove our patch code with the next radian update.

main() {
    # """
    # Install radian with patch for improved 'ldpaths' handling on macOS.
    # @note Updated 2023-05-30.
    #
    # @seealso
    # - https://github.com/randy3k/radian/pull/417
    # """
    local -A app dict
    koopa_activate_ca_certificates
    app['cat']="$(koopa_locate_cat --allow-system)"
    app['patch']="$(koopa_locate_patch)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    case "${dict['version']}" in
        '0.6.5')
            dict['hash']="01/c0/\
f2cd7bff1bc507e348925e357b714f407262dda073f2049737ab4721aef8"
            ;;
        *)
            koopa_stop 'Unsupported version.'
            ;;
    esac
    dict['url']="https://files.pythonhosted.org/packages/${dict['hash']}/\
radian-${dict['version']}.tar.gz"
    koopa_python_create_venv --prefix="${dict['libexec']}"
    app['python']="${dict['libexec']}/bin/python3"
    koopa_assert_is_executable "${app['python']}"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    "${app['cat']}" << END > 'app.patch'
--- app.py	2023-05-02 15:11:42
+++ app.py-1	2023-05-02 15:10:59
@@ -75,36 +75,36 @@
     if not r_home:
         raise RuntimeError("Cannot find R binary. Expose it via the \`PATH\` variable.")
 
-    if sys.platform.startswith("linux"):
+    libPath = os.path.join(r_home, "lib")
+    ldpaths = os.path.join(r_home, "etc", "ldpaths")
+    if "R_LD_LIBRARY_PATH" not in os.environ or libPath not in os.environ["R_LD_LIBRARY_PATH"]:
+        if os.path.exists(ldpaths):
+            R_LD_LIBRARY_PATH = subprocess.check_output(
+                ". \\"{}\\"; echo \$R_LD_LIBRARY_PATH".format(ldpaths),
+                shell=True
+            ).decode("utf-8").strip()
+        elif "R_LD_LIBRARY_PATH" in os.environ:
+            R_LD_LIBRARY_PATH = os.environ["R_LD_LIBRARY_PATH"]
+        else:
+            R_LD_LIBRARY_PATH = libPath
+        if libPath not in R_LD_LIBRARY_PATH:
+            R_LD_LIBRARY_PATH = "{}:{}".format(libPath, R_LD_LIBRARY_PATH)
+        os.environ['R_LD_LIBRARY_PATH'] = R_LD_LIBRARY_PATH
         # respect R_ARCH variable?
-        libPath = os.path.join(r_home, "lib")
-        ldpaths = os.path.join(r_home, "etc", "ldpaths")
-        if "R_LD_LIBRARY_PATH" not in os.environ or libPath not in os.environ["R_LD_LIBRARY_PATH"]:
-            if os.path.exists(ldpaths):
-                R_LD_LIBRARY_PATH = subprocess.check_output(
-                    ". \\"{}\\"; echo \$R_LD_LIBRARY_PATH".format(ldpaths),
-                    shell=True
-                ).decode("utf-8").strip()
-            elif "R_LD_LIBRARY_PATH" in os.environ:
-                R_LD_LIBRARY_PATH = os.environ["R_LD_LIBRARY_PATH"]
-            else:
-                R_LD_LIBRARY_PATH = libPath
+        if sys.platform == "darwin":
+            ld_library_var = "DYLD_FALLBACK_LIBRARY_PATH"
+        else:
+            ld_library_var = "LD_LIBRARY_PATH"
+        if ld_library_var in os.environ:
+            LD_LIBRARY_PATH = "{}:{}".format(R_LD_LIBRARY_PATH, os.environ[ld_library_var])
+        else:
+            LD_LIBRARY_PATH = R_LD_LIBRARY_PATH
+        os.environ[ld_library_var] = LD_LIBRARY_PATH
+        if sys.argv[0].endswith("radian"):
+            os.execv(sys.argv[0], sys.argv)
+        else:
+            os.execv(sys.executable, [sys.executable, "-m", "radian"] + sys.argv[1:])
 
-            if libPath not in R_LD_LIBRARY_PATH:
-                R_LD_LIBRARY_PATH = "{}:{}".format(libPath, R_LD_LIBRARY_PATH)
-
-            os.environ['R_LD_LIBRARY_PATH'] = R_LD_LIBRARY_PATH
-
-            if "LD_LIBRARY_PATH" in os.environ:
-                LD_LIBRARY_PATH = "{}:{}".format(R_LD_LIBRARY_PATH, os.environ["LD_LIBRARY_PATH"])
-            else:
-                LD_LIBRARY_PATH = R_LD_LIBRARY_PATH
-            os.environ['LD_LIBRARY_PATH'] = LD_LIBRARY_PATH
-            if sys.argv[0].endswith("radian"):
-                os.execv(sys.argv[0], sys.argv)
-            else:
-                os.execv(sys.executable, [sys.executable, "-m", "radian"] + sys.argv[1:])
-
     RadianApplication(r_home, ver=__version__).run(options, cleanup=cleanup)
 
 
END
    "${app['patch']}" \
        --unified \
        --verbose \
        'src/radian/app.py' \
        'app.patch'
    koopa_cd 'src'
    export PIP_NO_CACHE_DIR=1
    koopa_print_env
    "${app['python']}" setup.py install
    koopa_mkdir "${dict['prefix']}/bin"
    (
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln '../libexec/bin/radian' 'radian'
    )
    return 0
}
