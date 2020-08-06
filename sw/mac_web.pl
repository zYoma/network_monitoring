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

my $vlanCisco;
my %hashStatus=();
my %hashPorts=();
my %hashMac=();
my %hash = ();
my $temp_port;
my $name_port;
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
my $temp;
my $hashports;
my $type;
my @vlans;
my $session;
my  $community;
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
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.92"  || $result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.94"|| $result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.80" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.229")
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
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.780" )
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
		$name_port = $session->var_bind_list->{$oid};
	$hash{ $temp_port } = $name_port;
		}
		
	
}

	#Таблица маков

		#для хуавеев
			if ($id == 24 || $id == 25 || $id == 32){
				$macTable =".1.3.6.1.2.1.17.4.3.1.2";
				$result = $session->get_table(
					-baseoid        => $macTable,
					-maxrepetitions => 25
				);

				foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) {
					if ($oid =~ /^.1.3.6.1.2.1.17.4.3.1.2\.([\d]+)\.([\d]+)\.([\d]+)\.([\d]+)\.([\d]+)\.([\d]+)$/) {
						my $mac = join '-', map((sprintf '%.2x', $_), ($1, $2, $3, $4, $5, $6));
						my $port = $session->var_bind_list->{$oid};
							if($id == 32){$port = $port+7;}
							elsif($id == 24 || $id == 25){$port = $port+4;}
								print " mac: <b>$mac</b> port: <b>$hash{ $port }</b><br>";
							
					}
				}
			}
			
			#для cisco
			
			elsif ($id == 29 || $id == 27 || $id == 28 || $id == 29 || $id == 30 || $id == 33 ){
			

	#Cписок вланов
			 	$snmptemp = $session->get_table(
	        -baseoid        => '.1.3.6.1.4.1.9.9.46.1.3.1.1.2.1',
			-maxrepetitions => 5
			);
	
			
	foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) {
		if ($oid =~ /^.1.3.6.1.4.1.9.9.46.1.3.1.1.2.1\.([\d]+)$/) {
		 my $vlanNumver = $1;
		 push @vlans,"$vlanNumver";
	
		}
		
	
}
$session->close();

eval {

			foreach  $vlanCisco (@vlans) {
     $community = "icomm\@$vlanCisco";
	#print "$community\n";
	#print "$vlanCisco\n";
 ($session, $error) = Net::SNMP->session
        (
            -retries => "2",
            -hostname => $input,
            -version => "2c",
            -community => "$community",
            -port => 161,
            -timeout => "2",
            -translate => [-octetstring => 0x0]
        );
			
				$macTable =".1.3.6.1.2.1.17.4.3.1";
				$result = $session->get_table(
					-baseoid        => $macTable,
				
					-maxrepetitions => 25
				);

				foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) {
				#Маки
					if ($oid =~ /^$macTable\.1\.(.+)$/) {
						 $temp = $1;
						my $mac = $session->var_bind_list->{$oid};
						$mac =  unpack('H16', $mac);
						$mac =~ s/^(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)/$1-$2-$3-$4-$5-$6/;
						$hashMac{ $temp } = $mac;	
							
					}
					#порты
					if ($oid =~ /^$macTable\.2\.(.+)$/) {
						 $temp = $1;
						my $port = $session->var_bind_list->{$oid};
						
						if($id = 26 && $port!= 0){$port = $port +1;}
						if($id = 27 && $port!= 0){$port = $port -1;}
						
						#$port = $hash{$port};
						$hashPorts{ $temp } = $port;
							
					}
					
					#тип записи
					if ($oid =~ /^$macTable\.3\.(.+)$/) {
						 $temp = $1;
						$type = $session->var_bind_list->{$oid};
							
						if ($type== 1) {$type ='other';}
						if ($type== 2) {$type ='invalid';}
						if ($type== 3) {$type ='learned';}
						if ($type== 4) {$type ='self';}
						if ($type== 5) {$type ='mgmt';}
						$hashStatus{ $temp } = $type;
					}
					
					
				}
				  for my $key ( keys %hashMac ) {
       
		
		print "mac: <b>$hashMac{$key}</b>  vlan: <b>$vlanCisco</b>  Port: <b>$hashPorts{$key}</b> <br>";
		
    }
	%hashMac = ();
	%hashPorts = ();
		$session->close();	
			}
			};
	}		
			
			else{
			#для всех остальных
				$snmptemp = $session->get_table(
					-baseoid        => $macTable,
					-maxrepetitions => 25

				);
					foreach my $oid1 (oid_lex_sort(keys(%{$session->var_bind_list}))) {
						if ($oid1 =~ /^$macTable\.([\d]+)\.([\d]+)\.([\d]+)\.([\d]+)\.([\d]+)\.([\d]+)\.([\d]+)$/) {
							my $vlan1 = $1;
							my $mac1 = join '-', map((sprintf '%.2x', $_), ($2, $3, $4, $5, $6, $7));
							my $port1 = $session->var_bind_list->{$oid1};
								
									print "mac: <b>$mac1</b> vlan: <b>$vlan1</b> port: <b>$port1</b><br>";
								

						}
					}
				}
	



				
$session->close();


