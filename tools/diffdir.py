#! /usr/bin/env python
# Copyright (c) 2012 Nokia Corporation
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

#
# Standalone function for recursively creating directories and symbolic
# links to create a clone of 'sourcedir' into 'destinationdir'.
# This is particularly useful when using a read-only bind/mount
# directory as a reference, but allow local overwriting, deletion,
# addition of files to the directories.
# It might be thought of as a "poor man's UnionFS"
#

import os, subprocess, sys

def main(source_dir, dest_dir):
    verbose = False
    print "#diffdir.py", source_dir, dest_dir
    if not os.path.exists(source_dir):
        print "first doesn't exist: ", source_dir
        return 1
    if not os.path.exists(dest_dir):
        print "second doesn't exist: ", dest_dir
        return 1
    for root, dirs, files in os.walk(source_dir):
        # get string for directory after 'source_dir' root
        myroot = '.'+root[len(source_dir):]
        if not os.path.isdir(root):
            print "not dir", root
            return 1
        # append this directory string to 'dest_dir', create directory
        dest_root = os.path.join(dest_dir, myroot)
        for thedir in dirs:
            # for all of the included directories in source,
            # make the equivalent directory in target.
            origdir = os.path.join(os.curdir, source_dir, myroot, thedir)
            ddir = os.path.join(os.curdir, dest_dir, myroot, thedir)
            if os.path.islink(origdir):
                # 'directory' actually a symbolic link to a directory
                if verbose:
                    print "origlinkdir ", origdir, "link", os.readlink(origdir), "ddir", ddir
                #os.symlink(os.readlink(origdir), ddir)
            else:
                if verbose:
                    print "origlinkdir ", origdir, "ddir", ddir
        for thefile in files:
            # for all of the files included in source directory,
            # make a symbolic link to source.
            ddir = os.path.join(os.curdir, dest_dir, myroot)
            dfile = os.path.join(ddir, thefile)
            origfile = os.path.join(os.curdir, source_dir, myroot, thefile)
            #print 'des/sou', dest_dir, source_dir, myroot, thefile
            if not os.path.exists(dfile):
                print 'remove', os.path.join(myroot, thefile)
            elif not os.path.exists(origfile):
                print 'add', os.path.join(myroot, thefile)
            elif os.path.getsize(dfile) != os.path.getsize(origfile):
                print 'replace', os.path.join(myroot, thefile)
            else:
                ret = subprocess.call('cmp ' + origfile + ' ' + dfile + ' >xx.1', shell=True)
                if ret == 0:
                    continue
                tmp1 = open(dfile, 'rb').read()
                tmp2 = open(origfile, 'rb').read()
                i = 0
                startdiff = -1
                difflist = []
                while i < len(tmp1):
                    if tmp1[i] != tmp2[i]:
                        startdiff = i
                    elif startdiff != -1:
                        checklen = len(tmp1) - i
                        if checklen > 32:
                            checklen = 32
                        if tmp1[i: i+checklen] == tmp2[i: i+checklen]:
                            difflist.append((startdiff, i))
                            if i - startdiff > 64 or len(difflist) > 20:
                                break
                            startdiff = -1
                    i += 1
                if len(difflist) == 0:
                    pass
                elif startdiff == -1 and len(difflist) < 20:
                    print 'patch', os.path.join(myroot, thefile)
                    for item in difflist:
                        print '>%08x: %s' % (item[0], tmp1[item[0]:item[1]].encode('hex'))
                else:
                    print 'replace', os.path.join(myroot, thefile)
            #if os.path.islink(origfile):
                # If the file is already a link, link directly to target of original
                # link.  (we dont want to link to template/../lib, but to '../lib'
                # in our own directory heirarchy)
            #    os.symlink(os.readlink(origfile), dfile)
    # now look for files only in destination
    for root, dirs, files in os.walk(dest_dir):
        # get string for directory after 'source_dir' root
        myroot = '.'+root[len(dest_dir):]
        if not os.path.isdir(root):
            print "not dir", root
            return 1
        # append this directory string to 'dest_dir', create directory
        dest_root = os.path.join(dest_dir, myroot)
        for thedir in dirs:
            # for all of the included directories in source,
            # make the equivalent directory in target.
            origdir = os.path.join(os.curdir, source_dir, myroot, thedir)
            ddir = os.path.join(os.curdir, dest_dir, myroot, thedir)
            if os.path.islink(origdir):
                # 'directory' actually a symbolic link to a directory
                if verbose:
                    print "origlinkdir ", origdir, "link", os.readlink(origdir), "ddir", ddir
                #os.symlink(os.readlink(origdir), ddir)
            else:
                if verbose:
                    print "origlinkdir ", origdir, "ddir", ddir
        for thefile in files:
            # for all of the files included in source directory,
            # make a symbolic link to source.
            ddir = os.path.join(os.curdir, dest_dir, myroot)
            dfile = os.path.join(ddir, thefile)
            origfile = os.path.join(os.curdir, source_dir, myroot, thefile)
            if not os.path.exists(origfile):
                print 'add', os.path.join(myroot, thefile)
    return 0

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print 'diffdir.py <dir1> <dir2>'
        sys.exit(1)
    main(sys.argv[1], sys.argv[2])
