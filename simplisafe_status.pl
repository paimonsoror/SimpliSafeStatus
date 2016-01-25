#!/usr/bin/perl
################################################
#
# Get SimpliSafe alarm status
#
# @Author Paimon Sorornejad
################################################

# Strict and Warnings Enable
use strict;
use warnings;

# Set debug to 1 if you would like to enable
# debug mode, also, the cookie directory
# is where we will store the cookie file
my $debug = 0;
my $cookie_dir = "/tmp/sscookie.txt";

# User and password information.  At this time
# it seems that SS only supports plain text
# passwords over https.
my $user = "mySSUser\@gmail.com";
my $pw   = "abcdefgh";

#################################################
# Step 1
# get our cookies and store them in our defined
# directory
#################################################
my $cookie_post = `curl -s -X POST -c $cookie_dir -d 'name=$user&pass=$pw&device_name=openhab&&device_uuid=51644e80-1b62-11e3-b773-0800200c9a66&version=1200&no_persist=1&XDEBUG_SESSION_START=session_name' https://simplisafe.com/mobile/login/`;

print "Login Status: $cookie_post\n" if $debug;

#################################################
# Step 2
# Now let's read our cookies output file to grab our UID
#################################################
my $readCookies;
if(-e $cookie_dir) {
        local $/;
	open my $fh, '<', $cookie_dir;
        $readCookies = <$fh>;
        close $fh;
}
print "Cookie File: $readCookies\n" if $debug;

# grab our UID
my ($ss_uid) = $readCookies =~ /DRUPAL_UID\s+(\d+)/;

print "UID: $ss_uid\n" if $debug;

#################################################
# Step 3
# grab our alarm status
#################################################
my $ss_status = `curl -s -X POST -b $cookie_dir -d 'no_persist=1&XDEBUG_SESSION_START=session_name' https://simplisafe.com/mobile/$ss_uid/locations`;
print "Alarm Status Response: $ss_status\n" if $debug;

# and parse the status from the output
my ($ss_status_string) = $ss_status =~ /\"system\_state\":\"(.*)\"/;
print "Alarm Status String: $ss_status_string\n" if $debug;

#################################################
# Step 4
# logout
#################################################
my $ss_logout = `curl -s -X POST -b $cookie_dir -d 'no_persist=1&XDEBUG_SESSION_START=session_name' https://simplisafe.com/mobile/logout`;

print "Logout Status: $ss_logout\n" if $debug;

# Echo out the value of our status for the openhab
# command line parser to read
print $ss_status_string if !$debug;
