#!/usr/bin/perl

use strict;
use Fcntl;
use CGI;
use 5.010;

my $alarms = 'tt.txt';

print "Content-type: text/html\n\n";
 my $my_cgi = new CGI;

 open(FID,$alarms);
my @strings_alarms = <FID>;
chomp @strings_alarms;
close(FID);

foreach my $line(@strings_alarms) 
{
print $line;
}