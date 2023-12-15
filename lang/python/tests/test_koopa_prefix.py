"""
koopa_prefix()
"""

from os.path import isdir

from koopa import koopa_prefix


def test_is_scalar():
    assert isdir(koopa_prefix())
