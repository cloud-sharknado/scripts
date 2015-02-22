# Number of requests per IP address (sorted)
#
awk '{!a[$1]++}END{for(i in a) if ( a[i] >10 ) print a[i],i }' access_log | sort -nr | less
awk '{!a[$1]++}END{for(i in a) print a[i],i}' access_log | sort -nr -k 2 | sort -rn | (printf "%s\t%s\n" "#Req" "IPADDR"; head -n 10 | column -t )
awk '{!a[$1]++;}END{PROCINFO["sorted_in"] = "@val_num_desc"; j = 1; for(i in a) { print a[i],i; j++; if (j>10) break}}' access_log # Advanced version
tail -10000 access_log | awk '{print $1}' | sort | uniq -c | sort -n | tail

# Number of requests per IP address including information about owner
#
awk '{!a[$1]++}END{for(i in a) print a[i],i}' access_log | sort -nr -k 2 | sort -rn | (printf "%s\t%s\t%s\n" "#Req" "IPADDR" "Org/Person"; head -n 10 | while read line ; do    echo -n "$line " ;   IP="$(echo "$line" | awk '{print $2}')" ;   WHOIS="$(whois "$IP" | egrep -w 'netname:|OrgName:|person:' | xargs)";   echo "$WHOIS"; done | column -t )

# Top 10 requested pages and hit count
#
awk '{!a[$7]++}END{for(i in a) print a[i], i}' access_log | sort -nr | (printf "%s\t%s\n" "#Req" "URI"; head -10 | column -t)

# Percent of successful/unsuccessful requests 
#
awk '{!a[$9]++}END{for(i in a) print i, a[i], (a[i]/NR)*100}' access_log | (printf "%s\t%s\t%s\t\n" "Status" "Count" "Percent"; sort -nr -k 3 | column -t)
awk 'BEGIN{printf "%-18s%-18s%-18s\n", "Code", "Count", "Percent"}{ niz[$9]++; }END{ for ( var in niz ) printf "%-18s%-18s%-18s\n", var, niz[var], (niz[var]/NR)*100 }' access_log

# Top 10 of unsuccessful request
#
awk '$9 !~ /[23]0[0-9]/{!a[$7]++}END{for(i in a) print a[i], i}' access_log  | sort -nr -k 1 | (printf "%s\t%s\t\n" "#Req" "URI"; head -10 | column -t)

# Number of requests per minute in time interval
#
awk -F"[\ :"] 'BEGIN{printf "%-17s%9s\n","Date/Time","#Req"}/21\/Mar\/2011:08/,/22\/Mar\/2011:15/{!a[$4":"$5":"$6]++;}END{for(i in a) print i, a[i]}' access_log | sort -n
awk -F"[\ :"] 'BEGIN{printf "%-17s%9s\n","Date/Time","#Req"}/21\/Mar\/2011:08/,/22\/Mar\/2011:15/{!a[$4":"$5":"$6]++;}END{PROCINFO["sorted_in"] = "@ind_str_asc"; for(i in a) printf "%-17s%9s\n", i, a[i]}' access_log # Advanced version
awk -F"[\ :"] '/21\/Mar\/2011:08/,/22\/Mar\/2011:15/{!a[$4":"$5":"$6]++;}END{for(i in a) print i, a[i]}' access_log | sort -n

# Number of requests per day
#
awk '{print $4}' access_log | cut -d: -f1 | uniq -c

# Number of requests per hour
#
grep "02/Feb" access_log | grep "\?entryPoint\=SugarFieldTRAddress" | cut -d[ -f2 | cut -d] -f1 | awk -F: '{print $2":00"}' | sort -n | uniq -c

# For each of 10 IP addresses with larger number of requests show top 5 requested pages.
#
awk '{!a[$1]++; !b[$1,$7]++;}END{PROCINFO["sorted_in"] = "@val_num_desc"; i = 1; for(ip in a) { printf "%-15s%-12s\n", ip, a[ip]; j = 1; for(ipuri in b) { split(ipuri,sep,SUBSEP); if(sep[1] = ip) { printf "\t%-15s%-10s%s\n", sep[1], b[ipuri], sep[2]; j++; }; if (j >= 5) break; };i++; if (i >=10) break};}' access_log

#  Sum of 404 errors
#
awk '($9 ~ /404/){print $7}' access_log | sort | uniq -c | sort -n

# Number of requests for 'base URL'
#
cat access_log | cut -d\" -f2 | awk '{print $1 " " $2}' | cut -d? -f1 | sort | uniq -c | sort -n

# Number of requests for 'unique URL'
#
cat access_log | cut -d\" -f2 | awk '{print $1 " " $2}' | sort | uniq -c | sort -n

awk -F'[ "]+' '$1 == "10.253.210.250" { pagecount[$7]++ } END { for (i in pagecount) {printf "%15s - %d\n", i, pagecount[i] } }' access_log

# Reference
#
http://www.the-art-of-web.com/system/logs/
http://ferd.ca/awk-in-20-minutes.html
http://www.grymoire.com/Unix/Awk.html
