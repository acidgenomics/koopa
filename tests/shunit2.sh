#!/usr/bin/env bash
set -Eu -o pipefail

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
# """

testEquality() {
    assertEquals 1 1
}

# > testPartyLikeItIs1999() {
# >     year="$(date "+%Y")"
# >     assertEquals "It's not 1999 :-(" "1999" "$year"
# > }

# Load shUnit2.
# shellcheck disable=SC1091
. shunit2
