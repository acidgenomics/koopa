#!/bin/sh
# shellcheck disable=SC2039



# Get `R_HOME`, rather than exporting as global variable.
# Updated 2019-06-27.
_koopa_r_home() {
    _koopa_assert_is_installed R
    _koopa_assert_is_installed Rscript
    Rscript --vanilla -e 'cat(Sys.getenv("R_HOME"))'
}



# Update rJava configuration.
# The default Java path differs depending on the system.
# # > R CMD javareconf -h
# # Environment variables that can be used to influence the detection:
#   JAVA           path to a Java interpreter executable
#                  By default first 'java' command found on the PATH
#                  is taken (unless JAVA_HOME is also specified).
#   JAVA_HOME      home of the Java environment. If not specified,
#                  it will be detected automatically from the Java
#                  interpreter.
#   JAVAC          path to a Java compiler
#   JAVAH          path to a Java header/stub generator
#   JAR            path to a Java archive tool
# # Updated 2019-06-27.
_koopa_r_javareconf() {
    local java_home
    local java_flags
    local r_home

    _koopa_is_installed R || return 1
    _koopa_is_installed java || return 1
   
    java_home="$(_koopa_java_home)"
    [ -n "$java_home" ] && [ -d "$java_home" ] || return 1
    
    printf "Updating R Java configuration.\n"
    
    java_flags=(
        "JAVA_HOME=${java_home}" \
        "JAVA=${java_home}/bin/java" \
        "JAVAC=${java_home}/bin/javac" \
        "JAVAH=${java_home}/bin/javah" \
        "JAR=${java_home}/bin/jar" \
    )

    r_home="$(_koopa_r_home)"
    _koopa_build_set_permissions "$r_home"
    
    R --vanilla CMD javareconf "${java_flags[@]}"

    if _koopa_has_sudo
    then
        sudo R --vanilla CMD javareconf "${java_flags[@]}"
    fi

    # > Rscript -e 'install.packages("rJava")'
}



# Look into an improved POSIX method here. This works for bash and ksh.
# Note that this won't work on the first item in PATH.
# # Alternate approach using sed:
# > echo "$PATH" | sed "s|:${dir}||g"
# # Updated 2019-07-10.
_koopa_remove_from_path() {
    local dir
    dir="$1"
    export PATH="${PATH//:$dir/}"
}



# Updated 2019-06-21.
_koopa_rsync_flags() {
    echo "--archive --copy-links --delete-before --human-readable --progress"
}
