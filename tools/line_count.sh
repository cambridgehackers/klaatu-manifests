#
#set -x
set -e
find . -name \*.cc -o -name \*.c -o -name \*.h -o -name \*.h -o -name \*.cxx -o -name \*.cpp -o -name \*.hxx >ll.cfile
find . -iname \*.java >ll.javafile

rm -f jj.*
ls ll.* | while read filename ; do
    grep -v /development/ <$filename | grep -v /prebuilt/ | grep -v /prebuilts/ | grep -v /ndk/ | grep -v /sdk/ | grep -v /out/ | grep -v /gdk/ | grep -v /cts/ | sed -e "s/\.\///" >xx.tmp
    mv xx.tmp $filename
    #echo $filename `wc -l $filename`
    sed -e "s/\//Z123Z/" -e "s/\//Z123Z/" <$filename >xx.tmp
    sed -e "s/\(.*\)\Z123Z\(.*\)/echo '\1\/\2' >> jj.${filename}_\1/" -e "s/Z123Z/\//" -e "s/jj\.ll\./jj./" <xx.tmp >xx.tmp2
    sed \
        -e "s/file_abiZ123Z.*/file_abi/" \
        -e "s/file_bionicZ123Z.*/file_bionic/" \
        -e "s/file_deviceZ123Z.*/file_device/" \
        -e "s/file_dalvikZ123Z.*/file_dalvik/" \
        -e "s/file_bootableZ123Z.*/file_bootable/" \
        -e "s/file_buildZ123Z.*/file_build/" \
        -e "s/file_hardwareZ123Z.*/file_hardware/" \
        -e "s/file_libcoreZ123Z.*/file_libcore/" \
        -e "s/file_packagesZ123Z.*/file_packages/" \
        -e "s/file_systemZ123Z.*/file_system/" \
        <xx.tmp2 >xx.tmp3
    sh xx.tmp3
    rm $filename
done
ls jj.* | while read filename ; do
    rm -f /tmp/xx.tmp
    cat $filename | while read item ; do
        if [ -f $item ] ; then
            cat "$item" >>/tmp/xx.tmp
        fi
    done
    echo `echo $filename | sed -e "s/jj\.//" -e "s/Z123Z/\//g" -e "s/file_/ /"` `wc -l /tmp/xx.tmp | sed -e "s/ .*//"` | sed -e "s/\(.*\) \(.*\) \(.*\)/\2 \1 \3/"
    rm $filename /tmp/xx.tmp
done
