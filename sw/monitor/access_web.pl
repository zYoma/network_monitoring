#!/usr/bin/perl

use strict;
use Fcntl;

use Socket;
use 5.010;
use CGI;
use POSIX qw(strftime);
use DBI;

my $bd='bd.txt';
my $bd_nvrsk='bd_access_nvrsk.txt';
my $bd_anapa='bd_access_anapa.txt';
my $bd_mkp='bd_access_mkp.txt';
my $bd_glz='bd_access_glz.txt';
my $alarms = 'alarms.txt';
my $alarms_nvrsk = 'alarms_nvrsk.txt';
my $alarms_mkp = 'alarms_mkp.txt';
my $alarms_glz = 'alarms_glz.txt';
my $alarms_ktv = 'alarms_ktv.txt';
my @strings;
my @strings_nvrsk;
my @strings_anapa;
my @strings_mkp;
my @strings_glz;
my @strings_alarms;
my @strings_alarms_nvrsk;
my @strings_alarms_mkp;
my @strings_alarms_glz;
my $key;
my $line;
my %bd_hash = ();
my %bd_hash_nvrsk = ();
my %bd_hash_anapa = ();
my %bd_hash_mkp = ();
my %bd_hash_glz = ();
my @tping;
my %ChekAdress =();
my @debug;
my @sorted;
my $my_cgi;
my $alarm_png = 'white.png';
my %bd_alarms =();
my %bd_alarms2 =();
my %bd_alarms_nvrsk =();
my %bd_alarms2_nvrsk =();
my %bd_alarms_mkp =();
my %bd_alarms2_mkp =();
my %bd_alarms_glz =();
my %bd_alarms2_glz =();
my %bd_alarms_ktv =();
my %bd_alarms2_ktv =();
my @strings_alarms_ktv;
my $log = 'log/ip_address_log.txt';
my $anapa;


my $dsn = 'DBI:mysql:site_5000:localhost';
my $db_user_name = 'site_5000';
my $db_password = 'site_5000_pass';


print "Content-type: text/html\n\n";
$my_cgi = CGI->new;

my $ip=$ENV{'REMOTE_ADDR'};


 #---------------------------------------------------------------------------------------------------------- 
my $dbh = DBI->connect($dsn, $db_user_name, $db_password);
my $now_time = strftime "%Y-%m-%d %H-%M-%S", localtime;
$dbh->do("insert into counter (ip, date) values ('$ip', '$now_time')");
$dbh->disconnect();
#---------------------------------------------------------------------------------------------------------- 



print qq~
<head>
  <link rel="stylesheet" href="http://10.40.254.109/op/bootstrap/css/bootstrap.min.css" >

  <link href="access.css" rel="stylesheet">
<title>Мониторинг фиксированной сети.</title>
 <link rel="shortcut icon" href="favicon.ico" type="image/x-icon">
<script type="text/javascript">
window.onload = function() {
    document.forms["my_form2"].submit();
}
</script>

  <script type="text/javascript">
  if (navigator.userAgent.search(/MSIE/) > 0 || navigator.userAgent.search(/NET CLR /) > 0) {window.location.replace("http://10.40.254.109/op/sw/monitor/ie.html");};
   function isSW(obj) {
    var str = obj.text;
   document.getElementById('my_input').value = str;
	document.getElementById('my_form').submit();
	
   }

  </script>
  


</head>
<body>

~;


open(FIL,$bd);
@strings = <FIL>;
chomp @strings;
close(FIL);

open(FID,$alarms);
@strings_alarms = <FID>;
chomp @strings_alarms;
close(FID);

open(FIH,$bd_nvrsk);
@strings_nvrsk = <FIH>;
chomp @strings_nvrsk;
close(FIH);

open(FIT,$bd_anapa);
@strings_anapa = <FIT>;
chomp @strings_anapa;
close(FIT);

open(FIT,$bd_mkp);
@strings_mkp = <FIT>;
chomp @strings_mkp;
close(FIT);

open(FIT,$bd_glz);
@strings_glz = <FIT>;
chomp @strings_glz;
close(FIT);

open(FIN,$alarms_nvrsk);
@strings_alarms_nvrsk = <FIN>;
chomp @strings_alarms_nvrsk;
close(FIN);

open(FIN,$alarms_mkp);
@strings_alarms_mkp = <FIN>;
chomp @strings_alarms_mkp;
close(FIN);

open(FIN,$alarms_glz);
@strings_alarms_glz = <FIN>;
chomp @strings_alarms_glz;
close(FIN);

open(FIR,$alarms_ktv);
@strings_alarms_ktv = <FIR>;
chomp @strings_alarms_ktv;
close(FIR);

foreach $line(@strings) 

{
if ($line =~ /-b2b/){next;}
$line =~ s/^(\S+)\s(\S+)\s(.+)$/$1 $2 $3/;
my $host = "$2\n";
my $adress = "$3\n";
#$adress =~ s/\s+//g;
$bd_hash{$adress}{$host} = $adress;
}
$#strings = -1;

#Новоросс
foreach $line(@strings_nvrsk) 

{
$line =~ s/^(\S+)\s(\S+)\s(.+)$/$1 $2 $3/;
my $host = "$2\n";
my $adress = "$3\n";
#$adress =~ s/\s+//g;
$bd_hash_nvrsk{$adress}{$host} = $adress;
}
$#strings_nvrsk = -1;

foreach $line(@strings_anapa) 

{
$line =~ s/^(\S+)\s(\S+)\s(.+)$/$1 $2 $3/;
my $host = "$2\n";
my $adress = "$3\n";
#$adress =~ s/\s+//g;
$bd_hash_anapa{$adress}{$host} = $adress;
}
$#strings_anapa = -1;

#Майкоп
foreach $line(@strings_mkp) 

{
$line =~ s/^(\S+)\s(\S+)\s(.+)$/$1 $2 $3/;
my $host = "$2\n";
my $adress = "$3\n";
#$adress =~ s/\s+//g;
$bd_hash_mkp{$adress}{$host} = $adress;
}
$#strings_mkp = -1;

#Геленджик
foreach $line(@strings_glz) 

{
$line =~ s/^(\S+)\s(\S+)\s(.+)$/$1 $2 $3/;
my $host = "$2\n";
my $adress = "$3\n";
#$adress =~ s/\s+//g;
$bd_hash_glz{$adress}{$host} = $adress;
}
$#strings_glz = -1;

foreach $line(@strings_alarms_mkp) 
{
$line =~ s/^\s+//;
$line =~ s/^(\S+)\s(.+)$/$1 $2/;
my $host_alarm = "$1\n";
my $adress_alarm = "$2\n";
#$line = $line."\n";
$bd_alarms_mkp{$host_alarm} = $host_alarm;
$bd_alarms2_mkp{$adress_alarm} = $adress_alarm;
}
$#strings_alarms_mkp = -1;

foreach $line(@strings_alarms_glz) 
{
$line =~ s/^\s+//;
$line =~ s/^(\S+)\s(.+)$/$1 $2/;
my $host_alarm = "$1\n";
my $adress_alarm = "$2\n";
#$line = $line."\n";
$bd_alarms_glz{$host_alarm} = $host_alarm;
$bd_alarms2_glz{$adress_alarm} = $adress_alarm;
}
$#strings_alarms_glz = -1;

foreach $line(@strings_alarms_nvrsk) 
{
$line =~ s/^\s+//;
$line =~ s/^(\S+)\s(.+)$/$1 $2/;
my $host_alarm = "$1\n";
my $adress_alarm = "$2\n";
#$line = $line."\n";
$bd_alarms_nvrsk{$host_alarm} = $host_alarm;
$bd_alarms2_nvrsk{$adress_alarm} = $adress_alarm;
if ($host_alarm =~ /-anp-/){$anapa = 1;}
}
$#strings_alarms_nvrsk = -1;

foreach $line(@strings_alarms) 
{
$line =~ s/^\s+//;
$line =~ s/^(\S+)\s(.+)$/$1 $2/;
my $host_alarm = "$1\n";
my $adress_alarm = "$2\n";
#$line = $line."\n";
$bd_alarms{$host_alarm} = $host_alarm;
$bd_alarms2{$adress_alarm} = $adress_alarm;
}
$#strings_alarms = -1;

foreach $line(@strings_alarms_ktv) 
{
$line =~ s/^\s+//;
$line =~ s/^(\S+)\s(.+)$/$1 $2/;
my $host_alarm_ktv = "$1\n";
my $adress_alarm_ktv = "$2\n";

$bd_alarms_ktv{$host_alarm_ktv} = $host_alarm_ktv;
$bd_alarms2_ktv{$adress_alarm_ktv} = $adress_alarm_ktv;
}
$#strings_alarms_ktv = -1;

print "<div class=\"main\">";
print "<div class=\"block-left\">";
print "<div class=\"treeHTML\">";
print "<form action=\"modul_sw.pl\" method=\"post\"  target=\"area\" id=\"my_form\">";
print "<input type=\"hidden\" name=\"name2\" value=\"one\" id=\"my_input\">";
$alarm_png = 'white.png';
my $s = scalar keys %bd_alarms2;
my $s2 = scalar keys %bd_alarms2_ktv;
if($s > 0 || $s2 > 0){$alarm_png = 'red.png';}
print "<div><img src = \"$alarm_png\" height = '15' width = '15'> Краснодар<details><summary></summary>";
foreach my $name (sort keys %bd_hash) {
	$alarm_png = 'white.png';
	if(exists($bd_alarms2{"$name"})){
	$alarm_png = 'red.png';
	}
	if(exists($bd_alarms2_ktv{"$name"})){
	$alarm_png = 'red.png';
	}
	
	print "<div><img src = \"$alarm_png\" height = '15' width = '15'> $name<details><summary></summary>";
    foreach my $subject (sort {($a =~ /(\d)$/)[0] <=> ($b =~ /(\d)$/)[0]||$a cmp $b} keys %{ $bd_hash{$name} }) {
	$alarm_png = 'white.png';
	if(exists($bd_alarms{"$subject"})){
	$alarm_png = 'red.png';
	}
	if(exists($bd_alarms_ktv{"$subject"})){
	$alarm_png = 'red.png';
	}
        print "<div><img src = \"$alarm_png\" height = '15' width = '15'> <a href=\"javascript:{}\" id=\"my_a\" onclick=\"isSW(this)\">$subject</a></div>";
    }
	print "</details></div>";
		
	
}
print "</details></div>";
my $s = scalar keys %bd_alarms2_nvrsk;
if($s > 0){$alarm_png = 'red.png';}
print "<div><img src = \"$alarm_png\" height = '15' width = '15'> Новороссийск<details><summary></summary>";
foreach my $name (sort keys %bd_hash_nvrsk) {
	$alarm_png = 'white.png';
	if(exists($bd_alarms2_nvrsk{"$name"})){
	$alarm_png = 'red.png';
	}
	
	print "<div><img src = \"$alarm_png\" height = '15' width = '15'> $name<details><summary></summary>";
    foreach my $subject (sort {($a =~ /(\d)$/)[0] <=> ($b =~ /(\d)$/)[0]||$a cmp $b} keys %{ $bd_hash_nvrsk{$name} }) {
	$alarm_png = 'white.png';
	if(exists($bd_alarms_nvrsk{"$subject"})){
	$alarm_png = 'red.png';
	}
        print "<div><img src = \"$alarm_png\" height = '15' width = '15'> <a href=\"javascript:{}\" id=\"my_a\" onclick=\"isSW(this)\">$subject</a></div>";
    }
	print "</details></div>";
		
	
}
print "</details></div>";
my $s = scalar keys %bd_alarms2_nvrsk;
if($anapa > 0){$alarm_png = 'red.png';}
print "<div><img src = \"$alarm_png\" height = '15' width = '15'> Анапа<details><summary></summary>";
foreach my $name (sort keys %bd_hash_anapa) {
	$alarm_png = 'white.png';
	if(exists($bd_alarms2_nvrsk{"$name"})){
	$alarm_png = 'red.png';
	}
	
	print "<div><img src = \"$alarm_png\" height = '15' width = '15'> $name<details><summary></summary>";
    foreach my $subject (sort {($a =~ /(\d)$/)[0] <=> ($b =~ /(\d)$/)[0]||$a cmp $b} keys %{ $bd_hash_anapa{$name} }) {
	$alarm_png = 'white.png';
	if(exists($bd_alarms_nvrsk{"$subject"})){
	$alarm_png = 'red.png';
	}
        print "<div><img src = \"$alarm_png\" height = '15' width = '15'> <a href=\"javascript:{}\" id=\"my_a\" onclick=\"isSW(this)\">$subject</a></div>";
    }
	print "</details></div>";
}
print "</details></div>";
my $s = scalar keys %bd_alarms2_mkp;
if($s > 0){$alarm_png = 'red.png';}
print "<div><img src = \"$alarm_png\" height = '15' width = '15'> Майкоп<details><summary></summary>";
foreach my $name (sort keys %bd_hash_mkp) {
	$alarm_png = 'white.png';
	if(exists($bd_alarms2_mkp{"$name"})){
	$alarm_png = 'red.png';
	}
	
	print "<div><img src = \"$alarm_png\" height = '15' width = '15'> $name<details><summary></summary>";
    foreach my $subject (sort {($a =~ /(\d)$/)[0] <=> ($b =~ /(\d)$/)[0]||$a cmp $b} keys %{ $bd_hash_mkp{$name} }) {
	$alarm_png = 'white.png';
	if(exists($bd_alarms_mkp{"$subject"})){
	$alarm_png = 'red.png';
	}
        print "<div><img src = \"$alarm_png\" height = '15' width = '15'> <a href=\"javascript:{}\" id=\"my_a\" onclick=\"isSW(this)\">$subject</a></div>";
    }
	print "</details></div>";
	
	
	
}
print "</details></div>";

#Геленджик
my $s = scalar keys %bd_alarms2_glz;
if($s > 0){$alarm_png = 'red.png';}
print "<div><img src = \"$alarm_png\" height = '15' width = '15'> Геленджик<details><summary></summary>";
foreach my $name (sort keys %bd_hash_glz) {
	$alarm_png = 'white.png';
	if(exists($bd_alarms2_glz{"$name"})){
	$alarm_png = 'red.png';
	}
	
	print "<div><img src = \"$alarm_png\" height = '15' width = '15'> $name<details><summary></summary>";
    foreach my $subject (sort {($a =~ /(\d)$/)[0] <=> ($b =~ /(\d)$/)[0]||$a cmp $b} keys %{ $bd_hash_glz{$name} }) {
	$alarm_png = 'white.png';
	if(exists($bd_alarms_glz{"$subject"})){
	$alarm_png = 'red.png';
	}
        print "<div><img src = \"$alarm_png\" height = '15' width = '15'> <a href=\"javascript:{}\" id=\"my_a\" onclick=\"isSW(this)\">$subject</a></div>";
    }
	print "</details></div>";
	
}
print "</details></div>";




print "</form></div></div>";



print "<div class=\"block-right\">";
print "<form action=\"in.pl\" method=\"post\"  target=\"area\" id=\"my_form2\">";
print "<input type=\"hidden\" name=\"name3\" value=\"one\" id=\"my_input2\"></form>";
print "<left>&nbsp;&nbsp;<a href = \"http://10.40.254.109/op/sw/monitor/\"><img src = \"home.png\"></a>&nbsp;&nbsp;&nbsp;<img src = \"white.png\" height = '15' width = '15'> - на адресе аварий нет.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src = \"red.png\" height = '15' width = '15'> - по данному адресу есть активные аварии.</left>";

print "<iframe name=\"area\" width=\"100%\" height=\"95%\"  frameborder=\"0\" hspace=\"0\" vspace=\"0\" ></iframe>";


print "</div></div></body>";










