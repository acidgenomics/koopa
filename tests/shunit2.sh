#!/usr/bin/env bash

# """
# shUnit2
# https://github.com/kward/shunit2
#
#
# Asserts
# ==============================================================================
# 
# assertEquals [message] expected actual
# 
# Asserts that expected and actual are equal to one another. The expected and
# actual values can be either strings or integer values as both will be treated
# as strings. The message is optional, and must be quoted.
# 
# assertNotEquals [message] unexpected actual
# 
# Asserts that unexpected and actual are not equal to one another. The
# unexpected and actual values can be either strings or integer values as both
# will be treaded as strings. The message is optional, and must be quoted.
# 
# assertSame [message] expected actual
# 
# This function is functionally equivalent to assertEquals.
# 
# assertNotSame [message] unexpected actual
# 
# This function is functionally equivalent to assertNotEquals.
# 
# assertContains [message] container content
# 
# Asserts that container contains content. The container and content values can
# be either strings or integer values as both will be treated as strings. The
# message is optional, and must be quoted.
# 
# assertNotContains [message] container content
# 
# Asserts that container does not contain content. The container and content
# values can be either strings or integer values as both will be treaded as
# strings. The message is optional, and must be quoted.
# 
# assertNull [message] value
# 
# Asserts that value is null, or in shell terms, a zero-length string. The value
# must be a string as an integer value does not translate into a zero- length
# string. The message is optional, and must be quoted.
# 
# assertNotNull [message] value
# 
# Asserts that value is not null, or in shell terms, a non-empty string. The
# value may be a string or an integer as the later will be parsed as a non-empty
# string value. The message is optional, and must be quoted.
# 
# assertTrue [message] condition
# 
# Asserts that a given shell test condition is true. The condition can be as
# simple as a shell true value (the value 0 -- equivalent to ${SHUNIT_TRUE}), or
# a more sophisticated shell conditional expression. The message is optional,
# and must be quoted.
# 
# A sophisticated shell conditional expression is equivalent to what the if or
# while shell built-ins would use (more specifically, what the test command
# would use). Testing for example whether some value is greater than another
# value can be done this way.
# 
# assertTrue "[ 34 -gt 23 ]"
# 
# Testing for the ability to read a file can also be done. This particular test
# will fail.
# 
# assertTrue 'test failed' "[ -r /some/non-existant/file' ]"
# 
# As the expressions are standard shell test expressions, it is possible to
# string multiple expressions together with -a and -o in the standard fashion.
# This test will succeed as the entire expression evaluates to true.
# 
# assertTrue 'test failed' '[ 1 -eq 1 -a 2 -eq 2 ]'
# 
# One word of warning: be very careful with your quoting as shell is not the
# most forgiving of bad quoting, and things will fail in strange ways.
# 
# assertFalse [message] condition
# 
# Asserts that a given shell test condition is false. The condition can be as
# simple as a shell false value (the value 1 -- equivalent to ${SHUNIT_FALSE}),
# or a more sophisticated shell conditional expression. The message is optional,
# and must be quoted.
# 
# For examples of more sophisticated expressions, see assertTrue.
#
#
# Functions
# ==============================================================================
#
# oneTimeSetUp()
# oneTimeTearDown()
#
# setUp()
# tearDown()
#
#
# Suite approach
# ==============================================================================
#
# In this script:
# > suite() {
# >     . ./tests/test1
# > }
# > . shunit2
#
# In the test files:
# > example1_test() {
# >     ... # test body here
# > }
# > example2_test() {
# >     ... # test body here
# > }
# > suite_addTest example1_test
# > suite_addTest example2_test
#
# See also:
# https://github.com/kward/shunit2/issues/52#issuecomment-358536886
# """

script_dir="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" \
    >/dev/null 2>&1 && pwd -P)"
KOOPA_PREFIX="$(cd "${script_dir}/.." >/dev/null 2>&1 && pwd -P)"
export KOOPA_PREFIX
# shellcheck source=/dev/null
source "${KOOPA_PREFIX}/shell/bash/include/header.sh"

_koopa_exit_if_not_installed shunit2

extra=0

while (("$#"))
do
    case "$1" in
        --extra)
            extra=1
            shift 1
            ;;
        *)
            _koopa_invalid_arg "$1"
            ;;
    esac
done

_koopa_h1 "Running unit tests with shUnit2."

# Don't exit on errors, which are handled by shunit2.
set +o errexit

shunit2_dir="${script_dir}/shunit2"

suite() {
    for file in "${shunit2_dir}/"*".sh"
    do
        # shellcheck disable=SC1090
        . "$file"
    done

    if [[ "$extra" -eq 1 ]]
    then
        for file in "${shunit2_dir}/extra/"*".sh"
        do
            # shellcheck disable=SC1090
            . "$file"
        done
    fi

    mapfile -t tests < <( \
        declare -F \
            | cut -d ' ' -f 3 \
            | grep -E '^test_' \
            | sort
    )

    for test in "${tests[@]}"
    do
        suite_addTest "$test"
    done
}

# shellcheck disable=SC1091
. shunit2
