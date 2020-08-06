#!/usr/bin/perl


use Net::SSH::Perl;

use Fcntl;
use Socket;
use CGI;
use 5.010;

my $my_cgi;
my $b2b_logs ='logs.txt';



print "Content-type: text/html\n\n";
 $my_cgi = new CGI;
 my $line = $my_cgi->param('name');
 my $line2 = $my_cgi->param('name2');
 $line =~ s/\s//g;
 print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Выгрузка будет отправлена на почту $line2";

open(my $fh, '>', $b2b_logs);
print $fh "$line $line2\n";
close $fh;   
 
   