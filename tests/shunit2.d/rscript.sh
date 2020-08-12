#!/usr/bin/env bash

# shellcheck disable=SC2154
rscript_dir="${shunit2_dir}/rscript"

test_r_parse_args() { # {{{1
    assertContains \
        "$( \
            "${rscript_dir}/parse-args" \
                --aaa='AAA' \
                --bbb='BBB' \
                --ccc='CCC' \
                --ddd='DDD' \
                --eee \
                --fff \
                'GGG' \
                'HHH' \
        )" \
        'required'
    assertContains \
        "$("${rscript_dir}/positional-args" 'aaa' 'bbb')" \
        'aaa'
}

test_r_parse_args_errors() { # {{{1
    assertContains \
        "$("${rscript_dir}/required-args" --zzz='ZZZ' 2>&1)" \
        'Missing required args: aaa, bbb.'
    assertContains \
        "$("${rscript_dir}/required-args" --aaa='AAA' 2>&1)" \
        'Missing required args: bbb.'
    assertContains \
        "$("${rscript_dir}/optional-args" --ccc='CCC' 2>&1)" \
        'Invalid args detected: ccc.'
    assertContains \
        "$("${rscript_dir}/flags" --ccc 2>&1)" \
        'Invalid flags detected: ccc.'
    assertContains \
        "$("${rscript_dir}/positional-args" 2>&1)" \
        'Positional arguments are required but missing.'
    assertContains \
        "$("${rscript_dir}/positional-args" 2>&1)" \
        'Positional arguments are required but missing.'
    assertContains \
        "$("${rscript_dir}/no-positional-args" 'aaa' 'bbb' 2>&1)" \
        'Positional arguments are defined but not allowed'
}
