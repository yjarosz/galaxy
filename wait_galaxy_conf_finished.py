import time
import sys


def coroutine(fn):
    def start(*a, **kw):
        cr = fn(*a, **kw)
        cr.next()
        return cr
    return start


def follow(thefile):
    thefile.seek(0, 2)
    while True:
        line = thefile.readline()
        if not line:
            time.sleep(0.2)
            continue
        yield line

if __name__ == '__main__':
    with open(sys.argv[1], 'rb') as stream:
        for line in follow(stream):
            print '[x] %s' % line,
            sys.stdout.flush()
            if 'http://127.0.0.1:8080' in line:
                break
