#!/bin/sh
# Authors  : KatrinaTheLamia
# Projects : OOPSH
# License  : see Documentation/LICENSE.txt
# Groups   : NIMH Labs
# File     : $root/Modules/sandvinequit.sh
# Purpose  :
# Negates a poorly thought out technique often used to try to stop bit 
# torrent. The technique operates on the grounds of setting up a man in the 
# Middle on the bit torrent prot--then just simply sends reset packets to the 
# clients at both ends.
#
# Here it is modified to allow for variable ports to be used in this negation 
# of a rather poor attempt to stop this crappy method to remove bittorrent.
#
# Also it has come to the attention of the person who originally wrong it, that 
# most of the functionality may be useful outside this scope

export timestamp_request=13
export timestamp_response=14
export icmp_ping=0

#= oops_sandvine_negate
#Argument: tcp port
#Argument: udp port
# This is mostly a place holder until we put all of these into easier functions
# Functions we need are:
# oops_reset_negate($tcp)
# oops_tcp_port_allow($tcp)
# oops_udp_port_allow($udp)
# oops_tcp_port_negate($tcp)
# oops_udp_port_negate($udpp)
# Yes--there is a lot of customisability of the functionality we are dropping here,
# but how many people really use these features? Most people just custom generate 
# or have other people make these based on what is needed. And most of these 
# iptables commands ARE fairly common. This is mostly allowed to add a layer of 
# simplicity to iptables, so that people can be eased into this stuff gently
oops_sandvine_negate($tcp, $udp) {
    # drop the reset tcp packets sent to this computron
    iptables -A INPUT -p tcp -m tcp --dport $tcp --tcp-flags RST RST -j DROP;
    # allow other stuff to this port to be accepted
    iptables -A INPUT -p tcp -m tcp --dport $tcp -j ACCEPT;
    # accept stuff to the UDP port given
    iptables -A INPUT -p udp -m udp --dport $udp -j ACCEPT;
}

#= oops_timestamp_negate
# In some cases you may not want to allow timestamps requests
oops_timestamp_request_negate() {
    iptables -A INPUT -p icmp -m icmp --icmp-type $timestamp_request -j DROP;
}

#= oops_timestamp_allow
# Arguments: interface
# Yeah... let us allow timestamps requests... you may need to turn this back on.
oops_timestamp_allow($interface) {
    iptables -A INPUT -o $interface -p icmp -m icmp --icmp-type $timestamp_request -kj ALLOW;
}

#= oops_response_allow
# Arguments : interface
# In the case we asked for something... let us accept it.
oops_response_allow($interface) {
    iptables -A INPUT -o $interface -m state --state RELATED,ESTABLISHED -j ACCEPT;
}

#= oops_response_negate
# Yeah--including this only for completeness. This allows us to talk to other 
# people, but not have them talk back.
oops_response_negate() {
    iptables -A INPUT -m state --state RELATED,ESTABLISHED -j DENY;
}

#= oops_ignore_allow
# yeah--ignore everything that comes in
oops_ignore_allow() {
    iptables -A INPUT -j DENY;
}

#= oops_ignore_negate
# Arguments : interface
# This will allow input into a specific interface.
oops_ignore_negate($interface) {
    iptables -A INPUT -o $interface -j ALLOW;
}

#= oops_talk_allow
# Arguments : interface
# Allow an interface to be heard
oops_talk_allow($interface) {
    iptables -A OUTPUT -o $interface -j ALLOW;
}

#= oops_talk_negate
# Deny an interface to talk.
oops_talk_negate() {
    iptables -A OUTPUT -j DENY;
}

#= oops_timestamp_reply_negate
# do _not_ reply to timestamps
oops_timestamp_reply_negate() {
     iptables -A OUTPUT -p icmp -m icmp --icmp-type $timestamp_response -j DROP
}

#= oops_timestamp_reply_allow
# Argumnets : interface
# Allow a timestamp reply on a given interface
oops_timestamp_reply_allow($interface) {
    iptables -A OUTPUT -o $interface -p icmp -m icmp --icmp-type $timestamp_response -j DROP
}

#= oops_pong_deny
# Deny outgoing icmp echo
oops_pong_deny() {
    iptables -A OUTPUT -p icmp -m icmp --icmp-type $icmp_ping -j DROP
}

#= oops_pong_allow
# Arguments: interface
# allow outgoing icmp echo
oops_pong_allow($interface) {
    iptables -A OUTPUT -o $interface -p icmp -m icmp --icmp-type $icmp_ping -j DROP
}

# oops_sandvine_negate(46576, 27008)
# oops_timestamp_negate
# oops_response_allow
# oops_ignore_allow
# oops_talk_allow(lo)
# oops_time_stamp_reply_negate
# oops_ping_deny
