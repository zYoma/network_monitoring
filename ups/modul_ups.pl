#!/usr/bin/perl

use strict;
use Fcntl;
use CGI;
use 5.010;
use Net::SNMP;
my $my_cgi;
my $line;



print "Content-type: text/html\n\n";
 $my_cgi = new CGI;
 $line = $my_cgi->param('name2');
 $line =~ s/^(\d)\.(.+)/$1 $2/;
 my $modul = $1;
 my $ups = $2;
 
   my ($session, $error) = Net::SNMP->session
        (
            -retries => "1",
            -hostname => $ups,
            -version => "1",
            -community => "icomm",
            -port => 161,
            -timeout => "1",
            -translate => [-octetstring => 0x0]
        );
		
 my( @list);
     push( @list, (".1.3.6.1.4.1.2254.2.4.3.8", INTEGER, $modul));
	my $result = $session->set_request( -varbindlist => [@list]);

  print "<font color = 'green'>ок!</font>";
  $session->close();  
  

