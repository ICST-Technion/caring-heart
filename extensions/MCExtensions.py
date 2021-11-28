
def with_metaclass(*args):
    name = "".join(a.__name__ for a in args)
    return type(name, args, {})
