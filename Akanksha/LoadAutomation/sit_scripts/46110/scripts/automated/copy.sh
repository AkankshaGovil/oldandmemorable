
for i in $1 $2
do
    `scp -r 46110Scripts root@$i:/tmp/`
     if [ $? -eq 0 ]; then
        echo " Scripts copied successfully on remote machine $i"
     else
        echo " Scripts NOT copied successfully on remote machine $i"
     fi
done


