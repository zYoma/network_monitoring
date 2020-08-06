#!/usr/bin/perl 



use Net::SNMP qw(:snmp);
use strict;
use Fcntl;
use Term::ANSIColor qw(:constants);
use Net::Ping;
use Socket;
use POSIX qw(strftime);
use CGI;
use 5.010;



my $portMac;
my @mac;
my %hashMac=();

my $dop;
my $snmp_oid = '.1.3.6.1.2.1.1.2.0';
my $ip;
my $input;
my @vlanDB;
my @NOvlan;
my $getVlanTable =".1.3.6.1.2.1.17.7.1.4.2.1.3";
my $getLldp=".1.0.8802.1.1.2.1.4.1.1.9";
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
my $macTable =".1.3.6.1.2.1.17.7.1.2.2.1.2";
my $getRev = undef;
my $rev = undef;
my $port_status = '.1.3.6.1.2.1.2.2.1.8';
my $port_admin = '.1.3.6.1.2.1.2.2.1.7';
my $status2;
my $admin_status2;
my @port_s;
my @port_a;
my $CrcIn='1.3.6.1.2.1.2.2.1.14';
my $CrcOut='1.3.6.1.2.1.2.2.1.20';
my @crc_in;
my @crc_out;
my $CrcInDisplay;
my $CrcOutDisplay;
my $id=0;
my $my_cgi;
my %hash = ();
my $temp_port;
my $name_port;
my %portSpeed =();
my $StpLastChang;
my $StpCountChang;
my $StpCostRoot;
my $StpIdRoot;
my $StpPrior;
my %stpPortStatus =();
my %stpPortState =();
my %stpPortCost =();
my %stpPortPrior =();
my $portStpStatusOid = '1.3.6.1.2.1.17.2.15.1.3';
my $portStpStateOid ='1.3.6.1.2.1.17.2.15.1.4';
my $portStpCostOid ='1.3.6.1.2.1.17.2.15.1.5';
my $portStpPriorOid ='1.3.6.1.2.1.17.2.15.1.2';
my @list;
my $StpForwardDelay;
 my $StpTxHoldCount;
 my $StpHelloTime;
 my $StpMaxAge;
my $HWport;
my $kPrior;
print "Content-type: text/html\n\n";
$my_cgi = new CGI;
 $input = $my_cgi->param('name');



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
	}

#DES-3200-28
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.113.1.3")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 2;
	$portStpStatusOid = '.1.3.6.1.4.1.171.12.15.2.5.1.6';
	$portStpStateOid ='.1.3.6.1.4.1.171.12.15.2.4.1.4';
	$portStpCostOid ='.1.3.6.1.4.1.171.12.15.2.4.1.5';
	$portStpPriorOid ='.1.3.6.1.4.1.171.12.15.2.5.1.5';
	$dop = '.+';
	}

#DES-3200-52/C1
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.113.9.1")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 3;
	}

#DGS-1210-10/ME/A1      #DGS-1210-10/ME 
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.76.42.1")
	{
	$getFireware = '.1.3.6.1.4.1.171.10.76.42.1.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.76.42.1.1.30.0';
	$getRev = '.1.3.6.1.4.1.171.10.76.42.1.1.2.0';
	$id = 4;
	}

    #DGS-1210-10P/ME/A1 
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.76.35.1" )
	{
	$getFireware = '.1.3.6.1.4.1.171.10.76.35.1.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.76.35.1.1.30.0';
	$getRev = '.1.3.6.1.4.1.171.10.76.35.1.1.2.0';
	$id = 5;
	}

    #DGS-1210-10P/ME/A1 
elsif ( $result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.76.32.1")
	{
	$getFireware = '.1.3.6.1.4.1.171.10.76.32.1.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.76.32.1.1.30.0';
	$getRev = '.1.3.6.1.4.1.171.10.76.32.1.1.2.0';
	$id = 6;
	}

#DGS-3700-12G
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.102.1.2")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 7;
	}

#DGS-1210-28/ME/A1
	elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.76.28.1")
	{
	$getFireware = '.1.3.6.1.4.1.171.10.76.28.1.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.76.28.1.1.30.0';
	$getRev = '.1.3.6.1.4.1.171.10.76.28.1.1.2.0';
	$id = 8;
	}

#DGS-3420-26SC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.119.6")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 9;
	}

#DGS-3627G
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.70.8")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 10;
	}

#DGS-3420-28SC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.119.2")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 11;
	}
#DES-3028
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.63.6")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 12;
	$portStpStatusOid = '.1.3.6.1.4.1.171.12.15.2.5.1.6';
	$portStpStateOid ='.1.3.6.1.4.1.171.12.15.2.4.1.4';
	$portStpCostOid ='.1.3.6.1.4.1.171.12.15.2.4.1.5';
	$portStpPriorOid ='.1.3.6.1.4.1.171.12.15.2.5.1.5';
	$dop = '.+';
}

#D-Link DES-3010G
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.63.1.2")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 13;
	}

##DES-1210-28/ME-B2
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.75.15.2")
	{
	$getFireware = '.1.3.6.1.4.1.171.10.75.15.2.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.75.15.2.1.30.0';
	$getRev = '.1.3.6.1.4.1.171.10.75.15.2.1.2.0';
	$id = 14;
	$portStpStatusOid = '.1.3.6.1.4.1.171.10.75.15.2.6.2.1.12';
	$portStpStateOid ='.1.3.6.1.4.1.171.10.75.15.2.6.2.1.2';
	$portStpCostOid ='.1.3.6.1.4.1.171.10.75.15.2.6.2.1.5';
	$portStpPriorOid ='.1.3.6.1.4.1.171.10.75.15.2.6.2.1.3';
	}

#DES-1210-28/ME-B3   
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.75.15.3")
	{
	$getFireware = '.1.3.6.1.4.1.171.10.75.15.3.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.75.15.3.1.30.0';
	$getRev = '.1.3.6.1.4.1.171.10.75.15.3.1.2.0';
	$id = 15;
	$portStpStatusOid = '.1.3.6.1.4.1.171.10.75.15.3.6.2.1.12';
	$portStpStateOid ='.1.3.6.1.4.1.171.10.75.15.3.6.2.1.2';
	$portStpCostOid ='.1.3.6.1.4.1.171.10.75.15.3.6.2.1.5';
	$portStpPriorOid ='.1.3.6.1.4.1.171.10.75.15.3.6.2.1.3';
	}

#DES-3526
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.64.1")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 16;
	$portStpStatusOid = '.1.3.6.1.4.1.171.12.15.2.5.1.6';
	$portStpStateOid ='.1.3.6.1.4.1.171.12.15.2.4.1.4';
	$portStpCostOid ='.1.3.6.1.4.1.171.12.15.2.4.1.5';
	$portStpPriorOid ='.1.3.6.1.4.1.171.12.15.2.5.1.5';
	$dop = '.+';
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
	}

#EDGE-Core ECS3510-28T  
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.259.10.1.27.101")
	{
	$getFireware = '.1.3.6.1.4.1.259.10.1.27.1.1.3.1.6';
	$getSn = '.1.3.6.1.4.1.259.10.1.27.1.1.3.1.10';
	$id = 20;

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
	}

#H3C S3100-16TP-EI
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.25506.1.245")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 23;
	}

#Huawei S2326TP-EI   #Huawei S2328P-EI-AC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.92" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.80" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.229")
	{
	$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.67108873';
	$id = 24;
	}

	   #Huawei S5300-28X-LI-24S-AC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.221" )
	{
	$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.67108873';
	$id = 25;
	}

  # Catalyst 4500 L3
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.917" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.788")
	{
	#$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.1';
	$id = 26;
	}
	
		  # Catalyst C2960
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.716" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.694" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.799" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.696")
	{
	$getFireware = '.1.3.6.1.4.1.9.2.1.73.0';
	$id = 27;
	}

	#Cisco C3750ME
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.574")
{
$id = 28;
}

#Cisco C2950
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.359")
{
$id = 29;
}

#Cisco ME340x
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.780")
{
$id = 30;
}
#Quidway S5624P 
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.10.1.43")
{
$id = 31;
$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.67108873';
}

#Quidway S9303
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.170.1")
{
$id = 32;
$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.67108867';
}
	else {
		print YELLOW,"Unknown device\n", RESET;
		}
	

#Имена интерфейсов
	
 	$snmptemp = $session->get_table(
	        -baseoid        => '.1.3.6.1.2.1.2.2.1.2',
			-maxrepetitions => 5
			);
	
			
	foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) {
		if ($oid =~ /^.1.3.6.1.2.1.2.2.1.2\.([\d]+)$/) {
		 $temp_port = $1;
		 if ($id == 32){ $temp_port = $1-7;}
		$name_port = $session->var_bind_list->{$oid};
		if ($name_port =~ /(\s)(?=Port)/){
		
		$name_port=~ s/^.+\b(Port)/$1/g;
		if ($id == 7 || $id == 9 ||$id == 11 || $id == 13|| $id == 16){
		$name_port=~ s/^(\bPort\s+\d+).+/$1/;
		}
		}
		
		if ($name_port =~ /(,\s)(?=port)/){
		$name_port=~ s/^.+\b(port)/$1/g;
		}
		
		$hash{ $temp_port } = $name_port;
		}
		
	#while ( ($temp_port,$name_port) = each %hash) {
  #print "$temp_port => $name_port\n";
}
	

	
	#Определяем root порт и другие параметры STP
	if ($id == 14){
	
 #приоритет стп
 $snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.2.6.1.3.0");
 $StpPrior = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.2.6.1.3.0"};
  #id корня
 $snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.2.6.1.9.0");
 $StpIdRoot = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.2.6.1.9.0"};
$StpIdRoot = unpack('H16', $StpIdRoot);
$StpIdRoot=~ /^(\w).+/;
$kPrior = $1*4096;
$StpIdRoot=~ s/^(\w\w\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)/$kPrior-$2-$3-$4-$5-$6-$7/;
   #стоимость до корня
 $snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.2.6.1.10.0");
 $StpCostRoot = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.2.6.1.10.0"};
 #Число изменений топологии
 $snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.2.6.4.3.0");
 $StpCountChang = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.2.6.4.3.0"};
  #время с последнего изменения топологии
  $snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.2.6.4.4.0");
 $StpLastChang = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.2.6.4.4.0"};
  #MaxAge
  $snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.2.6.1.5.0");
 $StpMaxAge = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.2.6.1.5.0"};
 $StpMaxAge=~ s/^(.+)00$/$1/;
 #HelloTime
  $snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.2.6.1.6.0");
 $StpHelloTime = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.2.6.1.6.0"};
 $StpHelloTime=~ s/^(.+)00$/$1/;
  #TxHoldCount
  $snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.2.6.1.4.0");
 $StpTxHoldCount = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.2.6.1.4.0"};
 $StpTxHoldCount=~ s/^(.+)00$/$1/;
  #ForwardDelay
  $snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.2.6.1.7.0");
 $StpForwardDelay = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.2.6.1.7.0"};
 $StpForwardDelay=~ s/^(.+)00$/$1/;
	}
		elsif ($id == 15){
	#приоритет стп
 $snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.3.6.1.3.0");
 $StpPrior = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.3.6.1.3.0"};
  #id корня
 $snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.3.6.1.9.0");
 $StpIdRoot = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.3.6.1.9.0"};
$StpIdRoot = unpack('H16', $StpIdRoot);
$StpIdRoot=~ /^(\w).+/;
$kPrior = $1*4096;
$StpIdRoot=~ s/^(\w\w\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)/$kPrior-$2-$3-$4-$5-$6-$7/;
   #стоимость до корня
 $snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.3.6.1.10.0");
 $StpCostRoot = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.3.6.1.10.0"};
 #Число изменений топологии
 $snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.3.6.4.3.0");
 $StpCountChang = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.3.6.4.3.0"};
  #время с последнего изменения топологии
  $snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.3.6.4.4.0");
 $StpLastChang = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.3.6.4.4.0"};
   #MaxAge
  $snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.3.6.1.5.0");
 $StpMaxAge = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.3.6.1.5.0"};
 $StpMaxAge=~ s/^(.+)00$/$1/;
 #HelloTime
  $snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.3.6.1.6.0");
 $StpHelloTime = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.3.6.1.6.0"};
 $StpHelloTime=~ s/^(.+)00$/$1/;
  #TxHoldCount
  $snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.3.6.1.4.0");
 $StpTxHoldCount = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.3.6.1.4.0"};
 $StpTxHoldCount=~ s/^(.+)00$/$1/;
  #ForwardDelay
  $snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.3.6.1.7.0");
 $StpForwardDelay = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.3.6.1.7.0"};
 $StpForwardDelay=~ s/^(.+)00$/$1/;
	}
		
			elsif ($id == 12 || $id == 16 || $id == 2){
	#приоритет стп
 $snmptemp = $session -> get_request("1.3.6.1.4.1.171.12.15.2.3.1.12.0");
 $StpPrior = $snmptemp -> {"1.3.6.1.4.1.171.12.15.2.3.1.12.0"};
  #id корня
 $snmptemp = $session -> get_request("1.3.6.1.4.1.171.12.15.2.3.1.13");
 $StpIdRoot = $snmptemp -> {"1.3.6.1.4.1.171.12.15.2.3.1.13"};
$StpIdRoot = unpack('H16', $StpIdRoot);
$StpIdRoot=~ /^(\w).+/;
$kPrior = $1*4096;
$StpIdRoot=~ s/^(\w\w\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)/$kPrior-$2-$3-$4-$5-$6-$7/;
   #стоимость до корня
 $snmptemp = $session -> get_request("1.3.6.1.4.1.171.12.15.2.3.1.14.0");
 $StpCostRoot = $snmptemp -> {"1.3.6.1.4.1.171.12.15.2.3.1.14.0"};
 #Число изменений топологии
 $snmptemp = $session -> get_request("1.3.6.1.4.1.171.12.15.2.3.1.22.0");
 $StpCountChang = $snmptemp -> {"1.3.6.1.4.1.171.12.15.2.3.1.22.0"};
  #время с последнего изменения топологии
  $snmptemp = $session -> get_request("1.3.6.1.4.1.171.12.15.2.3.1.21.0");
 $StpLastChang = $snmptemp -> {"1.3.6.1.4.1.171.12.15.2.3.1.21.0"};
  #MaxAge
  $snmptemp = $session -> get_request("1.3.6.1.4.1.171.12.15.2.3.1.19.0");
 $StpMaxAge = $snmptemp -> {"1.3.6.1.4.1.171.12.15.2.3.1.19.0"};
 $StpMaxAge=~ s/^(.+)00$/$1/;

  #ForwardDelay
  $snmptemp = $session -> get_request("1.3.6.1.4.1.171.12.15.2.3.1.20.0");
 $StpForwardDelay = $snmptemp -> {"1.3.6.1.4.1.171.12.15.2.3.1.20.0"};
 $StpForwardDelay=~ s/^(.+)00$/$1/;
	}
	else{
 	#приоритет стп
 $snmptemp = $session -> get_request(".1.3.6.1.2.1.17.2.2.0");
 $StpPrior = $snmptemp -> {".1.3.6.1.2.1.17.2.2.0"};
  #id корня
 $snmptemp = $session -> get_request(".1.3.6.1.2.1.17.2.5.0");
 $StpIdRoot = $snmptemp -> {".1.3.6.1.2.1.17.2.5.0"};
 
$StpIdRoot = unpack('H16', $StpIdRoot);
$StpIdRoot=~ /^(\w).+/;
$kPrior = $1*4096;
$StpIdRoot=~ s/^(\w\w\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)/$kPrior-$2-$3-$4-$5-$6-$7/;
   #стоимость до корня
 $snmptemp = $session -> get_request(".1.3.6.1.2.1.17.2.6.0");
 $StpCostRoot = $snmptemp -> {".1.3.6.1.2.1.17.2.6.0"};
 #Число изменений топологии
 $snmptemp = $session -> get_request(".1.3.6.1.2.1.17.2.4.0");
 $StpCountChang = $snmptemp -> {".1.3.6.1.2.1.17.2.4.0"};
  #время с последнего изменения топологии
  $snmptemp = $session -> get_request(".1.3.6.1.2.1.17.2.3.0");
 $StpLastChang = $snmptemp -> {".1.3.6.1.2.1.17.2.3.0"};
 #MaxAge
  $snmptemp = $session -> get_request("1.3.6.1.2.1.17.2.8.0");
 $StpMaxAge = $snmptemp -> {"1.3.6.1.2.1.17.2.8.0"};
 $StpMaxAge=~ s/^(.+)00$/$1/;
 #HelloTime
  $snmptemp = $session -> get_request("1.3.6.1.2.1.17.2.9.0");
 $StpHelloTime = $snmptemp -> {"1.3.6.1.2.1.17.2.9.0"};
 $StpHelloTime=~ s/^(.+)00$/$1/;
  #TxHoldCount
  $snmptemp = $session -> get_request("1.3.6.1.2.1.17.2.10.0");
 $StpTxHoldCount = $snmptemp -> {"1.3.6.1.2.1.17.2.10.0"};
 $StpTxHoldCount=~ s/^(.+)00$/$1/;
  #ForwardDelay
  $snmptemp = $session -> get_request("1.3.6.1.2.1.17.2.11.0");
 $StpForwardDelay = $snmptemp -> {"1.3.6.1.2.1.17.2.11.0"};
 $StpForwardDelay=~ s/^(.+)00$/$1/;
  #maxhops

	}
	

			#Состояние stp на порту
	$snmptemp = $session->get_table(
        -baseoid        => "$portStpStatusOid",
        -maxrepetitions => 25

	);

	foreach my $oid2(oid_lex_sort(keys(%{$session->var_bind_list}))) {
		if ($oid2 =~ /^$portStpStatusOid\.([\d]+)$dop$/) {
			my $port = $1;
			my $stpStatus = $session->var_bind_list->{$oid2};
			
			if ($id == 12 || $id == 16 || $id == 2){
			if ( $stpStatus == 1){$stpStatus='<font color=\'red\'>other</font>';}
		elsif ( $stpStatus == 2){$stpStatus='<font color=\'red\'>disabled</font>';}
		elsif ( $stpStatus == 3){$stpStatus='<font color=\'#0489B1\'>discarding</font>';}	
		elsif ( $stpStatus  == 4){$stpStatus='<font color=\'green\'>learning</font>';}
		elsif ( $stpStatus  == 5){$stpStatus='<font color=\'green\'>forwarding</font>';}
		elsif ( $stpStatus == 6){$stpStatus='<font color=\'#0489B1\'>broken</font>';}
		elsif ( $stpStatus == 7){$stpStatus='<font color=\'red\'>no-stp-enabled</font>';}
			}	
			else {
			if ( $stpStatus == 1){$stpStatus='<font color=\'red\'>disabled</font>';}
		elsif ( $stpStatus == 2){$stpStatus='<font color=\'#0489B1\'>discarding</font>';}
		elsif ( $stpStatus == 3){$stpStatus='<font color=\'green\'>listening</font>';}	
		elsif ( $stpStatus  == 4){$stpStatus='<font color=\'green\'>learning</font>';}
		elsif ( $stpStatus  == 5){$stpStatus='<font color=\'green\'>forwarding</font>';}
		elsif ( $stpStatus == 6){$stpStatus='<font color=\'#0489B1\'>broken</font>';}
			}
			if  ($port > 0) {

					$stpPortStatus{ $port } = $stpStatus;
				}
		}
	}
	
			#Стоимость stp на порту
	$snmptemp = $session->get_table(
        -baseoid        => "$portStpCostOid",
        -maxrepetitions => 25

	);

	foreach my $oid2(oid_lex_sort(keys(%{$session->var_bind_list}))) {
		if ($oid2 =~ /^$portStpCostOid\.([\d]+)$/) {
			my $port = $1;
			my $stpCost = $session->var_bind_list->{$oid2};
			
			if  ($port > 0) {

					$stpPortCost{ $port } = $stpCost;
				}
		}
	}
	
				#Приоритет stp на порту
	$snmptemp = $session->get_table(
        -baseoid        => "$portStpPriorOid",
        -maxrepetitions => 25

	);

	foreach my $oid2(oid_lex_sort(keys(%{$session->var_bind_list}))) {
		if ($oid2 =~ /^$portStpPriorOid\.([\d]+)$dop$/) {
			my $port = $1;
			my $stpPrior = $session->var_bind_list->{$oid2};
			
			if  ($port > 0) {

					$stpPortPrior{ $port } = $stpPrior;
				}
		}
	}
	
	#Статус stp на порту
	$snmptemp = $session->get_table(
        -baseoid        => "$portStpStateOid",
        -maxrepetitions => 25

	);

	foreach my $oid2(oid_lex_sort(keys(%{$session->var_bind_list}))) {
		if ($oid2 =~ /^$portStpStateOid\.([\d]+)$/) {
			my $port = $1;
			if ($id == 24 || $id == 32) {$HWport = $1+4;}
			my $stpState = $session->var_bind_list->{$oid2};
			
		if ( $stpState == 1){
		#Убераем порты абонов на кривых эдчкорах
		   if ($id == 19 || $id == 20) {
		       if ($port >24) {
			   $stpPortState{ $port } = $stpState;
		push @list,"<b>$hash{$port}</b> - $stpPortCost{$port} - $stpPortPrior{ $port } - $stpPortStatus{$port}<br>";
			   }
		
		}
		else {
		$stpPortState{ $port } = $stpState;
		     if ($id == 24){ #отдельно для хуавеев
		     push @list,"<b>$hash{$HWport}</b> - $stpPortCost{$port} - $stpPortPrior{ $port } - $stpPortStatus{$port}<br>";
		     }
			 else {
			 push @list,"<b>$hash{$port}</b> - $stpPortCost{$port} - $stpPortPrior{ $port } - $stpPortStatus{$port}<br>";
			 }
		}
		}
		}
	}
	
	


				
$session->close();


print "Приоритет: <b>$StpPrior</b><br> ID рута:<b> $StpIdRoot</b><br>Стоимость до рута:<b> $StpCostRoot</b><br>Число перестроений stp: <b>$StpCountChang</b><br>Последнее изменение:<b> $StpLastChang</b>";
print "<br>MaxAge:<b>$StpMaxAge</b>&nbsp;&nbsp;&nbsp; HelloTime:<b>$StpHelloTime</b><br> TxHoldCount:<b>$StpTxHoldCount</b>&nbsp;&nbsp;&nbsp; ForwardDelay:<b>$StpForwardDelay</b>";
print "<br><br><b>Порт - Стоимость - Приоритет - Состояние</b><br><br>";

print @list;


print "<br><br><br><br><b><u>Стоимость:</u></b><br>10 Мбит/с &nbsp;&nbsp;- 2 000 000<br>100 Мбит/с  - 200 000<br>1 Гбит/с   &nbsp;&nbsp;&nbsp;&nbsp; - 20 000<br>10 Гбит/с   &nbsp;&nbsp;  - 2 000";