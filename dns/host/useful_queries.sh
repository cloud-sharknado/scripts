# The syntax is
host -a -t type name

## Show an IPv6 a record ##
host -a -t aaaa www.google.rs

## Show an IPv4 a record ##
host -a -t a www.google.rs

## Show cname record
host -a -t cname s0.cyberciti.org
host  -a -t cname s13.cyberciti.org
