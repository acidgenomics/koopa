"""Data module unit tests."""

from koopa.data import argsort, flatten, unique_pos


def test_argsort_ascending() -> None:
    """Test argsort with ascending order."""
    assert argsort(["b", "a", "c"]) == [1, 0, 2]


def test_argsort_descending() -> None:
    """Test argsort with descending order."""
    assert argsort(["b", "a", "c"], reverse=True) == [2, 0, 1]


def test_argsort_docstring_example() -> None:
    """Test argsort matches docstring example."""
    obj = ["b", "a", "a", "c", "c", "c"]
    idx = argsort(obj, reverse=False)
    assert idx == [1, 2, 0, 3, 4, 5]
    assert [obj[i] for i in idx] == ["a", "a", "b", "c", "c", "c"]


def test_argsort_empty() -> None:
    """Test argsort with empty list."""
    assert argsort([]) == []


def test_argsort_single() -> None:
    """Test argsort with single element."""
    assert argsort(["x"]) == [0]


def test_flatten_simple() -> None:
    """Test flatten with simple nested list."""
    assert flatten([["a", "b"], ["c"]]) == ["a", "b", "c"]


def test_flatten_deeply_nested() -> None:
    """Test flatten with deeply nested list."""
    assert flatten([[[1]], [[2, 3]]]) == [1, 2, 3]


def test_flatten_already_flat() -> None:
    """Test flatten with already flat list."""
    assert flatten([1, 2, 3]) == [1, 2, 3]


def test_flatten_empty() -> None:
    """Test flatten with empty list."""
    assert flatten([]) == []


def test_unique_pos_basic() -> None:
    """Test unique_pos with duplicates."""
    assert unique_pos([1, 2, 2, 3, 4, 5, 5, 5]) == [0, 1, 3, 4, 5]


def test_unique_pos_all_unique() -> None:
    """Test unique_pos with all unique values."""
    assert unique_pos([3, 1, 2]) == [1, 2, 0]


def test_unique_pos_single() -> None:
    """Test unique_pos with single element."""
    assert unique_pos([7]) == [0]


def test_unique_pos_empty() -> None:
    """Test unique_pos with empty list."""
    assert unique_pos([]) == []
