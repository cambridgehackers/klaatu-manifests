#! /usr/bin/env python
import os, sys

fin = open(sys.argv[1], 'rb')
fout = open(sys.argv[2], 'wb')
fout.write(fin.read(0x38))
t = fin.read(1)
fout.write('%c' % 0)
fout.write(fin.read())
fin.close()
fout.close()
