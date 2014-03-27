#!/usr/bin/python

from netaddr import *

ip1_str = "1.2.3.9"
ip2_str = "1.2.3.1"

if IPAddress(ip1_str) >= IPAddress(ip2_str):
    print("ip1 %s >= ip2 %s" % ( ip1_str, ip2_str))
else:
    print("ip1 %s < ip2 %s" % ( ip1_str, ip2_str))


ip1_str = "1.2.3.9"
ip1 = IPAddress(ip1_str)
ip3 = ip1 - 1 
print "ip3 " + str(ip3)


subnet_str = "1.2.3.0/24"
sub = IPNetwork(subnet_str)
print "sub " + str(sub)

if ip1 in sub:
    print ("%s is in %s" %(str(ip1), str(sub)))
else:
    print ("%s is NOT in %s" %(str(ip1), str(sub)))


ip1_str = "10.2.3.9"
ip1 = IPAddress(ip1_str)
if ip1 in sub:
    print ("%s is in %s" %(str(ip1), str(sub)))
else:
    print ("%s is NOT in %s" %(str(ip1), str(sub)))


sub = IPNetwork("70.105.72.0/24")
pub_ip = IPAddress("70.105.72.44")
ip_max = pub_ip - 1
pub_netmask = sub.netmask
pub_gateway = sub.ip + 1

print "-"*40
print "sub    %s" % sub
print "ip max %s" % ip_max
print "pub ip      %s" % pub_ip
print "pub_netmask %s" % pub_netmask
print "pub_gateway %s" % pub_gateway
ip_list = list(sub)
print "%s - %s len=%d" % (ip_list[0], ip_list[-1], len(ip_list))
if ip_max in sub:
    print ("%s is in %s" % (ip_max, sub))
else:
    print ("%s is NOT in %s" % (ip_max, sub))



sub = IPNetwork("70.105.72.128/25")
pub_ip = IPAddress("70.105.72.44")
ip_max = pub_ip - 1
pub_netmask = sub.netmask
pub_gateway = sub.ip + 1

print "-"*40
print "sub    %s" % sub
print "ip max %s" % ip_max
print "pub ip      %s" % pub_ip
print "pub_netmask %s" % pub_netmask
print "pub_gateway %s" % pub_gateway
ip_list = list(sub)
print "%s - %s len=%d" % (ip_list[0], ip_list[-1], len(ip_list))
if ip_max in sub:
    print ("%s is in %s" % (ip_max, sub))
else:
    print ("%s is NOT in %s" % (ip_max, sub))


try:
    sub = IPNetwork("70.105.72.128/a")
    print "sub    %s" % sub
except AddrFormatError, e:
    print e


try:
    sub = IPNetwork("1.1.1.1")
    print "sub    %s" % sub
except AddrFormatError, e:
    print e


