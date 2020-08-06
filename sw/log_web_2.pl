#!/usr/bin/perl 



use Net::SNMP;
use strict;
use Fcntl;
use Term::ANSIColor qw(:constants);
use Net::Ping;
use Socket;
use POSIX qw(strftime);
use CGI;
use 5.010;







my $snmp_oid = '.1.3.6.1.2.1.1.2.0';
my $ip;
my $input;
my @vlanDB;
my @NOvlan;
my $getFireware;
my $getRev;
my $getSn;
my $snmptemp;
my @lldpDB;
my $lldp;
my $firmware;
my $serial;
my $device;
my $sysname;
my $mac;
my $uptime;
my %snmplldpnei_hash = ();
my $remotemac;
my $getRev = undef;
my $rev = undef;
my $logFile ;
my $logFile2;
my @strings;
my $id=0;
my $my_cgi;
my $line;
my $line2;
my @strings;
my @strings2;
my $sysname;
print "Content-type: text/html\n\n";
$my_cgi = new CGI;
 $input = $my_cgi->param('name');

print " <title> Лог $input</title>";
print "
<style >

	body {
background-color: #ECF6CE;
</style >";
my ($session, $error) = Net::SNMP->session
        (
            -retries => "2",
            -hostname => $input,
            -version => "2c",
            -community => "icomm",
            -port => 161,
            -timeout => "2",
            -translate => [-octetstring => 0x0]
        );


				
my	$result = $session->get_request("$snmp_oid");

#DES-3200-28/C1
if ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.113.5.1")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 1;
	$logFile = "/home/network/log/dlink.log";
	$logFile2 = "/home/network/log/dlink.log.1";
	}

#DES-3200-28
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.113.1.3")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 2;
	$logFile = "/home/network/log/dlink.log";
	$logFile2 = "/home/network/log/dlink.log.1";
	}

#DES-3200-52/C1
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.113.9.1")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 3;
	$logFile = "/home/network/log/dlink.log";
	$logFile2 = "/home/network/log/dlink.log.1";
	}

#DGS-1210-10/ME/A1      #DGS-1210-10/ME 
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.76.42.1")
	{
	$getFireware = '.1.3.6.1.4.1.171.10.76.42.1.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.76.42.1.1.30.0';
	$getRev = '.1.3.6.1.4.1.171.10.76.42.1.1.2.0';
	$id = 4;
	$logFile = "/home/network/log/dlink.log";
	$logFile2 = "/home/network/log/dlink.log.1";
	}

    #DGS-1210-10P/ME/A1 
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.76.35.1" )
	{
	$getFireware = '.1.3.6.1.4.1.171.10.76.35.1.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.76.35.1.1.30.0';
	$getRev = '.1.3.6.1.4.1.171.10.76.35.1.1.2.0';
	$id = 5;
	$logFile = "/home/network/log/dlink.log";
	$logFile2 = "/home/network/log/dlink.log.1";
	}

    #DGS-1210-10P/ME/A1 
elsif ( $result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.76.32.1")
	{
	$getFireware = '.1.3.6.1.4.1.171.10.76.32.1.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.76.32.1.1.30.0';
	$getRev = '.1.3.6.1.4.1.171.10.76.32.1.1.2.0';
	$id = 6;
	$logFile = "/home/network/log/dlink.log";
	$logFile2 = "/home/network/log/dlink.log.1";
	}

#DGS-3700-12G
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.102.1.2")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 7;
	$logFile = "/home/network/log/dlink.log";
	$logFile2 = "/home/network/log/dlink.log.1";
	}

#DGS-1210-28/ME/A1
	elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.76.28.1")
	{
	$getFireware = '.1.3.6.1.4.1.171.10.76.28.1.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.76.28.1.1.30.0';
	$getRev = '.1.3.6.1.4.1.171.10.76.28.1.1.2.0';
	$id = 8;
	$logFile = "/home/network/log/dlink.log";
	$logFile2 = "/home/network/log/dlink.log.1";
	}

#DGS-3420-26SC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.119.6")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 9;
	$logFile = "/home/network/log/dlink.log";
	$logFile2 = "/home/network/log/dlink.log.1";
	}

#DGS-3627G
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.70.8")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 10;
	$logFile = "/home/network/log/dlink.log";
	$logFile2 = "/home/network/log/dlink.log.1";
	}

#DGS-3420-28SC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.119.2")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 11;
	$logFile = "/home/network/log/dlink.log";
	$logFile2 = "/home/network/log/dlink.log.1";
	}
#DES-3028
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.63.6")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 12;
	$logFile = "/home/network/log/dlink.log";
	$logFile2 = "/home/network/log/dlink.log.1";
}

#D-Link DES-3010G
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.63.1.2")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 13;
	$logFile = "/home/network/log/dlink.log";
	$logFile2 = "/home/network/log/dlink.log.1";
	}

##DES-1210-28/ME-B2
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.75.15.2")
	{
	$getFireware = '.1.3.6.1.4.1.171.10.75.15.2.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.75.15.2.1.30.0';
	$getRev = '.1.3.6.1.4.1.171.10.75.15.2.1.2.0';
	$id = 14;
	$logFile = "/home/network/log/dlink.log";
	$logFile2 = "/home/network/log/dlink.log.1";
	}

#DES-1210-28/ME-B3   
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.75.15.3")
	{
	$getFireware = '.1.3.6.1.4.1.171.10.75.15.3.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.75.15.3.1.30.0';
	$getRev = '.1.3.6.1.4.1.171.10.75.15.3.1.2.0';
	$id = 15;
	$logFile = "/home/network/log/dlink.log";
	$logFile2 = "/home/network/log/dlink.log.1";
	}

#DES-3526
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.64.1")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 16;
	$logFile = "/home/network/log/dlink.log";
	$logFile2 = "/home/network/log/dlink.log.1";
	}

#ZyXEL IES-1000 AAM1008-61
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.890.1.5.11.6")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 17;
	}

#ZyXEL GS-4012F
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.890.1.5.8.20")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 18;
	}

#EDGE-Core ES3528M
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.259.6.10.94")
	{

	$getSn = '.1.3.6.1.4.1.259.6.10.94.1.1.3.1.10';
	$getFireware = '.1.3.6.1.4.1.259.6.10.94.1.1.3.1.6.1';
	$id = 19;
	$logFile = "/home/network/log/edgecore.log";
	$logFile2 = "/home/network/log/edgecore.log.1";
	}

#EDGE-Core ECS3510-28T  
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.259.10.1.27.101")
	{
	$getFireware = '.1.3.6.1.4.1.259.10.1.27.1.1.3.1.6';
	$getSn = '.1.3.6.1.4.1.259.10.1.27.1.1.3.1.10';
	$id = 20;
$logFile = "/home/network/log/edgecore.log";
$logFile2 = "/home/network/log/edgecore.log.1";
	}

#24-port 10/100 + 4-Port Gigabit Switch with CLI and WebView
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.3955.6.9.224.1")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 21;
	}

#H3C S3100-26TP-EI
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.25506.1.246")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 22;
	$logFile = "/home/network/log/huawei.log";
	$logFile2 = "/home/network/log/huawei.log.1";
	}

#H3C S3100-16TP-EI
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.25506.1.245")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 23;
	$logFile = "/home/network/log/huawei.log";
	$logFile2 = "/home/network/log/huawei.log.1";
	}

#Huawei S2326TP-EI   #Huawei S2328P-EI-AC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.92" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.80" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.229")
	{
	$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.67108873';
	$id = 24;
	$logFile = "/home/network/log/huawei.log";
	$logFile2 = "/home/network/log/huawei.log.1";
	}

	   #Huawei S5300-28X-LI-24S-AC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.221" )
	{
	$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.67108873';
	$id = 25;
	$logFile = "/home/network/log/huawei.log";
	$logFile2 = "/home/network/log/huawei.log.1";
	}

 # Catalyst 4500 L3
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.917" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.788")
	{
	#$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.1';
	$id = 26;
	$logFile = "/home/network/log/cisco.log";
	$logFile2 = "/home/network/log/cisco.log.1";
	}
	
		  # Catalyst C2960
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.716" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.694" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.799" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.696")
	{
	$getFireware = '.1.3.6.1.4.1.9.2.1.73.0';
	$id = 27;
	$logFile = "/home/network/log/cisco.log";
	$logFile2 = "/home/network/log/cisco.log.1";
	}

	#Cisco C3750ME
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.574")
{
$id = 28;
$logFile = "/home/network/log/cisco.log";
$logFile2 = "/home/network/log/cisco.log.1";
}

#Cisco C2950
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.359")
{
$id = 29;
$logFile = "/home/network/log/cisco.log";
$logFile2 = "/home/network/log/cisco.log.1";
}

#Cisco ME340x
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.780")
{
$id = 30;
$logFile = "/home/network/log/cisco.log";
$logFile2 = "/home/network/log/cisco.log.1";
}

#Cisco ME360x
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.1250")
{
$id = 33;
$logFile = "/home/network/log/cisco.log";
$logFile2 = "/home/network/log/cisco.log.1";
}

#Quidway S5624P 
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.10.1.43")
{

$id = 31;
$logFile = "/home/network/log/huawei.log";
$logFile2 = "/home/network/log/cisco.log.1";
}

#Quidway S9303
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.170.1")
{

$id = 32;
$logFile = "/home/network/log/huawei.log";
$logFile2 = "/home/network/log/huawei.log.1";
}

	else {
		print YELLOW,"Unknown device\n", RESET;
		}
	


	#get sysName
$snmptemp = $session -> get_request(".1.3.6.1.2.1.1.5.0");
  $sysname = $snmptemp -> {".1.3.6.1.2.1.1.5.0"};
  if ($id==27 || $id==28 || $id==29 || $id==30 || $id==26) {$sysname =~ s/^(.+)\.\baaanet.ru/$1/;}
	
	$session->close();
	
		if ($input =~ /^\d/){
#Получаем NS запись
$input = gethostbyaddr(inet_aton($input), AF_INET)
 or die "Can't resolve $input: $!\n";
$input =~ s/(\w+)\.\w+/$1/; #отрезаем .local
}
	
	open(FIL,$logFile);
@strings = <FIL>;
chomp @strings;
close(FIL);
	
		open(FIA,$logFile2);
@strings2 = <FIA>;
chomp @strings2;
close(FIA);



foreach $line2 (@strings2)
{

    if ($line2 =~ /$input/) {
	$line2 =~ s/^.+?\s(.+)/$1/;
	print $line2;
	print "<br>";
	}
	
}	

foreach $line (@strings)
{
#my $data = join "", $line;
    if ($line =~ /$input/) {
	$line =~  s/^.+?\s(.+)/$1/; # удалить все что до первого пробела
	print $line;
	print "<br>";
	}
	
}

			



