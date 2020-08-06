#!/usr/bin/perl

use strict;
use Fcntl;
use CGI;
use 5.010;
my $my_cgi;
my $line;


my $event = 'event_on_mu.txt';

my @strings;

my @list;

my %chek = ();


print "Content-type: text/html\n\n";
 $my_cgi = new CGI;

 if ( -e $event){
 open(FID,$event);
@strings = <FID>;
chomp @strings;
close(FID);
}
else {
print "<p>-Пусто-</p>";
exit;
}

my @string_2;


foreach $line(@strings) 
{
@string_2 = split /<br>/, $line;

}
my $id = 0;
my @string_3 = reverse @string_2;
foreach $line(@string_3) 
{
$line =~ s/^\s*\S+\s\S+\s//;
if ($id == 0){
$line = "<p style = \"background-color: #D9F6F4;\">$line</p>";
}
print "<p>$line</p>";
$id = 1;
}


 




