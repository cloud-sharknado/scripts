# Simple one-liners for checking of file system usage
# provided tools could be used for finding disk hogs 

# Check for file system usage
df -h
#
#     == Sample output ==
#   Filesystem      Size  Used Avail Use% Mounted on
#   /dev/sda3       9.9G  6.0G  3.4G  65% /
#   tmpfs           2.9G     0  2.9G   0% /dev/shm
#   /dev/sda2        30G   15G   14G  52% /home
#   /dev/sda1       194M   89M   96M  48% /boot
#   /dev/sda6       2.0G  149M  1.8G   8% /tmp
#   /dev/sda5       5.0G  714M  4.0G  15% /var

# Check directory usage
du -smh $(find $1 -maxdepth 1 -type d ) | sort -gr
#
#     == Sample output ==
#   545M    ./logs
#   113M    ./opt
#   72M     ./test
#   16K     ./lost+found
#   15G     .
#   14G     ./mysql

# How to find big files in dir?
#
#   1st way.
find {/path/to/directory/} -type f -size +{size-in-kb}k -exec ls -lh {} \; | awk '{ print $9 ": " $5 }' 
#
#     == Sample output ==
#   /opt/app/backup_01_04_2014_11_01.sql: 72M
#   /opt/logs/old/app.error.log.2.gz: 92M
#   /opt/logs/old/app.log.2.gz: 450M
#   /opt/mysql/app/user_global_action.MYD: 84M
#   /opt/mysql/app/user_order.MYD: 94M
#   /opt/mysql/mysql-slow.log: 14G
#
#   2nd way. 
find . -xdev -printf '%s %p\n' |sort -nr|head -20
#
#     == Sample output ==
#   216862720 ./usr/src/MySQL-5.6.16-1.el6.x86_64.rpm-bundle.tar
#   216862720 ./root/MySQL-5.6.16-1.el6.x86_64.rpm-bundle.tar
#   99158576 ./usr/lib/locale/locale-archive
#   85019380 ./root/MySQL-embedded-5.6.16-1.el6.x86_64.rpm
#   84976509 ./usr/sbin/mysqld
#   70013589 ./usr/sbin/mysqld-debug
#   67220181 ./usr/lib/jvm/java-1.7.0-openjdk-1.7.0.51.x86_64/jre/lib/rt.jar
#   54448076 ./root/MySQL-server-5.6.16-1.el6.x86_64.rpm
#   49669208 ./root/MySQL-test-5.6.16-1.el6.x86_64.rpm
#   49105672 ./usr/lib64/libgcj.so.10.0.0
#   41612688 ./usr/lib64/firefox/libxul.so
#   35976664 ./usr/lib64/xulrunner/libxul.so
#   34281024 ./usr/src/php-5.4.25/libs/libphp5.so
#   34281024 ./usr/src/php-5.4.25/.libs/libphp5.so
#   34281024 ./usr/local/apache2.4.7/modules/libphp5.so
#   34249300 ./usr/lib64/eclipse/dropins/sdk/plugins/org.eclipse.platform.doc.isv_3.6.1.r361_v20100713.jar
#   33415953 ./usr/src/php-5.4.25/sapi/cli/php
#   33415953 ./usr/local/bin/php
#   33357291 ./usr/src/php-5.4.25/sapi/cgi/php-cgi
#   33357291 ./usr/local/bin/php-cgi

#   3rd way
find . -type f -exec wc -c {} \; | sort -rn | head -10 
#  4148166656 ./Downloads/CentOS-7.0-1406-x86_64-DVD.iso
#  3053371392 ./Downloads/kali-linux-1.0.9a-amd64.iso
#  2585028608 ./Downloads/FreeBSD-10.1-RELEASE-amd64-dvd1.iso
#  1162936320 ./Downloads/ubuntu-14.10-desktop-amd64.iso
#  727711744 ./Downloads/elementaryos-stable-amd64.20130810.iso
#  606076928 ./Downloads/archlinux-2014.12.01-dual.iso
#  92441170 ./Downloads/plan9.iso.bz2
#  63261271 ./Downloads/kernel/backup.tar.gz
#  54329636 ./Downloads/kernel/20140917213118-linux-image-3.16.3-031603-generic_3.16.3-031603.201409171435_amd64.deb
#  46398793 ./Downloads/book.pdf

#   4th way (using perl)
du -k | sort -n | perl -ne 'if ( /^(\d+)\s+(.*$)/){$l=log($1+.1);$m=int($l/log(1024)); printf ("%6.1f\t%s\t%25s  %s\n",($1/(2**(10*$m))),(("K","M","G","T","P")[$m]),"*"x (1.5*$l),$2);}'
#
#     == Sample output ==
#    220.7  M              ******************  ./usr/share/locale
#    223.3  M              ******************  ./usr/lib64/eclipse
#    241.4  M              ******************  ./usr/share/javadoc/java-1.6.0-openjdk
#    241.4  M              ******************  ./usr/share/javadoc
#    246.9  M              ******************  ./usr/lib/jvm
#    252.0  M              ******************  ./var/lib
#    293.0  M              ******************  ./usr/share/doc
#    298.2  M              ******************  ./apps/mysql/selfcare
#    310.3  M             *******************  ./lib/modules
#    330.5  M             *******************  ./usr/src/php-5.4.25
#    354.8  M             *******************  ./lib
#    362.1  M             *******************  ./usr/bin
#    478.4  M             *******************  ./root
#    543.4  M             *******************  ./apps/logs/old
#    543.8  M             *******************  ./apps/logs
#    573.3  M             *******************  ./usr/lib
#    575.5  M             *******************  ./var
#    791.5  M            ********************  ./usr/src
#      1.1  G            ********************  ./usr/lib64
#      1.7  G           *********************  ./usr/share
#      5.0  G         ***********************  ./usr
#     13.5  G        ************************  ./apps/mysql
#     14.2  G        ************************  ./apps
#     20.8  G       *************************  .
#
# Refernec 
# http://www.cyberciti.biz/faq/unix-disk-usage-command-examples/
# http://www.cyberciti.biz/faq/check-free-space/
# http://www.cyberciti.biz/faq/find-large-files-linux/
