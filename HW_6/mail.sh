#!/bin/bash
if
find / -name full.sh -exec {} \; > otchet.txt &&
mailx root@localhost < otchet.txt &&
rm otchet.txt access.log

then
exit 0
else 
echo "file not found"
fi

