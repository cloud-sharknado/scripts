# The syntax is
dig type name
dig @ns-name-server-here type name
dig [optipns] @ns-name-server-here type name
dig [options] type name

## Find ttl for IPv6 record  ##
dig +nocmd +noall +answer +ttlid aaaa www.example.com

## Find ttl for mx record ##
dig +nocmd +noall +answer +ttlid mx www.example.com

# Where,
#
#    +nocmd - Toggles the printing of the initial comment in the output identifying the version of dig 
#              and the query options that have been applied. This comment is printed by default.
#    +noall - Set or clear all display flags.
#    +answer - Display [do not display] the answer section of a reply. The default is to display it.
#    +ttlid - Display [do not display] the TTL when printing the record.

# You can skip caching recursive name server and get fresh ttl value using the following syntax:
dig +trace a www.cyberciti.biz
dig +trace +nocmd +noall +answer +ttlid aaaa www.cyberciti.biz
