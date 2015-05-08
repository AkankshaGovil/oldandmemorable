sh configFile.sh
echo "lllllllllll"
echo $Gens

vnetInterface_1="eth2"
vnetInterface_2="eth3"
vnetInterface_3="eth4"

realm_1_rsa="23.23.0.88"
realm_1_mask="255.255.0.0"

realm_2_rsa="24.24.0.88"
realm_2_mask="255.255.0.0"

realm_ser_rsa="10.148.0.41"
realm_ser_mask="255.255.0.0"

SERCount=3

SER_ip_1=" "
SER_mask_1="255.255.0.0"
SER_domain_1=" "


SER_ip_2=" "
SER_mask_2="255.255.0.0"
SER_domain_2=" "


SER_ip_3=" "
SER_mask_3="255.255.0.0"
SER_domain_3=" "
cli vnet add v1
cli vnet add v2
cli vnet add v3
cli vnet edit v1 ifname $vnetInterface_1 gateway 0.0.0.0
cli vnet edit v2 ifname $vnetInterface_2 gateway 0.0.0.0
cli vnet edit v3 ifname $vnetInterface_3 gateway 0.0.0.0

cli realm add r1
cli realm add r2
cli realm add r3
cli realm edit r1 admin enable addr private emr alwayson imr alwayson mask 255.255.0.0 medpool 1 rsa 23.23.0.88 vnet v1 sipauth all
cli realm edit r2 admin enable addr private emr alwayson imr alwayson mask 255.255.0.0 medpool 2 rsa 24.24.0.88 vnet v2 sipauth all
cli realm edit r3 admin enable addr private emr alwaysoff imr alwaysoff medpool 1 mask 255.255.0.0 rsa 10.148.0.41 vnet v3 sipauth all

#---------Proxy 1---
count=1 
while [ $count -ne 2 ] 
#while [ $count -ne $SERCount ] 
do
    ip="$""SER_ip_$count"

    echo "cli iedge add SERProxy$count 0"
    cli iedge edit SERProxy$count 0 type sipproxy static $[SER_ip_$count] uri $SER_domain_$count sip enable
    echo  "   cli iedge add SERProxy$count 1"
    echo   "  cli iedge edit SERProxy$count 1 type sipproxy static $SER_ip_$count realm r3 uri $SER_ip_$count locatingsipserver srv sip enable"
    
    count=`expr $count + 1`
done
#------------Proxy 2
cli iedge add SERProxy2 0
cli iedge edit SERProxy2 0 type sipproxy static 0.0.0.0 realm r3 uri as.load52test2.com sip enable
cli iedge add SERProxy2 1
cli iedge edit SERProxy2 1 type sipproxy static 0.0.0.0 realm r3 uri 10.148.0.91 locatingsipserver srv sip enable
#------------Proxy 3
cli iedge add SERProxy3 0
cli iedge edit SERProxy3 0 type sipproxy static 0.0.0.0 realm r3 uri as.load52test3.com sip enable
cli iedge add SERProxy3 1
cli iedge edit SERProxy3 1 type sipproxy static 0.0.0.0 realm r3 uri 10.148.0.94 locatingsipserver srv sip enable
