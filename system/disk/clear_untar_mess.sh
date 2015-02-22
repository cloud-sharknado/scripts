# How do I fix mess created by accidentally untarred files in the current dir?

cd /var/www/html/
/bin/rm -f "$(tar ztf /path/to/file.tar.gz)"

# reference 
# http://www.cyberciti.biz/open-source/command-line-hacks/20-unix-command-line-tricks-part-i/
