#!/usr/bin/perl

use strict;
use Fcntl;
use CGI;
use 5.010;
my $my_cgi;
my $line;


my $alarms = 'alarms.txt';
my $alarms_nvrsk = 'alarms_nvrsk.txt';
my $alarms_ktv = 'alarms_ktv.txt';
my $alarms_mkp = 'alarms_mkp.txt';
my @strings;
my @strings_alarms;
my @strings_alarms_nvrsk;
my @strings_alarms_mkp;
my @strings_alarms_ktv;
my @list;
my @list_nvrsk;
my @list_mkp;
my @list_anapa;
my %chek = ();


print "Content-type: text/html\n\n";
 $my_cgi = new CGI;

 
 open(FID,$alarms);
@strings_alarms = <FID>;
chomp @strings_alarms;
close(FID);

 open(FIL,$alarms_nvrsk);
@strings_alarms_nvrsk = <FIL>;
chomp @strings_alarms_nvrsk;
close(FIL);

 open(FIL,$alarms_mkp);
@strings_alarms_mkp = <FIL>;
chomp @strings_alarms_mkp;
close(FIL);

open(FIR,$alarms_ktv);
@strings_alarms_ktv = <FIR>;
chomp @strings_alarms_ktv;
close(FIR);

foreach $line(@strings_alarms) 
{
$line =~ s/^\s+//;
$line =~ s/^(\S+)\s(.+)$/$1 $2/;
my $device = $1;
my $adress_alarm = "$2";

my @df_output = qx (cat /var/www/html/op/sw/monitor/shpd_logs.txt |grep -E  -i '($device)');
my $smth = pop @df_output;
if ($smth =~ /\sдоступно/){$smth =~ s/^(<font color = 'green'>)(.+<\/font>).+/$1 востановлено $2/;}
elsif ($smth =~ /недоступно/){$smth =~ s/^(<font color = 'red'>.+<\/font>).+/$1/;}
unless(exists($chek{"$adress_alarm"})){
push @list,"$adress_alarm  ($smth)<br>";
$chek{$adress_alarm} = $adress_alarm;
}
}
$#strings_alarms = -1;

foreach $line(@strings_alarms_ktv) 
{
$line =~ s/^\s+//;
$line =~ s/^(\S+)\s(.+)$/$1 $2/;
my $device = $1;
my $adress_alarm_ktv = "$2";
my @df_output = qx (cat /var/www/html/op/sw/monitor/shpd_logs.txt |grep -E  -i '($device)');
my $smth = pop @df_output;
if ($smth =~ /\sдоступно/){$smth =~ s/^(<font color = 'green'>)(.+<\/font>).+/$1 востановлено $2/;}
elsif ($smth =~ /недоступно/){$smth =~ s/^(<font color = 'red'>.+<\/font>).+/$1/;}
elsif ($smth =~ /Уровни сигналов/){$smth =~ s/^\S+\s(<font color = 'red'>.+<\/font>).+/$1/;}
unless(exists($chek{"$adress_alarm_ktv"})){
push @list,"$adress_alarm_ktv  ($smth)<br>";
$chek{$adress_alarm_ktv} = $adress_alarm_ktv;
}
}
$#strings_alarms_ktv = -1;

foreach $line(@strings_alarms_nvrsk) 
{
$line =~ s/^\s+//;
$line =~ s/^(\S+)\s(.+)$/$1 $2/;
my $host = $1;
my $adress_alarm = "$2";
my @df_output = qx (cat /var/www/html/op/sw/monitor/shpd_logs.txt |grep -E  -i '($host)');
my $smth = pop @df_output;
if ($smth =~ /\sдоступно/){$smth =~ s/^(<font color = 'green'>)(.+<\/font>).+/$1 востановлено $2/;}
elsif ($smth =~ /недоступно/){$smth =~ s/^(<font color = 'red'>.+<\/font>).+/$1/;}
unless(exists($chek{"$adress_alarm"})){
if ($host =~ /-nvrsk-/){ push @list_nvrsk,"$adress_alarm  ($smth)<br>"; }
elsif ($host =~ /-anp-/){ push @list_anapa,"$adress_alarm  ($smth)<br>"; }
$chek{$adress_alarm} = $adress_alarm;
}

}
$#strings_alarms_nvrsk = -1;

foreach $line(@strings_alarms_mkp) 
{
$line =~ s/^\s+//;
$line =~ s/^(\S+)\s(.+)$/$1 $2/;
my $host = $1;
my $adress_alarm = "$2";
my @df_output = qx (cat /var/www/html/op/sw/monitor/shpd_logs.txt |grep -E  -i '($host)');
my $smth = pop @df_output;
if ($smth =~ /\sдоступно/){$smth =~ s/^(<font color = 'green'>)(.+<\/font>).+/$1 востановлено $2/;}
elsif ($smth =~ /недоступно/){$smth =~ s/^(<font color = 'red'>.+<\/font>).+/$1/;}
unless(exists($chek{"$adress_alarm"})){
 push @list_mkp,"$adress_alarm  ($smth)<br>"; 
$chek{$adress_alarm} = $adress_alarm;
}

}
$#strings_alarms_mkp = -1;

my %values;
@values{@list} = ();
my @unique_list = keys %values;
my @sorted = sort @unique_list;

%values = ();
$#unique_list = -1;
@values{@list_nvrsk} = ();
@unique_list = keys %values;
my @sorted_nvrsk = sort @unique_list;

%values = ();
$#unique_list = -1;
@values{@list_anapa} = ();
@unique_list = keys %values;
my @sorted_anapa = sort @unique_list;

%values = ();
$#unique_list = -1;
@values{@list_mkp} = ();
@unique_list = keys %values;
my @sorted_mkp = sort @unique_list;
 



print "<center><font color='brown'><h2>Аварии на сети:</h2> </font></center><br><div class=\"text\">";
print "<h3><b>Краснодар:</b><br></h3>";
print "<h3>@sorted<br></h3>";
print "<h3><b>Новороссийск:</b><br></h3>";
print "<h3>@sorted_nvrsk<br></h3>";
print "<h3><b>Анапа:</b><br></h3>";
print "<h3>@sorted_anapa<br></h3>";
print "<h3><b>Майкоп:</b><br></h3>";
print "<h3>@sorted_mkp<br></h3>";
print "</div>";

