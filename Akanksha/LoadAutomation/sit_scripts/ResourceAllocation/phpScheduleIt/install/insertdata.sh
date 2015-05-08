#!/bin/sh

#fileContent=`cat data.txt | IFS=","`
fileContent=`cat data.txt`

#IFS=","
#echo $IFS

insertQuery="insert into machines values("
for i in $fileContent; do
	echo $i
	j=1
	insertQuery=$insertQuery\'
	insertQuery=$insertQuery$i
	insertQuery=$insertQuery\'
	
	if [$j!=5]
	then
		insertQuery=$insertQuery\,
	fi
	j=j+1
done
echo $insertQuery

