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

my %result_lldp=();
my %hashMac_count = ();
my $rootPortOid ='.1.3.6.1.2.1.17.2.7';
my $lldpPortNumberOid = '.1.0.8802.1.1.2.1.4.1.1.7';
my $rootPort;
my $portMac;
my @mac;
my %hashMac=();
my %hashLLDPdescription=();
my $lldp_description;
my $lldp_port_number;
my %hashLLDP=();
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
my $CrcIn='1.3.6.1.2.1.10.7.2.1.2';
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
my %portAdmin =();
my %portCrc =();
my %nameMac =();
my $id_port;

print "Content-type: text/html\n\n";
$my_cgi = new CGI;
 $input = $my_cgi->param('name');

#$input = 'fh2-kdr-metalnikova28-p1';

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
	$CrcIn='.1.3.6.1.2.1.16.1.1.1.8';
	}

#DES-3200-28
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.113.1.3")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 2;
	
	}

#DES-3200-52/C1
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.113.9.1")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 3;
	$CrcIn='.1.3.6.1.2.1.16.1.1.1.8';
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
	$CrcIn='.1.3.6.1.2.1.16.1.1.1.8';
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
	$CrcIn='.1.3.6.1.2.1.16.1.1.1.8';
	}
#DES-3028
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.63.6")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 12;
	
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
	}

#DES-1210-28/ME-B3   
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.75.15.3")
	{
	$getFireware = '.1.3.6.1.4.1.171.10.75.15.3.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.75.15.3.1.30.0';
	$getRev = '.1.3.6.1.4.1.171.10.75.15.3.1.2.0';
	$id = 15;
	}

#DES-3526
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.64.1")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.1.2.7.1.2.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 16;
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
	$CrcIn='.1.3.6.1.2.1.16.1.1.1.8';
	}

#EDGE-Core ECS3510-28T  
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.259.10.1.27.101")
	{
	$getFireware = '.1.3.6.1.4.1.259.10.1.27.1.1.3.1.6';
	$getSn = '.1.3.6.1.4.1.259.10.1.27.1.1.3.1.10';
	$id = 20;
	$CrcIn='.1.3.6.1.2.1.16.1.1.1.8';

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
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.92"  || $result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.80" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.229")
	{
	$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.67108873';
	$id = 24;
	$CrcIn='1.3.6.1.2.1.2.2.1.14';
	}




	   #Huawei S5300-28X-LI-24S-AC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.221" )
	{
	$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.67108873';
	$id = 25;
	$CrcIn='1.3.6.1.2.1.2.2.1.14';
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

#Cisco ME360x
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.1250")
{
$id = 33;

}

#Quidway S5624P 
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.10.1.43")
{
$id = 31;
$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.67108873';
	$CrcIn='1.3.6.1.2.1.2.2.1.14';
}

#Quidway S9303
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.170.1")
{
$id = 32;
$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.67108867';
	$CrcIn='1.3.6.1.2.1.2.2.1.14';
}

	   #Huawei S2352P-EI
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.94" )
	{
	$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.67108873';
	$id = 34;
	$CrcIn='1.3.6.1.2.1.2.2.1.14';
	}

#FiberHome S4820-28T-X
elsif ( $result->{$snmp_oid} eq ".1.3.6.1.4.1.3807.1.482816" )
	{
    $CrcIn='1.3.6.1.2.1.2.2.1.14';
	$id = 36;
	}
#FiberHome S4820-28T-X
elsif ( $result->{$snmp_oid} eq ".1.3.6.1.4.1.3807.1.485201" )
	{
    $CrcIn='1.3.6.1.2.1.2.2.1.14';
	$id = 37;
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
		
		if ($id == 24  ){
		
									
		if ($name_port =~/Loop/ || $name_port =~/Vlan/ || $name_port =~/NULL/ ) {next;}
			if ($name_port =~/GigabitEthernet0\/0\/1/) {$id_port  = 25; $nameMac{ $name_port } = $id_port;}
			elsif ($name_port =~/GigabitEthernet0\/0\/2/) {$id_port  = 26; $nameMac{ $name_port } = $id_port;}
			elsif ($name_port =~/GigabitEthernet0\/0\/3/) {$id_port  = 27; $nameMac{ $name_port } = $id_port;}
			elsif ($name_port =~/GigabitEthernet0\/0\/4/) {$id_port  = 28; $nameMac{ $name_port } = $id_port;}
			else{
				my $kostil = $name_port;
				$kostil =~ s/\/(\d+)$/$1/;
				 $id_port = $1;
				$nameMac{ $name_port } = $id_port;
				}
		}

	if ($id == 34  ){
		
			
		if ($name_port =~/Loop/ || $name_port =~/Vlan/ || $name_port =~/NULL/ ) {next;}
			if ($name_port =~/GigabitEthernet0\/0\/1/) {$id_port  = 49; $nameMac{ $name_port } = $id_port;}
			elsif ($name_port =~/GigabitEthernet0\/0\/2/) {$id_port  = 50; $nameMac{ $name_port } = $id_port;}
			elsif ($name_port =~/GigabitEthernet0\/0\/3/) {$id_port  = 51; $nameMac{ $name_port } = $id_port;}
			elsif ($name_port =~/GigabitEthernet0\/0\/4/) {$id_port  = 52; $nameMac{ $name_port } = $id_port;}
			else{
				my $kostil = $name_port;
				$kostil =~ s/\/(\d+)$/$1/;
				 $id_port = $1;
				$nameMac{ $name_port } = $id_port;
				}
		}
		
			if ( $id == 25 ){
		
		if ($name_port =~/Loop/ || $name_port =~/Vlan/ || $name_port =~/NULL/ || $name_port =~/Console/  ) {next;}
			if ($name_port =~/XGigabitEthernet0\/0\/1/) {$id_port  = 25; $nameMac{ $name_port } = $id_port;}
			elsif ($name_port =~/XGigabitEthernet0\/0\/2/) {$id_port  = 26; $nameMac{ $name_port } = $id_port;}
			elsif ($name_port =~/XGigabitEthernet0\/0\/3/) {$id_port  = 27; $nameMac{ $name_port } = $id_port;}
			elsif ($name_port =~/XGigabitEthernet0\/0\/4/) {$id_port  = 28; $nameMac{ $name_port } = $id_port;}
			else{
				my $kostil = $name_port;
				$kostil =~ s/\/(\d+)$/$1/;
				 $id_port = $1;
				$nameMac{ $name_port } = $id_port;
				}
		}



		
		
		#say "port - $temp_port   name - $name_port";
		$hash{ $temp_port } = $name_port;
		}
		
	#while ( ($temp_port,$name_port) = each %hash) {
  #print "$temp_port => $name_port\n";
}
	

	
			#Cкорость на порту
	$snmptemp = $session->get_table(
        -baseoid        => '.1.3.6.1.2.1.2.2.1.5',
        -maxrepetitions => 25

	);

	foreach my $oid2(oid_lex_sort(keys(%{$session->var_bind_list}))) {
		if ($oid2 =~ /^.1.3.6.1.2.1.2.2.1.5\.([\d]+)$/) {
			my $port = $1;
			my $tempSpeed = $session->var_bind_list->{$oid2};
			if ( $tempSpeed eq '10000000'){$tempSpeed='<font color=\'red\'>10 Mb/s</font>'}
		if ( $tempSpeed eq '100000000'){$tempSpeed='<font color=\'#0489B1\'>100 Mb/s</font>'}
		if ( $tempSpeed eq '1000000000'){$tempSpeed='<font color=\'green\'>1 Gb/s</font>'}	
		if ( $tempSpeed eq '4294967295'){$tempSpeed='<font color=\'green\'>10 Gb/s</font>'}
				if  ($port > 0) {

					$portSpeed{ $port } = $tempSpeed;
				}
			
		}
	}
	

	eval{
	#Маки на портах
	unless ($id == 10 || $id == 9 || $id == 17 || $id == 18 || $id == 11 || $id == 25 || $id == 4 || $id == 5 || $id == 6 || $id == 7 || $id == 8 || $id == 26 || $id == 27 || $id == 28 || $id == 29 || $id == 30 || $id == 33 || $id == 37){
	#для хуавеев
			if ($id == 24 || $id == 25 || $id == 34 ){
				$macTable =".1.3.6.1.2.1.17.4.3.1.2";
				$result = $session->get_table(
					-baseoid        => $macTable,
					-maxrepetitions => 25
				);

				foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) {
					if ($oid =~ /^.1.3.6.1.2.1.17.4.3.1.2\.([\d]+)\.([\d]+)\.([\d]+)\.([\d]+)\.([\d]+)\.([\d]+)$/) {
						my $mac = join '-', map((sprintf '%.2x', $_), ($1, $2, $3, $4, $5, $6));
						#if ($mac =~ /^d4-60-e3/){$mac = "$mac"."&nbsp;<i><font color ='green' size =2>Sercomm</font></i>"}#Серкомы
						$mac = "<font color ='#CD5C5C'>$mac</font>";
						my $port = $session->var_bind_list->{$oid};
						#$port = $port+4;
						
					if ( $id != 34){
					if ($port <25) {
						
							$hashMac{$port}=$mac;
							}
						}
			else{

				if ($port < 49) {
				
							$hashMac{$port}=$mac;
							}
			}
								
								
							#забераем все маки для определения колличества маков на порту
							$hashMac_count{$port} = [] if not exists $hashMac_count{$port};  
							push @{ $hashMac_count{$port} }, $mac;
							
					}
				}
			}
			else{
				$snmptemp = $session->get_table(
					-baseoid        => $macTable,
					-maxrepetitions => 25

				);
					foreach my $oid1 (oid_lex_sort(keys(%{$session->var_bind_list}))) {
						if ($oid1 =~ /^$macTable\.([\d]+)\.([\d]+)\.([\d]+)\.([\d]+)\.([\d]+)\.([\d]+)\.([\d]+)$/) {
							my $vlan1 = $1;
							my $mac1 = join '-', map((sprintf '%.2x', $_), ($2, $3, $4, $5, $6, $7));
							#if ($mac1 =~ /^d4-60-e3/){$mac1 = "$mac1"."&nbsp;<i><font color ='green' size =2>Sercomm</font></i>"}#Серкомы
							
						$mac1 = "<font color ='#CD5C5C'>$mac1</font>";
							$portMac = $session->var_bind_list->{$oid1};
								
								if ($portMac < 49 && $id == 3 ){
								$hashMac{$portMac}=$mac1;
								
								}
								if ($portMac < 25 && $id != 5 ){
								$hashMac{$portMac}=$mac1;
								
								}
								#забераем все маки для определения колличества маков на порту
								$hashMac_count{$portMac} = [] if not exists $hashMac_count{$portMac};  
								push @{ $hashMac_count{$portMac} }, $mac1;
								
						}
						
					}
					
					}
					}
	};
	
	
	
	
	
		#CRCin
	$snmptemp = $session->get_table(
        -baseoid        => $CrcIn,
        -maxrepetitions => 25

	);

	foreach my $oid2(oid_lex_sort(keys(%{$session->var_bind_list}))) {
		if ($oid2 =~ /^$CrcIn\.([\d]+)$/) {
			my $port = $1;
			#if ($id==24 || $id==32 ) {$port = $port - 4;}#для хуавеев
			my $tempCrcIn = $session->var_bind_list->{$oid2};
			if ($tempCrcIn >0) {
				$CrcInDisplay = "$tempCrcIn";
			}
				else {
					$CrcInDisplay = "";
				}
			
				if  ($port > 0) {

					#push @crc_in," $CrcInDisplay";
					$portCrc{ $port } = $CrcInDisplay;
				}
			
		}
	}



	#Административный статус порта
	$snmptemp = $session->get_table(
        -baseoid        => $port_admin,
        -maxrepetitions => 25

	);
	foreach my $oid2(oid_lex_sort(keys(%{$session->var_bind_list}))) {
		if ($oid2 =~ /^$port_admin\.([\d]+)$/) {
			my $port2 = $1;
			my $admin_status = $session->var_bind_list->{$oid2};
#if ($id==24 || $id==32 ) {$port2 = $port2 - 4;}#для хуавеев
			if ($admin_status == 2){
				$admin_status2 = "Выключен";
			}
			if ($admin_status == 1){
				$admin_status2 = "";
			}
			
			
				if  ($port2 > 0) {
					#push @port_a,"$admin_status2";
					$portAdmin{ $port2 } = $admin_status2;
				}
			
		}
	}
	
	
	



	#Статусы портов


		$snmptemp = $session->get_table(
        -baseoid        => $port_status,
        -maxrepetitions => 25

		);

	foreach my $oid2(oid_lex_sort(keys(%{$session->var_bind_list}))) {
		if ($oid2 =~ /^$port_status\.([\d]+)$/) {
			my $port = $1;
			
			my $status = $session->var_bind_list->{$oid2};
			if ($status == 2 || $status == 7){
				$status2 = "Down";
				$portSpeed{ $port } = '';
			}
			if ($status == 1){
				$status2 = "";
			}
			#число маков на порту
			my $n;
			if ($id==24 || $id==32  || $id==25 | $id==34){
			if ($hash{$port} eq '') {next;}
			
			if(exists  $hashMac_count{$nameMac{$hash{$port}}} ) {
			my @values = @{ $hashMac_count{$nameMac{$hash{$port}}} }; 
			$n = scalar(@values) ;
			$n = "<font color ='#8B0000'><i>($n)</i></font>";
			}
			}
			
			else{
			 if(exists  $hashMac_count{$port} ) {
			my @values = @{ $hashMac_count{$port} }; 
			$n = scalar(@values) ;
			$n = "<font color ='#8B0000'><i>($n)</i></font>";
			}
			}
			
		if ($id==3 || $id==27 || $id==28 || $id==29 || $id==30 || $id==26 || $id==33){push @port_s,"<b>$hash{$port}</b> - $portSpeed{ $port }$status2 &nbsp; $hashMac{$port} $n &nbsp;&nbsp;&nbsp;$portAdmin{$port}&nbsp;<b>$portCrc{$port}</b>&nbsp;";} #циски
		elsif ($id==24 || $id==25 || $id==32 || $id==34 || $id==36|| $id==37){ if ($port > 0){push @port_s,"<b>$hash{$port}</b> - $portSpeed{ $port }$status2 &nbsp; $hashMac{$nameMac{$hash{$port}}} $n &nbsp;&nbsp;&nbsp;$portAdmin{$port}&nbsp;<b>$portCrc{$port}</b>&nbsp;";}}#хувеи
		else {	
			
		if ($port < 33) {
				if  ($port > 0) {
					push @port_s,"<b>$hash{$port}</b> - $portSpeed{ $port }$status2 &nbsp; $hashMac{$port} $n &nbsp;&nbsp;&nbsp;$portAdmin{$port}&nbsp;<b>$portCrc{$port}</b>&nbsp;";
				}
			}
			}
		}
	}

	

	
	









					
print "Порт &nbsp;&nbsp;/&nbsp;&nbsp;Состояние&nbsp;&nbsp;/&nbsp;&nbsp;Mac (всего маков)&nbsp;/&nbsp;&nbsp;CRC&nbsp;<br><br>";
	#Печатаем оба массива
	for (my $i = 0; $i < scalar(@port_s); $i++ ){
		print "$port_s[$i]<br>";
	}





				
$session->close();





