#!/usr/bin/env python
#
# Python script helper to check overlayfs d_type support is enabled for specified directory path
#
# Author: Original Python implementation of d_type support checker written by Prashanth Pai <ppai@redhat.com>
#         Modified for purpose of xPaaS images by Jan Lieskovsky <jlieskov@redhat.com>
#

import ctypes
import os
import sys
from ctypes.util import find_library

(DT_UNKNOWN, DT_DIR,) = (0, 4,)

class linux_dirent64(ctypes.Structure):
    _fields_ = (
        ('d_ino', ctypes.c_uint64),
        ('d_off', ctypes.c_int64),
        ('d_reclen', ctypes.c_ushort),
        ('d_type', ctypes.c_ubyte),
        ('d_name', ctypes.c_char * 256),
    )


class linux_DIR(ctypes.Structure):
    pass


if __name__ == '__main__':

    if len(sys.argv) < 2:
        print "%s: Enter directory path to check for d_type support!" % sys.argv[0]
        exit(1)

    dpath = sys.argv[1]
    if not os.path.isdir(dpath):
        errmsg = "%s: Invalid directory path '%s': " % (sys.argv[0], dpath)
        if not os.path.exists(dpath):
            errmsg += "The directory does not exist!"
        else:
            errmsg += "Not a directory!"
        print errmsg
        exit(1)

    dpath_fstype = os.popen("stat -f -c %%T %s" % dpath).read().rstrip()
    if dpath_fstype != "overlayfs":
        print "%s: File system type for \"%s\" directory path is not overlayfs!" % (sys.argv[0], dpath)
        exit(1)

    libc = ctypes.CDLL(find_library('c'), use_errno=True)

    libc.opendir.argtypes = [ctypes.c_char_p]
    libc.opendir.restype = ctypes.POINTER(linux_DIR)
    libc.readdir.restype = ctypes.POINTER(linux_dirent64)

    dirp = libc.opendir(dpath)
    while True:
        e = libc.readdir(dirp)
        if not e:
            break
        # The backing filesystem is formatted with ftype=0 (d_type support is not enabled)
        if e.contents.d_type == DT_UNKNOWN:
            print "%s: The backing filesystem is formatted without d_type support!" % sys.argv[0]
            exit(1)

    # The backing filesystem is formatted with ftype=1 (d_type support enabled)
    exit(0)
