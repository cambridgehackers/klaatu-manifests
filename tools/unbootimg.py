#!/usr/bin/python
# Original author John Ankcorn
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

#./mkbootimg --kernel tmp.kernel --ramdisk tmp.ramdisk.gz --cmdline 'console=ttyHSL0,115200,n8 androidboot.hardware=qcom user_debug=31' --pagesize 2048 --base 0x80200000 -o foo
#kernel  5153824 0x80208000
#ramdisk  171147 0x81400000
#second  0 0x81100000
#tags  2149581056
#pagesize  2048 name cmdline console=ttyHSL0,115200,n8 androidboot.hardware=qcom user_debug=31

import os, struct, sys

def read_next(fn, name, size, pad):
    os.lseek(fn, pad, os.SEEK_CUR)
    fo = os.open(name, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0666)
    os.write(fo, os.read(fn, size))
    os.close(fo)

fn = os.open(sys.argv[1], os.O_RDONLY)
header_len = 8 + 10 * 4 + 16 + 512 + 8 * 4
s = os.read(fn, header_len)
instruct = struct.unpack('8s10I16s512s8I', s)
if instruct[0] != 'ANDROID!':
    print 'not a boot.img file !!!'
    sys.exit(1)
pagesize = instruct[8]
name = instruct[11].strip(chr(0))
cmdline = instruct[12].strip(chr(0))

print 'kernel ', instruct[1], hex(instruct[2])
print 'ramdisk ', instruct[3], hex(instruct[4])
print 'second ', instruct[5], hex(instruct[6])
print 'tags ', instruct[7]
print 'pagesize ', pagesize, 'name', name, 'cmdline', cmdline

read_next(fn, 'tmp.kernel', instruct[1], pagesize - header_len)
read_next(fn, 'tmp.ramdisk.gz', instruct[3], pagesize - instruct[1] % pagesize)
if instruct[5] > 0:
    read_next(fn, 'tmp.second', instruct[5], pagesize - instruct[3] % pagesize)
