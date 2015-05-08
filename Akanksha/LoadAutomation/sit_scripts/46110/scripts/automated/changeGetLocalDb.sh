

changeGetLocalDBScript()
{
    echo $1
    echo $2
    echo "Changing getlocaldbinfo.sh script"
    confFile='46110Scripts/getlocaldbinfo.sh'
    perl -pi -e 's/= *[0-9]*/= $1/g' $confFile
    #print cmd
    #os.system(cmd)
    `perl -pi -e 's/ *1T-[aA-zZ]*%/1T-$2%/g' $confFile`
    #print cmd

}

changeGetLocalDBScript $1 $2

