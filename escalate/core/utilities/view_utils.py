import functools

def rsetattr(obj, attr, val):
    pre, _, post = attr.rpartition('.')
    return setattr(rgetattr(obj, pre) if pre else obj, post, val)

def rgetattr(obj, attr, *args):
    def _getattr(obj, attr):
        if obj == None:
            return None
        else:
            return getattr(obj, attr, *args)
    return functools.reduce(_getattr, [obj] + attr.split('.'))