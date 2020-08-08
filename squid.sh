#!/bin/bash

############################################################################
# Squid Proxy Installer (SPI)                                              #
# Version: 2.0 Build 2017                                                  #
# Branch: Stable                                                           #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Author: Hidden Refuge (© 2014 - 2017)                                    #
# License: MIT License                                                     #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# GitHub Repo: https://github.com/hidden-refuge/spi/                       #
# SPI Wiki: https://github.com/hidden-refuge/spi/wiki                      #
############################################################################

# Declaring a few misc variables
vspiversion=2.0 # SPI version
vspibuild=2017 # SPI build number
vbranch=Stable # SPI build branch
vsysarch=$(getconf LONG_BIT) # System architecture

# Function for iptables rules (CentOS 7, Debian, Ubuntu, Fedora)
firew2 ()	{
	# Opening default Squid port 3128 for clients to connect
	iptables -I INPUT -p tcp --dport 3128 -j ACCEPT
	# Saving firewall rules
	iptables-save
}


# Function for Ubuntu
ubt ()	{
	# Updating package database
	apt-get update
	# Installing necessary packages (Squid, apache2-utils for htpassword and dependencies)
	apt-get install apache2-utils squid3 -y
	# Asking user to set a server port
	read -e -p "Your desired server port: " port
	# Asking user to set a username via read and writing it into $usrn
	read -e -p "Your desired username: " usrn
	# Creating user with username from $usrn and asking user to set a password
	htpasswd -c /etc/squid/passwd $usrn
	# Downloading Squid configuration
	echo 'http_port' $port > /etc/squid/squid.conf
	echo 'cache deny all
hierarchy_stoplist cgi-bin ?

access_log none
cache_store_log none
cache_log /dev/null

refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320

acl localhost src 127.0.0.1/32 ::1
acl to_localhost dst 127.0.0.0/8 0.0.0.0/32 ::1

acl SSL_ports port 1-65535
acl Safe_ports port 1-65535
acl CONNECT method CONNECT
acl siteblacklist dstdomain "/etc/squid/blacklist.acl"
http_access allow manager localhost
http_access deny manager

http_access deny !Safe_ports

http_access deny CONNECT !SSL_ports
http_access deny siteblacklist
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd

auth_param basic children 5
auth_param basic realm Squid proxy-caching web server
auth_param basic credentialsttl 2 hours
acl password proxy_auth REQUIRED
http_access allow localhost
http_access allow password
http_access deny all

forwarded_for off
request_header_access Allow allow all
request_header_access Authorization allow all
request_header_access WWW-Authenticate allow all
request_header_access Proxy-Authorization allow all
request_header_access Proxy-Authenticate allow all
request_header_access Cache-Control allow all
request_header_access Content-Encoding allow all
request_header_access Content-Length allow all
request_header_access Content-Type allow all
request_header_access Date allow all
request_header_access Expires allow all
request_header_access Host allow all
request_header_access If-Modified-Since allow all
request_header_access Last-Modified allow all
request_header_access Location allow all
request_header_access Pragma allow all
request_header_access Accept allow all
request_header_access Accept-Charset allow all
request_header_access Accept-Encoding allow all
request_header_access Accept-Language allow all
request_header_access Content-Language allow all
request_header_access Mime-Version allow all
request_header_access Retry-After allow all
request_header_access Title allow all
request_header_access Connection allow all
request_header_access Proxy-Connection allow all
request_header_access User-Agent allow all
request_header_access Cookie allow all
request_header_access All deny all' >> /etc/squid/squid.conf
	# Creating empty blacklist.acl file for further blacklisting entries
	touch /etc/squid/blacklist.acl	
	# Restarting Squid and enabling its service
	service squid restart && update-rc.d squid defaults
	# Running function firew2
	firew2
}


# Default function with information
dinfo ()	{
	echo "Squid Proxy Installer $vspiversion Build $vspibuild"
	echo "You are using builds from the $vbranch branch"
	echo ""
	echo "Usage: bash spi <option>"
	echo "Example (Debian 8): bash spi -jessie"
	echo ""
	echo "Options:"
	echo "-ubuntu  -- Ubuntu"
	echo ""
	echo "How to add more users:"
	echo "https://github.com/hidden-refuge/spi/wiki/User-management"
	echo ""
	echo "How to blacklist domains:"
	echo "https://github.com/hidden-refuge/spi/wiki/Domain-blacklist"
	echo ""
	echo ""
	echo "(C) 2014 - 2017 by Hidden Refuge"
	echo "GitHub Repo: https://github.com/hidden-refuge/spi"
	echo "SPI Wiki: https://github.com/hidden-refuge/spi/wiki"
}

# Checking $1 and running corresponding function
case $1 in
	'-ubuntu') # If option "-ubuntu" run function ubt
		ubt;; # Ubuntu
	*) # If option empty or non existing run function info
		dinfo;; # Default, information about available options and et cetera
esac