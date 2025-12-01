"""OS module unit tests."""

from os.path import isdir

from koopa.os import koopa_prefix


def test_koopa_prefix():
    """Test koopa_prefix function."""
    assert isdir(koopa_prefix())
