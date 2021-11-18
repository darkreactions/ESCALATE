import functools
import collections.abc


def rsetattr(obj, attr, val):
    pre, _, post = attr.rpartition(".")
    return setattr(rgetattr(obj, pre) if pre else obj, post, val)


def rgetattr(obj, attr, *args):
    def _getattr(obj, attr):
        if obj == None:
            return None
        else:
            return getattr(obj, attr, *args)

    return functools.reduce(_getattr, [obj] + attr.split("."))


class FrozenDict(collections.abc.Mapping):
    """
    Frozen dictionary class to use if needed
    item assignment is disabled
    new attribute assignment is disabled since it doesn't extend dict directly
    """

    __is_frozen = False

    def __init__(self, *args, **kwargs):
        self._d = dict(*args, **kwargs)
        self._hash = None
        self.__is_frozen = True

    def __iter__(self):
        return iter(self._d)

    def __len__(self):
        return len(self._d)

    def __getitem__(self, key):
        return self._d[key]

    def __str__(self):
        return str(self._d)

    def __repr__(self):
        return str(self._d)

    def __hash__(self):
        if self._hash is None:
            hash_ = 0
            for pair in sorted(self.items()):
                hash_ ^= hash(pair)
            self._hash = hash_
        return self._hash

    def __setattr__(self, key, value):
        if self.__is_frozen and not hasattr(self, key):
            raise Exception(f"{self} is a frozen class. Cannot set new attribute {key}")
        object.__setattr__(self, key, value)
