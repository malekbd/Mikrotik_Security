#########################################################################################################
#  Rick Frey's Basic MikroTik Firewall Rev 5.0 (Free Version)                                           #
#########################################################################################################
# Author: Rick Frey                                                                                     #
# email: support@rickfreyconsulting.com                                                                 #
# Username in MikroTik Forum is rickfrey                                                                #
#########################################################################################################
#                                         License                                                       #
# This script has been created for use by the general public and may be used freely. This script may    #
# not be sold!                                                                                          #
#########################################################################################################
#########################################################################################################
# Features                                                                                              #
# -Detect and block brute force attacks to the routers via SSH, Telnet, and Winbox (Disables WWW & FTP) #
# -Basic Antivirus filtering                                                                            #
# -P2P Blocking                                                                                         #
# -High Connection Rate detection                                                                       #
# -Basic Spam detection                                                                                 #
# -Basic Port Scanner Detection                                                                         #
# -Bogon Address Blocking                                                                               #
#########################################################################################################

###########################################################################################################################

###########################################################################################################################
#### Firewall Settings                                                                                                 ####
###########################################################################################################################
/ip firewall connection tracking
set enabled=yes

###########################################################################################################################
#### Drop Invalid Connections                                                                                          ####
#### To make this more useful, create a copy of the forward chain rule and set the interface for each LAN intface      ####
#### on your network. Remember to remove the orginal rule.                                                             ####
###########################################################################################################################
/ip firewall filter
add action=drop chain=input comment="Drop Invalid Connections" connection-state=invalid disabled=no
add action=drop chain=forward comment="Drop Invalid Connections" connection-state=invalid disabled=no

###########################################################################################################################
#### Must Add Admin IP Addresses in the Address List for Administering the Network in "Exempt Addresses"              #####
###########################################################################################################################

add action=accept chain=input comment="Accept Exempt IP Addresses" disabled=no src-address-list="Exempt Addresses"
add action=accept chain=forward comment="Accept Exempt IP Addresses" disabled=no src-address-list="Exempt Addresses"

############################################################################################################################
#### Multiple "Black Lists" have been created to help identify why any given person has been blocked.#######################
#### By default Port Scanners Black List is disabled. The Firewall will continue to add these people to the ################
#### the Black List, but will not block them unless the Black List is enabled. Use with caution!!!! ########################
#### Once someone is on a Black List they are permanently recorded there. To remove them, go to the address list.###########
############################################################################################################################

add action=drop chain=input comment="Drop anyone in the Black List (Manually Added)" disabled=no src-address-list="Black List"
add action=drop chain=forward comment="Drop anyone in the Black List (Manually Added)" disabled=no src-address-list="Black List"
add action=drop chain=input comment="Drop anyone in the Black List (SSH)" disabled=no src-address-list="Black List (SSH)"
add action=drop chain=forward comment="Drop anyone in the Black List (SSH)" disabled=no src-address-list="Black List (SSH)"
add action=drop chain=input comment="Drop anyone in the Black List (Telnet)" disabled=no src-address-list="Black List (Telnet)"
add action=drop chain=forward comment="Drop anyone in the Black List (Telnet)" disabled=no src-address-list="Black List (Telnet)"
add action=drop chain=input comment="Drop anyone in the Black List (Winbox)" disabled=no src-address-list="Black List (Winbox)"
add action=drop chain=forward comment="Drop anyone in the Black List (Winbox)" disabled=no src-address-list="Black List (Winbox)"
add action=drop chain=input comment="Drop anyone in the WAN Port Scanner List" disabled=yes src-address-list="WAN Port Scanners"
add action=drop chain=forward comment="Drop anyone in the WAN Port Scanner List" disabled=yes src-address-list="WAN Port Scanners"
add action=drop chain=input comment="Drop anyone in the LAN Port Scanner List" disabled=yes src-address-list="LAN Port Scanners"
add action=drop chain=forward comment="Drop anyone in the LAN Port Scanner List" disabled=yes src-address-list="LAN Port Scanners"
add action=drop chain=input comment="Drop all Bogons" disabled=no src-address-list=Bogons
add action=drop chain=forward comment="Drop all Bogons" disabled=no src-address-list=Bogons
add action=drop chain=forward comment="Drop all P2P" disabled=yes p2p=all-p2p
add chain=output comment="Section Break" disabled=yes

###########################################################################################################################
#### Detect & Block Brute Force Login Attempts                                                                         ####
###########################################################################################################################
add action=jump chain=input comment="Jump to RFC SSH Chain" disabled=no jump-target="RFC SSH Chain"
add action=add-src-to-address-list address-list="Black List (SSH)" address-list-timeout=0s chain="RFC SSH Chain" comment="Transfer repeated attempts from SSH Stage 3 to Black-List" connection-state=new disabled=no dst-port=22 protocol=tcp src-address-list="SSH Stage 3"
add action=add-src-to-address-list address-list="SSH Stage 3" address-list-timeout=1m chain="RFC SSH Chain" comment="Add succesive attempts to SSH Stage 3" connection-state=new disabled=no dst-port=22 protocol=tcp src-address-list="SSH Stage 2"
add action=add-src-to-address-list address-list="SSH Stage 2" address-list-timeout=1m chain="RFC SSH Chain" comment="Add succesive attempts to SSH Stage 2" connection-state=new disabled=no dst-port=22 protocol=tcp src-address-list="SSH Stage 1"
add action=add-src-to-address-list address-list="SSH Stage 1" address-list-timeout=1m chain="RFC SSH Chain" comment="Add intial attempt to SSH Stage 1 List" connection-state=new disabled=no dst-port=22 protocol=tcp
add action=return chain="RFC SSH Chain" comment="Return From RFC SSH Chain" disabled=no
add chain=output comment="Section Break" disabled=yes

add action=jump chain=input comment="Jump to RFC Telnet Chain" disabled=no jump-target="RFC Telnet Chain"
add action=add-src-to-address-list address-list="Black List (Telnet)" address-list-timeout=0s chain="RFC Telnet Chain" comment="Transfer repeated attempts from Telnet Stage 3 to Black-List" connection-state=new disabled=no dst-port=23 protocol=tcp src-address-list="Telnet Stage 3"
add action=add-src-to-address-list address-list="Telnet Stage 3" address-list-timeout=1m chain="RFC Telnet Chain" comment="Add succesive attempts to Telnet Stage 3" connection-state=new disabled=no dst-port=23 protocol=tcp src-address-list="Telnet Stage 2"
add action=add-src-to-address-list address-list="Telnet Stage 2" address-list-timeout=1m chain="RFC Telnet Chain" comment="Add succesive attempts to Telnet Stage 2" connection-state=new disabled=no dst-port=23 protocol=tcp src-address-list="Telnet Stage 1"
add action=add-src-to-address-list address-list="Telnet Stage 1" address-list-timeout=1m chain="RFC Telnet Chain" comment="Add Intial attempt to Telnet Stage 1" connection-state=new disabled=no dst-port=23 protocol=tcp
add action=return chain="RFC Telnet Chain" comment="Return From RFC Telnet Chain" disabled=no
add chain=output comment="Section Break" disabled=yes

add action=jump chain=input comment="Jump to RFC Winbox Chain" disabled=no jump-target="RFC Winbox Chain"
add action=add-src-to-address-list address-list="Black List (Winbox)" address-list-timeout=0s chain="RFC Winbox Chain" comment="Transfer repeated attempts from Winbox Stage 3 to Black-List" connection-state=new disabled=no dst-port=8291 protocol=tcp src-address-list="Winbox Stage 3"
add action=add-src-to-address-list address-list="Winbox Stage 3" address-list-timeout=1m chain="RFC Winbox Chain" comment="Add succesive attempts to Winbox Stage 3" connection-state=new disabled=no dst-port=8291 protocol=tcp src-address-list="Winbox Stage 2"
add action=add-src-to-address-list address-list="Winbox Stage 2" address-list-timeout=1m chain="RFC Winbox Chain" comment="Add succesive attempts to Winbox Stage 2" connection-state=new disabled=no dst-port=8291 protocol=tcp src-address-list="Winbox Stage 1"
add action=add-src-to-address-list address-list="Winbox Stage 1" address-list-timeout=1m chain="RFC Winbox Chain" comment="Add Intial attempt to Winbox Stage 1" connection-state=new disabled=no dst-port=8291 protocol=tcp
add action=return chain="RFC Winbox Chain" comment="Return From RFC Winbox Chain" disabled=no
add chain=output comment="Section Break" disabled=yes

###########################################################################################################################
#### Detect & Manage Port Scanners                                                                                     ####
###########################################################################################################################
/ip firewall filter
add action=add-src-to-address-list address-list="Wan Port Scanners" chain=input comment="Add TCP Port Scanners to Address List" protocol=tcp psd=40,3s,2,1
add action=add-src-to-address-list address-list="LAN Port Scanners" chain=forward comment="Add TCP Port Scanners to Address List" protocol=tcp psd=40,3s,2,1
add chain=output comment="Section Break" disabled=yes


###########################################################################################################################
#### Detect & Manage High Connection Rates                                                                             ####
###########################################################################################################################
/ip firewall filter
add action=add-src-to-address-list address-list="(WAN High Connection Rates)" chain=input comment="Add WAN High Connections to Address List" connection-limit=100,32 protocol=tcp
add action=add-src-to-address-list address-list="(LAN High Connection Rates)" chain=forward comment="Add LAN High Connections to Address List" connection-limit=100,32 protocol=tcp



############################################################################################################################
#### The Virus Chain has been added at the request of customers, but there is no guarantee expressed or implied with the ###
#### Virus Chain. ##########################################################################################################
############################################################################################################################

add action=jump chain=input comment="Jump to Virus Chain" disabled=no jump-target=Virus
add action=drop chain=Virus comment="Drop Blaster Worm" disabled=no dst-port=135-139 protocol=tcp
add action=drop chain=Virus comment="Drop Blaster Worm" disabled=no dst-port=445 protocol=tcp
add action=drop chain=Virus comment="Drop Blaster Worm" disabled=no dst-port=445 protocol=udp
add action=drop chain=Virus comment="Drop Messenger Worm" disabled=no dst-port=135-139 protocol=udp
add action=drop chain=Virus comment=Conficker disabled=no dst-port=593 protocol=tcp
add action=drop chain=Virus comment=Worm disabled=no dst-port=1024-1030 protocol=tcp
add action=drop chain=Virus comment="ndm requester" disabled=no dst-port=1363 protocol=tcp
add action=drop chain=Virus comment="ndm server" disabled=no dst-port=1364 protocol=tcp
add action=drop chain=Virus comment="screen cast" disabled=no dst-port=1368 protocol=tcp
add action=drop chain=Virus comment=hromgrafx disabled=no dst-port=1373 protocol=tcp
add action=drop chain=Virus comment="Drop MyDoom" disabled=no dst-port=1080 protocol=tcp
add action=drop chain=Virus comment=cichlid disabled=no dst-port=1377 protocol=tcp
add action=drop chain=Virus comment=Worm disabled=no dst-port=1433-1434 protocol=tcp
add action=drop chain=Virus comment="Drop Dumaru.Y" disabled=no dst-port=2283 protocol=tcp
add action=drop chain=Virus comment="Drop Beagle" disabled=no dst-port=2535 protocol=tcp
add action=drop chain=Virus comment="Drop Beagle.C-K" disabled=no dst-port=2745 protocol=tcp
add action=drop chain=Virus comment="Drop MyDoom" disabled=no dst-port=3127-3128 protocol=tcp
add action=drop chain=Virus comment="Drop Backdoor OptixPro" disabled=no dst-port=3410 protocol=tcp
add action=drop chain=Virus comment="Drop Sasser" disabled=no dst-port=5554 protocol=tcp
add action=drop chain=Virus comment=Worm disabled=no dst-port=4444 protocol=tcp
add action=drop chain=Virus comment=Worm disabled=no dst-port=4444 protocol=udp
add action=drop chain=Virus comment="Drop Beagle.B" disabled=no dst-port=8866 protocol=tcp
add action=drop chain=Virus comment="Drop Dabber.A-B" disabled=no dst-port=9898 protocol=tcp
add action=drop chain=Virus comment="Drop Dumaru.Y" disabled=no dst-port=10000 protocol=tcp
add action=drop chain=Virus comment="Drop MyDoom.B" disabled=no dst-port=10080 protocol=tcp
add action=drop chain=Virus comment="Drop NetBus" disabled=no dst-port=12345 protocol=tcp
add action=drop chain=Virus comment="Drop Kuang2" disabled=no dst-port=17300 protocol=tcp
add action=drop chain=Virus comment="Drop SubSeven" disabled=no dst-port=27374 protocol=tcp
add action=drop chain=Virus comment="Drop PhatBot, Agobot, Gaobot" disabled=no dst-port=65506 protocol=tcp
add action=return chain=Virus comment="Return From Virus Chain" disabled=no
add chain=output comment="Section Break" disabled=yes





###########################################################################################################################
#### This is the BOGON short list.                                                                                     ####
####!!!!! All subnets in this list will be blocked!!! Disable or remove any subnets that you are using!!!##################
###########################################################################################################################

/ip firewall address-list
add address=0.0.0.0/8 comment="RFC 1122 \"This host on this network\"" disabled=yes list=Bogons
add address=10.0.0.0/8 comment="RFC 1918 (Private Use IP Space)" disabled=yes list=Bogons
add address=100.64.0.0/10 comment="RFC 6598 (Shared Address Space)" disabled=yes list=Bogons
add address=127.0.0.0/8 comment="RFC 1122 (Loopback)" disabled=yes list=Bogons
add address=169.254.0.0/16 comment="RFC 3927 (Dynamic Configuration of IPv4 Link-Local Addresses)" disabled=yes list=Bogons
add address=172.16.0.0/12 comment="RFC 1918 (Private Use IP Space)" disabled=yes list=Bogons
add address=192.0.0.0/24 comment="RFC 6890 (IETF Protocol Assingments)" disabled=yes list=Bogons
add address=192.0.2.0/24 comment="RFC 5737 (Test-Net-1)" disabled=yes list=Bogons
add address=192.168.0.0/16 comment="RFC 1918 (Private Use IP Space)" disabled=yes list=Bogons
add address=198.18.0.0/15 comment="RFC 2544 (Benchmarking)" disabled=yes list=Bogons
add address=198.51.100.0/24 comment="RFC 5737 (Test-Net-2)" disabled=yes list=Bogons
add address=203.0.113.0/24 comment="RFC 5737 (Test-Net-3)" disabled=yes list=Bogons
add address=224.0.0.0/4 comment="RFC 5771 (Multicast Addresses) - Will affect OSPF, RIP, PIM, VRRP, IS-IS, and others. Use with caution.)" disabled=yes list=Bogons
add address=240.0.0.0/4 comment="RFC 1112 (Reserved)" disabled=yes list=Bogons
add address=192.31.196.0/24 comment="RFC 7535 (AS112-v4)" disabled=yes list=Bogons
add address=192.52.193.0/24 comment="RFC 7450 (AMT)" disabled=yes list=Bogons
add address=192.88.99.0/24 comment="RFC 7526 (Deprecated (6to4 Relay Anycast))" disabled=yes list=Bogons
add address=192.175.48.0/24 comment="RFC 7534 (Direct Delegation AS112 Service)" disabled=yes list=Bogons
add address=255.255.255.255 comment="RFC 919 (Limited Broadcast)" disabled=yes list=Bogons


##############################################################################################################################################
#### This is a list of all common ports as found on http://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers  and other sources.       ##
#### By default they are enabled to prevent immediate problems when applying the script. Carefully review the list of                       ##
#### ports and remove or disable entries that are not needed.                                                                               ##
##############################################################################################################################################

/ip firewall filter
add action=jump chain=forward comment="Jump to \"Manage Common Ports\" Chain" jump-target="Manage Common Ports"
add chain="Manage Common Ports" comment="\"All hosts on this subnet\" Broadcast" src-address=224.0.0.1
add chain="Manage Common Ports" comment="\"All routers on this subnet\" Broadcast" src-address=224.0.0.2
add chain="Manage Common Ports" comment="DVMRP (Distance Vector Multicast Routing Protocol)" src-address=224.0.0.4
add chain="Manage Common Ports" comment="OSPF - All OSPF Routers Broadcast" src-address=224.0.0.5
add chain="Manage Common Ports" comment="OSPF - OSPF DR Routers Broadcast" src-address=224.0.0.6
add chain="Manage Common Ports" comment="RIP Broadcast" src-address=224.0.0.9
add chain="Manage Common Ports" comment="EIGRP Broadcast" src-address=224.0.0.10
add chain="Manage Common Ports" comment="PIM Broadcast" src-address=224.0.0.13
add chain="Manage Common Ports" comment="VRRP Broadcast" src-address=224.0.0.18
add chain="Manage Common Ports" comment="IS-IS Broadcast" src-address=224.0.0.19
add chain="Manage Common Ports" comment="IS-IS Broadcast" src-address=224.0.0.20
add chain="Manage Common Ports" comment="IS-IS Broadcast" src-address=224.0.0.21
add chain="Manage Common Ports" comment="IGMP Broadcast" src-address=224.0.0.22
add chain="Manage Common Ports" comment="GRE Protocol (Local Management)" protocol=gre
add chain="Manage Common Ports" comment="FTPdata transfer" port=20 protocol=tcp
add chain="Manage Common Ports" comment="FTPdata transfer  " port=20 protocol=udp
add chain="Manage Common Ports" comment="FTPcontrol (command)" port=21 protocol=tcp
add chain="Manage Common Ports" comment="Secure Shell(SSH)" port=22 protocol=tcp
add chain="Manage Common Ports" comment="Secure Shell(SSH)   " port=22 protocol=udp
add chain="Manage Common Ports" comment=Telnet port=23 protocol=tcp
add chain="Manage Common Ports" comment=Telnet port=23 protocol=udp
add chain="Manage Common Ports" comment="Priv-mail: any privatemailsystem." port=24 protocol=tcp
add chain="Manage Common Ports" comment="Priv-mail: any privatemailsystem.  " port=24 protocol=udp
add chain="Manage Common Ports" comment="Simple Mail Transfer Protocol(SMTP)" port=25 protocol=tcp
add chain="Manage Common Ports" comment="Simple Mail Transfer Protocol(SMTP)  " port=25 protocol=udp
add chain="Manage Common Ports" comment="TIME protocol" port=37 protocol=tcp
add chain="Manage Common Ports" comment="TIME protocol  " port=37 protocol=udp
add chain="Manage Common Ports" comment="ARPA Host Name Server Protocol & WINS" port=42 protocol=tcp
add chain="Manage Common Ports" comment="ARPA Host Name Server Protocol  & WINS  " port=42 protocol=udp
add chain="Manage Common Ports" comment="WHOIS protocol" port=43 protocol=tcp
add chain="Manage Common Ports" comment="WHOIS protocol" port=43 protocol=udp
add chain="Manage Common Ports" comment="Domain Name System (DNS)" port=53 protocol=tcp
add chain="Manage Common Ports" comment="Domain Name System (DNS)" port=53 protocol=udp
add chain="Manage Common Ports" comment="Mail Transfer Protocol(RFC 780)" port=57 protocol=tcp
add chain="Manage Common Ports" comment="(BOOTP) Server & (DHCP)  " port=67 protocol=udp
add chain="Manage Common Ports" comment="(BOOTP) Client & (DHCP)  " port=68 protocol=udp
add chain="Manage Common Ports" comment="Trivial File Transfer Protocol (TFTP)  " port=69 protocol=udp
add chain="Manage Common Ports" comment="Gopher protocol" port=70 protocol=tcp
add chain="Manage Common Ports" comment="Finger protocol" port=79 protocol=tcp
add chain="Manage Common Ports" comment="Hypertext Transfer Protocol (HTTP)" port=80 protocol=tcp
add chain="Manage Common Ports" comment="RemoteTELNETService protocol" port=107 protocol=tcp
add chain="Manage Common Ports" comment="Post Office Protocolv2 (POP2)" port=109 protocol=tcp
add chain="Manage Common Ports" comment="Post Office Protocolv3 (POP3)" port=110 protocol=tcp
add chain="Manage Common Ports" comment="IdentAuthentication Service/Identification Protocol" port=113 protocol=tcp
add chain="Manage Common Ports" comment="Authentication Service (auth)  " port=113 protocol=udp
add chain="Manage Common Ports" comment="Simple File Transfer Protocol (SFTP)" port=115 protocol=tcp
add chain="Manage Common Ports" comment="Network Time Protocol(NTP)" port=123 protocol=udp
add chain="Manage Common Ports" comment="NetBIOSNetBIOS Name Service" port=137 protocol=tcp
add chain="Manage Common Ports" comment="NetBIOSNetBIOS Name Service  " port=137 protocol=udp
add chain="Manage Common Ports" comment="NetBIOSNetBIOS Datagram Service" port=138 protocol=tcp
add chain="Manage Common Ports" comment="NetBIOSNetBIOS Datagram Service  " port=138 protocol=udp
add chain="Manage Common Ports" comment="NetBIOSNetBIOS Session Service" port=139 protocol=tcp
add chain="Manage Common Ports" comment="NetBIOSNetBIOS Session Service  " port=139 protocol=udp
add chain="Manage Common Ports" comment="Internet Message Access Protocol (IMAP)" port=143 protocol=tcp
add chain="Manage Common Ports" comment="Background File Transfer Program (BFTP)" port=152 protocol=tcp
add chain="Manage Common Ports" comment="Background File Transfer Program (BFTP)  " port=152 protocol=udp
add chain="Manage Common Ports" comment="SGMP,Simple Gateway Monitoring Protocol" port=153 protocol=tcp
add chain="Manage Common Ports" comment="SGMP,Simple Gateway Monitoring Protocol  " port=153 protocol=udp
add chain="Manage Common Ports" comment="DMSP, Distributed Mail Service Protocol" port=158 protocol=tcp
add chain="Manage Common Ports" comment="DMSP, Distributed Mail Service Protocol  " port=158 protocol=udp
add chain="Manage Common Ports" comment="Simple Network Management Protocol(SNMP)  " port=161 protocol=udp
add chain="Manage Common Ports" comment="Simple Network Management ProtocolTrap (SNMPTRAP)" port=162 protocol=tcp
add chain="Manage Common Ports" comment="Simple Network Management ProtocolTrap (SNMPTRAP)  " port=162 protocol=udp
add chain="Manage Common Ports" comment="BGP (Border Gateway Protocol)" port=179 protocol=tcp
add chain="Manage Common Ports" comment="Internet Message Access Protocol (IMAP), version 3" port=220 protocol=tcp
add chain="Manage Common Ports" comment="Internet Message Access Protocol (IMAP), version 3" port=220 protocol=udp
add chain="Manage Common Ports" comment="BGMP, Border Gateway Multicast Protocol" port=264 protocol=tcp
add chain="Manage Common Ports" comment="BGMP, Border Gateway Multicast Protocol  " port=264 protocol=udp
add chain="Manage Common Ports" comment="Lightweight Directory Access Protocol (LDAP)" port=389 protocol=tcp
add chain="Manage Common Ports" comment="Lightweight Directory Access Protocol (LDAP)" port=389 protocol=udp
add chain="Manage Common Ports" comment="SSTP TCP Port 443 (Local Management) & HTTPS" port=443 protocol=tcp
add chain="Manage Common Ports" comment="Microsoft-DSActive Directory, Windows shares" port=445 protocol=tcp
add chain="Manage Common Ports" comment="L2TP/ IPSEC UDP Port 500 (Local Management)" port=500 protocol=udp
add chain="Manage Common Ports" comment="Modbus, Protocol" port=502 protocol=tcp
add chain="Manage Common Ports" comment="Modbus, Protocol  " port=502 protocol=udp
add chain="Manage Common Ports" comment="Shell (Remote Shell, rsh, remsh)" port=514 protocol=tcp
add chain="Manage Common Ports" comment="Syslog - used for system logging  " port=514 protocol=udp
add chain="Manage Common Ports" comment="Routing Information Protocol (RIP)  " port=520 protocol=udp
add chain="Manage Common Ports" comment="e-mail message submission (SMTP)" port=587 protocol=tcp
add chain="Manage Common Ports" comment="LDP,Label Distribution Protocol" port=646 protocol=tcp
add chain="Manage Common Ports" comment="LDP,Label Distribution Protocol" port=646 protocol=udp
add chain="Manage Common Ports" comment="FTPS Protocol (data):FTP over TLS/SSL" port=989 protocol=tcp
add chain="Manage Common Ports" comment="FTPS Protocol (data):FTP over TLS/SSL" port=989 protocol=udp
add chain="Manage Common Ports" comment="FTPS Protocol (control):FTP over TLS/SSL" port=990 protocol=tcp
add chain="Manage Common Ports" comment="FTPS Protocol (control):FTP over TLS/SSL" port=990 protocol=udp
add chain="Manage Common Ports" comment="TELNET protocol overTLS/SSL" port=992 protocol=tcp
add chain="Manage Common Ports" comment="TELNET protocol overTLS/SSL" port=992 protocol=udp
add chain="Manage Common Ports" comment="Internet Message Access Protocol over TLS/SSL (IMAPS)" port=993 protocol=tcp
add chain="Manage Common Ports" comment="Post Office Protocol3 over TLS/SSL (POP3S)" port=995 protocol=tcp
add chain="Manage Common Ports" comment="OVPN TCP Port 1194 (Local Management)" port=1194 protocol=tcp
add chain="Manage Common Ports" comment="PPTP Port 1723 (Local Management)" port=1723 protocol=tcp
add chain="Manage Common Ports" comment="L2TP UDP Port 1701 (Local Management)" port=1701 protocol=udp
add chain="Manage Common Ports" comment="L2TP UDP Port 4500 (Local Management)" port=4500 protocol=udp



/ip firewall filter
add chain=input comment="Accept Related or Established Connections" connection-state=established,related disabled=yes
add chain=forward comment="Accept New Connections" connection-state=new disabled=yes
add chain=forward comment="Accept Related or Established Connections" connection-state=established,related disabled=yes


##########################################################################################################################
#### Enable this rule in SAFE MODE and test before using##################################################################
##########################################################################################################################

add action=drop chain=forward comment="Drop all other LAN Traffic" disabled=yes
add action=drop chain=input comment="Drop all other WAN Traffic" disabled=yes



/ip service
set telnet address="" disabled=yes port=23
set ftp address="" disabled=yes port=21
set www address="" disabled=no port=80
set ssh address="" disabled=no port=25
set www-ssl address="" certificate=none disabled=yes port=443
set api address="" disabled=yes port=8728
set winbox address="" disabled=no port=8291
set api-ssl address="" certificate=none disabled=yes port=8729

#################################################################################################################

###Below you need to change x.x.x.x/x for your technical subnet. This subnet will have full access to the router.###

/ip firewall address-list add address=x.x.x.x/x disabled=no list=support

###Below we have the bogon list.###

/ip firewall address-list

add address=0.0.0.0/8 comment="Self-Identification [RFC 3330]" disabled=no list=bogons
add address=10.0.0.0/8 comment="Private[RFC 1918] - CLASS A # Check if you need this subnet before enable it"\
disabled=yes list=bogons
add address=127.0.0.0/8 comment="Loopback [RFC 3330]" disabled=no list=bogons
add address=169.254.0.0/16 comment="Link Local [RFC 3330]" disabled=no list=bogons
add address=172.16.0.0/12 comment="Private[RFC 1918] - CLASS B # Check if you need this subnet before enable it"\
disabled=yes list=bogons
add address=192.168.0.0/16 comment="Private[RFC 1918] - CLASS C # Check if you need this subnet before enable it"\
disabled=yes list=bogons
add address=192.0.2.0/24 comment="Reserved - IANA - TestNet1" disabled=no list=bogons
add address=192.88.99.0/24 comment="6to4 Relay Anycast [RFC 3068]" disabled=no list=bogons
add address=198.18.0.0/15 comment="NIDB Testing" disabled=no list=bogons
add address=198.51.100.0/24 comment="Reserved - IANA - TestNet2" disabled=no list=bogons
add address=203.0.113.0/24 comment="Reserved - IANA - TestNet3" disabled=no list=bogons
add address=224.0.0.0/4 comment="MC, Class D, IANA # Check if you need this subnet before enable it"\
disabled=yes list=bogons

####### Now we have protection against: SynFlood, ICMP Flood, Port Scan, Email Spam and much more. For more information read the comments.###

/ip firewall filter
add action=add-src-to-address-list address-list=Syn_Flooder address-list-timeout=30m chain=input \
comment="Add Syn Flood IP to the list" connection-limit=30,32 disabled=no protocol=tcp tcp-flags=syn
add action=drop chain=input comment="Drop to syn flood list" disabled=no src-address-list=Syn_Flooder
add action=add-src-to-address-list address-list=Port_Scanner address-list-timeout=1w chain=input comment="Port Scanner Detect"\
disabled=no protocol=tcp psd=21,3s,3,1
add action=drop chain=input comment="Drop to port scan list" disabled=no src-address-list=Port_Scanner
add action=jump chain=input comment="Jump for icmp input flow" disabled=no jump-target=ICMP protocol=icmp
add action=drop chain=input\
comment="Block all access to the winbox - except to support list # DO NOT ENABLE THIS RULE BEFORE ADD YOUR SUBNET IN THE SUPPORT ADDRESS LIST"\
disabled=yes dst-port=8291 protocol=tcp src-address-list=!support
add action=jump chain=forward comment="Jump for icmp forward flow" disabled=no jump-target=ICMP protocol=icmp
add action=drop chain=forward comment="Drop to bogon list" disabled=no dst-address-list=bogons
add action=add-src-to-address-list address-list=spammers address-list-timeout=3h chain=forward comment="Add Spammers to the list for 3 hours"\
connection-limit=30,32 disabled=no dst-port=25,587 limit=30/1m,0 protocol=tcp
add action=drop chain=forward comment="Avoid spammers action" disabled=no dst-port=25,587 protocol=tcp src-address-list=spammers
add action=accept chain=input comment="Accept DNS - UDP" disabled=no port=53 protocol=udp
add action=accept chain=input comment="Accept DNS - TCP" disabled=no port=53 protocol=tcp
add action=accept chain=input comment="Accept to established connections" connection-state=established\
disabled=no
add action=accept chain=input comment="Accept to related connections" connection-state=related disabled=no
add action=accept chain=input comment="Full access to SUPPORT address list" disabled=no src-address-list=support
add action=drop chain=input comment="Drop anything else! # DO NOT ENABLE THIS RULE BEFORE YOU MAKE SURE ABOUT ALL ACCEPT RULES YOU NEED"\
disabled=yes
add action=accept chain=ICMP comment="Echo request - Avoiding Ping Flood" disabled=no icmp-options=8:0 limit=1,5 protocol=icmp
add action=accept chain=ICMP comment="Echo reply" disabled=no icmp-options=0:0 protocol=icmp
add action=accept chain=ICMP comment="Time Exceeded" disabled=no icmp-options=11:0 protocol=icmp
add action=accept chain=ICMP comment="Destination unreachable" disabled=no icmp-options=3:0-1 protocol=icmp
add action=accept chain=ICMP comment=PMTUD disabled=no icmp-options=3:4 protocol=icmp
add action=drop chain=ICMP comment="Drop to the other ICMPs" disabled=no protocol=icmp
add action=jump chain=output comment="Jump for icmp output" disabled=no jump-target=ICMP protocol=icmp
