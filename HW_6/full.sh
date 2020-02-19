#!/bin/bash
echo "Временной диапазон":
cat access.log | awk '{print $4}' | head -n 1 &&  date | awk '{print $2,$3,$4,$6}' &&

#1
echo "Топ-10 клиентских URL запрашиваемых с этого сервера"
cat access.log | awk '{print $7}' | sort | uniq -c | sort -rn | head -n 10 > 1.1.txt && cat 1.1.txt &&
echo "------------------------------------------------------" 
#2
echo "Топ-10 клиентских IP"
cat access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -n 10 > 2.2.txt && tail -n 10 2.2.txt &&
echo "------------------------------------------------------"
#3
echo "Все коды состояния HTTP и их количество"
cat access.log | awk '{print $9}'| grep -v "-" | sort | uniq -c | sort -rn > 3.3.txt && cat 3.3.txt && 
echo "------------------------------------------------------" 
#4
echo "Все коды состояния  4xx и 5xx"
cat access.log | awk '{print $9}' | grep ^4 > 4.4.txt && cat access.log | awk '{print $9}'  | grep ^5 >> 4.4.txt && cat 4.4.txt | uniq -d -c | sort -rn > 4.5.txt && cat 4.5.txt &&
echo "------------------------------------------------------"
echo "all"
rm -f 1.1.txt 2.2.txt 3.3.txt 4.4.txt 4.5.txt
