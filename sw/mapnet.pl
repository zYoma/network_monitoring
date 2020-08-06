#!/usr/bin/perl
# Topology Discovery, lldp2dot for FTTB by SergiusFacsimile, v3.0.1beta_prostinya
# Skype: SergiusFacsimile
# ICQ: 122823
# sergius.facsimile@gmail.com

use 5.010;
use CGI;
print "Content-type: text/html\n\n";
 $my_cgi = new CGI;
# Conf
my $pingtimeout = '0.200'; 				# зависит от ресурсов машины и пинга до оборудования, примерно должно быть пинг_до_оборудования+150мс
my $snmpport = '161';
my $snmpcommunity = 'icomm';
my $snmpcommunity2 = 'icommQF';
my $snmpversion = '2c';
my $snmptimeout = '2';
my $snmpretries = '5';
my @scanRange;

# body
# use strict;
# use warnings;


use Net::SNMP;
use Net::Ping;

use lldp;


my %lldpmapout = ();
my %edges = ();
my %edges2 = ();
my %database = ();
my %snmplldpnei_hash = ();
my %snmplldpnei_hash2 = ();
my $i;
my $edgesid = 0;
my $edgesid2 = 0;
my $errorcount = 0;

my $input = $my_cgi->param('name');
$input =~ s/\s+//g;

print qq~

 <title> Network MAP</title>
<link rel="shortcut icon" href="favicon.ico" type="image/x-icon">
~;
#--------------------------------------------------------------------------------------------
my @scanRange =lldp::NN($input);
#print "@scanRange";




#push @scanRange, "$input";
#push @scanRange, "d1-kdr-dalnjaja4-2-2-p2";



#---------------------------------------------------------------------------------------------

foreach my $rangeS (@scanRange)
	{
	#say "DEvice - $rangeS<br>";
	#my @range=split /-/,$rangeS;
	#my $startIP=iptools::IPtodec($range[0]);
	#my $endIP=iptools::IPtodec($range[1]);
	#for (my $i=$startIP;$i<=$endIP;$i++)
		#{
		#pingDec($rangeS,$pingtimeout);
		#}
		#если пингуется, добавляем в хеш
		#Проверяем доступность
		my $p = Net::Ping->new("tcp", 2);
		$p->{'port_num'} = 23;
    
		if ($p->ping($rangeS,2)){
		#say "$rangeS YES PING<br>";
		$hosts{$rangeS}=undef;
		}
		$p->close();
		
	#foreach $iphost (keys %hosts)
		#{
		#print "get sysObjct.0 from $iphost... \n";
		#}

	foreach $iphost (keys %hosts)
		{
		delete $hosts{$iphost};
		my %snmpsysobjectid = ();		
		my $snmpsession;
		my $snmperror;
		my $snmptemp;
		my $snmpsysobject;
		my $snmplocalmac;
		my $snmplocation;
		my $snmpsysname;
		my %snmptemp = ();	
		my $request;
		my $id;
		my $sysobject;
		my $localmac;
		my $syslocation;
		my $sysname;
		my $errorcount = 0;
		$sysobject = "";

		#print "get sysObjct.0 from $iphost... ";
		

		
		($snmpsession, $snmperror) = Net::SNMP -> session(  -timeout => $snmptimeout,
									-retries => $snmpretries,
									-hostname => $iphost,
									-version => $snmpversion,
									-community => $snmpcommunity,
									-port => $snmpport,
									-translate => [-octetstring => 0x0],
									 );
				

		#sysObject.0
		my $snmptemp = $snmpsession->get_request('.1.3.6.1.2.1.1.2.0');
		if (ref($snmptemp))
			{
			my %snmpsysobjectid = %{$snmptemp};
			foreach my $values (values %snmpsysobjectid){$sysobjectid = $values;}

			$id = 0;

			# L2
			if($sysobjectid eq ".1.3.6.1.4.1.171.10.63.6")
				{$id = 1; $sysobject = "D-Link DES-3028";}
		
			if($sysobjectid eq ".1.3.6.1.4.1.171.10.64.1")
				{$id = 2; $sysobject = "D-Link DES-3526";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.113.1.1")
				{$id = 3; $sysobject = "D-Link DES-3000-10";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.113.1.2")
				{$id = 4; $sysobject = "D-Link DES-3200-18";}	

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.113.1.5")
				{$id = 5; $sysobject = "D-Link DES-3200-26";}
				
				if($sysobjectid eq ".1.3.6.1.4.1.171.10.113.4.1")
				{$id = 6; $sysobject = "D-Link DES-3200-26/C1";}
		
				if($sysobjectid eq ".1.3.6.1.4.1.171.10.113.9.1")
				{$id = 7; $sysobject = "D-Link DES-3200-52/C1";}
		
				if($sysobjectid eq ".1.3.6.1.4.1.3902.15.2.30.104")
				{$id = 8; $sysobject = "ZTE ZXR10 2928E";}
		
#				if($sysobjectid eq ".1.3.6.1.4.1.3902.15.2.30.105")
#				{$iq{$id = 9; $sysobject = "ZTE ZXR10 2952E";}

				if($sysobjectid eq ".1.3.6.1.4.1.6486.800.1.1.2.2.4.1.1")
				{$id = 10; $sysobject = "Alcatel OS LS 6224";}
				if($sysobjectid eq ".1.3.6.1.4.1.171.10.75.15.2")
				{$id = 11; $sysobject = "DES-1210-28/ME";}
				if($sysobjectid eq ".1.3.6.1.4.1.2011.2.23.92")
				{$id = 12; $sysobject = "Huawei S2326TP-EI";}
				if($sysobjectid eq ".1.3.6.1.4.1.259.10.1.27.101")
				{$id = 13; $sysobject = "EDGE-Core ECS3510-28T";}
				if($sysobjectid eq ".1.3.6.1.4.1.171.10.113.5.1")
				{$id = 14; $sysobject = "D-link DES-3200-28/C1";}	
				if($sysobjectid eq ".1.3.6.1.4.1.25506.1.246")
				{$id = 15; $sysobject = "H3C S3100-26TP-EI";}	
				if($sysobjectid eq ".1.3.6.1.4.1.25506.1.245")
				{$id = 16; $sysobject = "H3C S3100-16TP-EI";}
				if($sysobjectid eq ".1.3.6.1.4.1.2011.2.23.229")
				{$id = 17; $sysobject = "Huawei S2328P-EI-AC";}
				if($sysobjectid eq ".1.3.6.1.4.1.259.6.10.94")
				{$id = 18; $sysobject = "EDGE-Core ES3528M";}
				if($sysobjectid eq ".1.3.6.1.4.1.2011.2.23.80")
				{$id = 19; $sysobject = "Huawei S3328TP-SI";}
				if($sysobjectid eq ".1.3.6.1.4.1.171.10.113.1.3")
				{$id = 20; $sysobject = "D-link DES-3200-28";}
				if($sysobjectid eq ".1.3.6.1.4.1.890.1.5.8.20")
				{$id = 21; $sysobject = "GS-4012F";}
				if($sysobjectid eq ".1.3.6.1.4.1.171.10.63.1.2")
				{$id = 22; $sysobject = "Dlink DES-3010G";}
				if($sysobjectid eq ".1.3.6.1.4.1.3955.6.9.224.1")
				{$id = 23; $sysobject = "Linksys-SPS224G4";}
				if($sysobjectid eq ".1.3.6.1.4.1.171.10.75.15.3")
				{$id = 24; $sysobject = "DES-1210-28/ME-B3";}
				if($sysobjectid eq ".1.3.6.1.4.1.171.10.76.35.1")
				{$id = 25; $sysobject = "DGS-1210-10/ME/A1";}
				if($sysobjectid eq ".1.3.6.1.4.1.171.10.76.42.1")
				{$id = 26; $sysobject = "DGS-1210-10P/ME/A1";}
				if($sysobjectid eq ".1.3.6.1.4.1.2011.2.23.94")
				{$id = 27; $sysobject = "Huawei S2352P-EI";}
				if($sysobjectid eq ".1.3.6.1.4.1.3807.1.482816")
				{$id =28 ; $sysobject = "FiberHome S4820-28T-X";}
				if($sysobjectid eq ".1.3.6.1.4.1.3807.1.485201")
				{$id =29 ; $sysobject = "FiberHome S4820-52T-X";}

			

				
			# L3
			if($sysobjectid eq ".1.3.6.1.4.1.171.10.59.7")
				{$id = 101; $sysobject = "D-Link DXS-3326GSR";}			
		
			if($sysobjectid eq ".1.3.6.1.4.1.171.10.70.9")
				{$id = 102; $sysobject = "D-Link DGS-3612G";}
			
			if($sysobjectid eq ".1.3.6.1.4.1.171.10.70.8")
				{$id = 103; $sysobject = "D-Link DGS-3627G";}

			if($sysobjectid eq ".1.3.6.1.4.1.171.10.117.1.3")
				{$id = 104; $sysobject = "D-Link DGS-3120-24SC";}
				
			if($sysobjectid eq ".1.3.6.1.4.1.171.10.118.2")
				{$id = 105; $sysobject = "D-Link DGS-3620-28SC";}				

			if($sysobjectid eq ".1.3.6.1.4.1.207.1.4.149")
				{$id = 106; $sysobject = "Allied Telesis AT-9000/28SP";}	
				
			if($sysobjectid eq ".1.3.6.1.4.1.1916.2.167")
				{$id = 107; $sysobject = "ExtremeXOS X670-48x";}
			
			if($sysobjectid eq ".1.3.6.1.4.1.3902.3.600.3.1.751")
				{$id = 108; $sysobject = "ZTE 5928E-FI";}
				
			if($sysobjectid eq ".1.3.6.1.4.1.6486.800.1.1.2.1.7.1.10")
				{$id = 109; $sysobject = "Alcatel OS 6850-U24X";}
				if($sysobjectid eq ".1.3.6.1.4.1.171.10.119.6")
				{$id = 110; $sysobject = "D-link DGS-3420-26SC";}
 if($sysobjectid eq ".1.3.6.1.4.1.171.10.76.32.1")
				{$id = 111; $sysobject = "D-link DGS-1210-10/ME";}
				if($sysobjectid eq ".1.3.6.1.4.1.2011.2.23.221")
				{$id = 112; $sysobject = "Huawei S5300-28X-LI-24S-AC";}
				if($sysobjectid eq ".1.3.6.1.4.1.2011.2.170.1")
				{$id = 113; $sysobject = "Huawei Quidway S9303";}
				
				if($sysobjectid eq ".1.3.6.1.4.1.9.1.917" || $sysobjectid eq ".1.3.6.1.4.1.9.1.788")
				{$id = 114; $sysobject = "Catalyst 4500 L3";}
				if($sysobjectid eq ".1.3.6.1.4.1.9.1.716" || $sysobjectid eq ".1.3.6.1.4.1.9.1.694" || $sysobjectid eq ".1.3.6.1.4.1.9.1.799" || $sysobjectid eq ".1.3.6.1.4.1.9.1.696")
				{$id = 115; $sysobject = "Cisco C3750ME";}
				if($sysobjectid eq ".1.3.6.1.4.1.9.1.359")
				{$id = 116; $sysobject = "Cisco C2950";}
				if($sysobjectid eq ".1.3.6.1.4.1.9.1.780")
				{$id = 117; $sysobject = "Cisco ME340x";}
				if($sysobjectid eq ".1.3.6.1.4.1.9.1.1250")
				{$id = 118; $sysobject = "Cisco ME360x";}
				if($sysobjectid eq ".1.3.6.1.4.1.9.1.863")
				{$id = 119; $sysobject = "Cisco c7600";}
				if($sysobjectid eq ".1.3.6.1.4.1.2011.10.1.43")
				{$id = 120; $sysobject = "Quidway S5624P ";}
				if($sysobjectid eq ".1.3.6.1.4.1.171.10.119.2")
				{$id = 121; $sysobject = "DGS-3420-28SC";}
			
				
			# UPS
			if($sysobjectid eq ".1.3.6.1.4.1.2254.2.4")
				{$id = 1000;$sysobject = "Delta GES102R202035";}

			if($sysobjectid eq ".1.3.6.1.4.1.935")
				{$id = 1001;$sysobject = "EngPower EP901RH";}

				
			# Core
			if($sysobjectid eq ".1.3.6.1.4.1.9.1.402")
				{$id = 10000; $sysobject = "Cisco 7606 Chassis";}

			if($sysobjectid eq ".1.3.6.1.4.1.2636.1.1.1.2.25")
				{$id = 10001; $sysobject = "Juniper Networks MX480";}

			if($sysobjectid eq ".1.3.6.1.4.1.9.1.924")
				{$id = 10002; $sysobject = "Cisco IOS Software ASR1004";}			

			if($sysobjectid eq ".1.3.6.1.4.1.2352.1.15")
				{$id = 10003; $sysobject = "Redback Networks SmartEdge 600";}
			
			if($sysobjectid eq ".1.3.6.1.4.1.9.1.821")
				{$id = 10004; $sysobject = "Cisco 7200P-IS-M";}

			if($sysobjectid eq ".1.3.6.1.4.1.9.1.476")
				{$id = 10005; $sysobject = "Cisco 7301-ADVIPSERVICESK9-M";}	
			
			if($sysobjectid eq ".1.3.6.1.4.1.2636.1.1.1.2.21")
				{$id = 10006; $sysobject = "Juniper Networks MX960";}	
				
			if($sysobjectid eq ".1.3.6.1.4.1.171.10.120.1")
				{$id = 10007; $sysobject = "D-Link DGS-6604";}	
				if($sysobjectid eq ".1.3.6.1.4.1.9.1.863")
				{$id = 10008; $sysobject = "Cisco c7600rsp72043_rp";}
				
			}
			else
			{
			$id = "-1";
			print "fault, reason: wrong SNMP community or forbitten SNMP protocol ";
			}

		if($id eq 0){print "unknow net device "; $sysobject = "unknow net device";}
		undef $snmptemp;

		# If all
		if($id >= 0 && $id <= 99999)
			{
		
			#get uptime
			$snmptemp = $snmpsession -> get_request(".1.3.6.1.2.1.1.3.0");
			if (ref($snmptemp))
				{
				$uptime = $snmptemp -> {".1.3.6.1.2.1.1.3.0"};
				}
			undef $snmptemp;
			
			#get MAC-adress
			$snmptemp = $snmpsession -> get_request(".1.3.6.1.2.1.17.1.1.0");
			$localmac = $snmptemp -> {".1.3.6.1.2.1.17.1.1.0"};
			if($localmac eq "noSuchInstance"){$id = -1;}
			my @arraylocalmac = $localmac =~ /[0-9A-Fa-f]{2}/g;
			 if(@arraylocalmac == 6)
			       {$localmac = join "", @arraylocalmac;
				$localmac =~ tr/A-F/a-f/;}
			 else  {$localmac = unpack('H12', $localmac)}
			
			#get sysLocation.0
			$snmptemp = $snmpsession -> get_request(".1.3.6.1.2.1.1.6.0");
			$syslocation = $snmptemp -> {".1.3.6.1.2.1.1.6.0"};
			
			#get sysName.0
			$snmptemp = $snmpsession -> get_request(".1.3.6.1.2.1.1.5.0");
			$sysname = $snmptemp -> {".1.3.6.1.2.1.1.5.0"};

			#get syscontact
			$snmptemp = $snmpsession -> get_request(".1.3.6.1.2.1.1.4.0");
			$syscontact = $snmptemp -> {".1.3.6.1.2.1.1.4.0"};

			#LLDP nei
			%snmplldpnei_hash = %{($snmpsession -> get_table(".1.0.8802.1.1.2.1.4.1.1.5"))};
			
@snmplldpnei_hash = `snmpwalk -v2c -c$snmpcommunity -Oxnq $iphost .1.0.8802.1.1.2.1.4.1.1.5`;

			

foreach   ( @snmplldpnei_hash)
{
chomp ;
/((\.\d+)+)\s+"(.*)"/;
$key=$1;
$value=$3;
$value=~s/\s+//g;
  $snmplldpnei_hash{ $key } = $value;
}



				

			my $snmpport;
#			print "\n1 ";
			#printf %snmplldpnei_hash;
			
#			print "\n";
#			print Dumper \%snmplldpnei_hash;
#			print Dumper \@snmplldpnei_hash;
#			print " 1\n ";

			foreach $lldpneioid (keys %snmplldpnei_hash)
				{
				$remotemac = $snmplldpnei_hash{$lldpneioid};
			
			
				my @arrayremotemac = $remotemac =~ /[0-9A-Fa-f]{2}/g;
				if(@arrayremotemac == 6)
					{$remotemac = join "", @arrayremotemac;$remotemac =~ tr/A-F/a-f/;}
				else	{$remotemac = unpack('H12', $remotemac)}

				$lldpneioid =~ m/(\d{1,})(?=\.(\d{1,})$)/;
			
#				print Dumper \@words ;
#				print "\n $sysname lldpneoif= $lldpneioid\n";
				
		
				if($id >=0 && $id <= 99999)
					{
					my $myport = $&;
					if ($id == 12 || $id == 17 || $id == 19 || $id == 27){$myport= $myport+4;}#для хуавеев
					if ($id == 112){$myport= $myport+5;}#для хуавеев
					$getport = ".1.3.6.1.2.1.31.1.1.1.1."."$myport";
					$snmptemp = $snmpsession -> get_request("$getport");
					$portname = $snmptemp -> {"$getport"};
					if($portname eq "noSuchInstance")
						{
						$portname = "$&";
						}
						
					$edges{$edgesid} = {
					'edgefrom'=>$localmac,
					'edgeto'=>$remotemac,
					'port'=>$portname,
					};
					$edgesid = $edgesid + 1;
					$lldpnei.= $portname."->".$remotemac.",";
					undef $remotemac;
					
					}
				}
			}

		if(defined($lldpnei))
					{
					chop $lldpnei;
					}

		if($id >=0 )
			{
			#print "$iphost;";
			#print "$uptime";
			#print "$localmac;";
			#print "$syslocation;";
			#print "$syscontact;";
			#print "$sysname;";
			#print "$id;";
			#print "$sysobject;";

			if(!defined($lldpnei)){$lldpnei = "";}

			#print "$lldpnei\n\n";

			$database{$iphost}={
			'uptime'=>$uptime,
			
			'localmac'=>$localmac,
			'syscontact'=>$syscontact,
			'syslocation'=>$syslocation,
			'sysname'=>$sysname,
			'id'=>$id,
			'sysobject'=>$sysobject,
			'lldpnei'=>$lldpnei,
			};
			}
			
		undef $uptime;		
		undef $localmac;
		undef $syscontact;
		undef $syslocation;
		undef $sysname;
		undef $id;
		undef $sysobject;
		undef $lldpnei;
		}
	%hosts = ();
#print "-------------------------\n"; 
	}


my $edgefrom;
my $edgefrom2;
my $edgeto;
my $edgeto2;
my $edge;
my $edge2;
my $port;
my $port2;

foreach $edge6(keys %edges)
	{
	$edgefrom6 = $edges{$edge6}{edgefrom};
	$edgeto6 = $edges{$edge6}{edgeto};
	$port6 = $edges{$edge6}{port};
	#print "$edge6 => $edgefrom6--$edgeto6;$port6\n";
	}

# Delete full edges dublicate
foreach $edge3(keys %edges)
	{
	$edgefrom3 = $edges{$edge3}{edgefrom};
	$edgeto3 = $edges{$edge3}{edgeto};
	$port3 = $edges{$edge3}{port};
	if(defined($edgefrom3) & defined($edgeto3) & defined($port3))
		{
		foreach $edge4(keys %edges)
			{
			$edgefrom4 = $edges{$edge4}{edgefrom};
			$edgeto4 = $edges{$edge4}{edgeto};
			$port4 = $edges{$edge4}{port};
			if(defined($edgefrom4) & defined($edgeto4) & defined($port4))
				{			
				if($edgefrom3 eq $edgefrom4 & $edgeto3 eq $edgeto4 & $port3 eq $port4 & $edge3 ne $edge4)
					{
					delete $edges{$edge4};
					}
				}
			}
		}
	}

# combine edges and ports and delete dublicate
foreach $edge(keys %edges)
	{
	my $port2;
	$edgefrom = $edges{$edge}{edgefrom};
	$edgeto = $edges{$edge}{edgeto};
	$port = $edges{$edge}{port};
	foreach $edge2(keys %edges)
		{
		$edgefrom2 = $edges{$edge2}{edgefrom};
		$edgeto2 = $edges{$edge2}{edgeto};
		if(defined($edgefrom))
			{
			if(defined($edgeto2))
				{
				if($edgefrom eq $edgeto2)
					{
					if($edgeto eq $edgefrom2)
						{
						$port2 = $edges{$edge2}{port};
						delete $edges{$edge2};
						}
					}
				}
			}
		}
	if (defined($edgefrom) & defined($edgeto))
		{
		if(defined($edge) & defined($edgefrom) & defined($edgeto) & defined($port) & defined($port2))
			{
			#print "$edge => $edgefrom--$edgeto;$port;$port2\n";
			}
		if(!defined($port2))
			{
			$port2 = "";
			}
		$lldpmap.= "\"$edgefrom\" -- \"$edgeto\" [taillabel=\"$port\", headlabel=\"$port2\", labeldistance=\"2\", len=\"4\" ]\;\n";
		}
	}

foreach $iphost(keys %database)
	{
	$uptime = $database{$iphost}{uptime};
	$localmac = $database{$iphost}{localmac};
	$syslocation = $database{$iphost}{syslocation};
	$sysname = $database{$iphost}{sysname};
	$sysobject = $database{$iphost}{sysobject};
	$id = $database{$iphost}{id};
	
	# Если какой придурок напихал кавычек в переменную
	$syslocation =~ s/"/\\"/g; 
	$sysname =~ s/"/\\"/g; 
	
	# Если какой нибудь мудак напихал \n в названия
	$syslocation =~ s/\\n/\\\\n/g; 
	$sysname =~ s/\\n/\\\\n/g; 

$localmac  =~ s/(\S\S)(\S\S)(\S\S)(\S\S)(\S\S)(\S\S)/$1-$2-$3-$4-$5-$6/;	

	my @portmac = ();
	if($id == 0){$label.="\"$database{$iphost}{localmac}\" [ label=\"$iphost\\n$sysobject\\n$sysname\\n$uptime\", shape=\"octagon\", fillcolor=\"red\" ]\;\n";}
	if($id > 0){$label.="\"$database{$iphost}{localmac}\" [ label=\"$iphost\\n$sysname\\n$sysobject\\n$localmac\\n$uptime\", shape=\"octagon\", fillcolor=\"green\" ]\;\n";}
	if($id > 100){$label.="\"$database{$iphost}{localmac}\" [ label=\"$iphost\\n$sysname\\n$sysobject\\n$localmac\\n$uptime\", shape=\"octagon\", fillcolor=\"yellow\" ]\;\n";}
	}

open(lldp2dot,">mapdot.gv");
print lldp2dot "graph lldp2dot {\n\toverlap=scale;\n\tsplines=true;\n";
print lldp2dot "node [ shape=\"box\", fixedsize=\"false\", style=\"filled\", fillcolor=\"white\" ];\n";
print lldp2dot "graph [ fontname=\"Helvetica-Oblique\", fontsize=\"150\", label=\"Network graph\", size=\"6,6\" ];\n";
print lldp2dot "edge [color=red];\n";
print lldp2dot $label;
print lldp2dot $lldpmap;
print lldp2dot "}";
close(lldp2dot);

sub pingDec {
	my $iphost=iptools::dectoIP(shift);
	my $pingtimeout = (shift);
	print "ping $iphost... timeout $pingtimeout";
	if($ping->ping($iphost,$pingtimeout))
		{
		$hosts{$iphost}=undef;
		print " success, save result, go to next host...\n";
		}
		else
		{
		print " fault, save result, go to next host...\n";
		}
	return 0;
}


# pdf

 #print "dot ==> generation PDF...\n";
# `dot -Tpdf -Gratio=auto -Ecolor=black -Ncolor=black -Goverlap=false -Gsize=10 mapdot.gv -o mapdot.pdf`;

#print "neato ==> generation PDF...\n";
 `neato -Tpdf -Gratio=auto -Ecolor=black -Ncolor=black -Goverlap=false -Gsize=10 mapdot.gv -o ./mapneato.pdf`;

# print "fdp ==> generation PDF...\n";
# `fdp -Tpdf -Gratio=auto -Ecolor=black -Ncolor=black -Goverlap=false -Gsize=10 mapdot.gv -o mapfdp.pdf`;

# svg

# print "dot ==> generation SVG...\n";
# `dot -Tsvg -Gratio=auto -Ecolor=black -Ncolor=black -Goverlap=false -Gsize=10 mapdot.gv -o mapdot.svg`;

# print "neato ==> generation SVG...\n";
 `neato -Tsvg -Gratio=auto -Ecolor=black -Ncolor=black -Goverlap=false -Gsize=50 mapdot.gv -o ./mapneato.svg`;

# print "fdp ==> generation SVG...\n";
# `fdp -Tsvg -Gratio=auto -Ecolor=black -Ncolor=black -Goverlap=false -Gsize=50 mapdot.gv -o mapfdp.svg`;

print qq~
<embed src="mapneato.pdf" width="1600" height="1000"  type="application/pdf">
~;
