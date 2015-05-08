
checkCallingPlan()
{
details=`grep -a "com.nextone.bn.rating.MSWRoutesGenerator:updateRoutesToDBs" /var/log/bn.log.0 | grep -a CallingPlans: | tail -1 | awk -F "CallingPlans: " '{print $2}'`
insert=`echo $details | awk -F"," '{print $1}' | awk -F"=" '{print $2}'` 
update=`echo $details | awk -F"," '{print $2}' | awk -F"=" '{print $2}'` 
delete=`echo $details | awk -F"," '{print $3}' | awk -F"=" '{print $2}'` 

if [ $insert -eq 0 ]
then
   return 0 
else
   return 1
fi
}

checkCallingRoute()
{
details=`grep -a "com.nextone.bn.rating.MSWRoutesGenerator:updateRoutesToDBs" /var/log/bn.log.0  | grep -a "CallingRoutes" | tail -1 | awk -F"CallingRoutes: " '{print $2}'`
insert=`echo $details | awk -F"," '{print $1}' | awk -F"=" '{print $2}'` 
update=`echo $details | awk -F"," '{print $2}' | awk -F"=" '{print $2}'` 
delete=`echo $details | awk -F"," '{print $3}' | awk -F"=" '{print $2}'` 

if [ $insert -eq 45000 ]
then
   return 0 
else
   return 1
fi
}

checkCallingPlanBindings()
{
details=`grep -a "com.nextone.bn.rating.MSWRoutesGenerator:updateRoutesToDBs" /var/log/bn.log.0  | grep -a "CallingPlanBindings" | tail -1 | awk -F"CallingPlanBindings: " '{print $2}'`
insert=`echo $details | awk -F"," '{print $1}' | awk -F"=" '{print $2}'` 
update=`echo $details | awk -F"," '{print $2}' | awk -F"=" '{print $2}'` 
delete=`echo $details | awk -F"," '{print $3}' | awk -F"=" '{print $2}'` 

if [ $insert -eq 180000 ]
then
   return 0 
else
   return 1
fi
}

checkCallingPlan
cpRet=$?
checkCallingRoute
crRet=$?
checkCallingPlanBindings
cpbRet=$?

#echo $cpRet
#echo $crRet
#echo $cpbRet

if [ $cpRet -eq 0 -a $crRet -eq 0 -a $cpbRet -eq 0 ]
then
  #echo true
  echo 0
else
  echo 1
fi
