#!/usr/bin/perl
use File::stat;
use Time::localtime;
my $event = 'event_on_mu.txt';
use Net::Ping;
use strict;
use Fcntl;
use CGI;
use 5.010;
use Net::SNMP qw(:snmp);
my $my_cgi;
my $line;
use Socket; 

my $snmptimeout = '1';
my %snmplldpnei_hash = ();
my $snmp_oid ='.1.3.6.1.2.1.1.2.0';
my $getFireware;
my $getSn;
my $firmware;
my $serial;
my $device;
my $mac;
my $id=0;
my $oidIp ='IP-MIB::ipAdEntAddr';
my $IPaddres;
my $cpu;
my $temOid= '.1.3.6.1.4.1.171.12.11.1.8.1.2.1';
my @ipOID;
my $tem;
my $powerA;
my $powerB;
my $term;
my $soft;
my $snmp_com ="icomm";
my $test;
my $out;
my $volt;
my $my_cgi;
my $sn;
my $hwVersion;
my $swVersion;
my $temper;
my $mac;
my $hexmac;
my $ip;
my $chekSW = 0;
my $dns;
my $chekping;
my $ActivChanel;
my $Serial;
my $uptime;
my $color;
my $logs = 'shpd_logs.txt';
my $pingtimeout = '0.200';

print "Content-type: text/html\n\n";
 $my_cgi = new CGI;
 $line = $my_cgi->param('name2');
 $line =~ s/\s+//;
 #my $modul = $1;
 #my $host = $2;
 
 print qq~
<head>
 <link rel="stylesheet" href="http://10.40.254.109/op/bootstrap/css/bootstrap.min.css" >
<link href="access.css" rel="stylesheet">
<script type="text/javascript" src="jquery.js"></script>  
</head>

 <script type="text/javascript">
   function isSW(obj) {
    var str = obj.text;
   document.getElementById('my_input').value = str;
	document.getElementById('my_form').submit();
	
   }

  </script>
  
<body style = "background-color: #ECF6CE;">
~;
#Попингуем
my $p = Net::Ping->new("tcp", 2);
$p->{'port_num'} = 23;
	unless ($p->ping($line,$pingtimeout)){
	my ($problem, $connect) = FundRing($line);
	print " <div id=\"back2\"><h3><br><br><br><br><b><font color = 'red'>$line</font> не отвечает.</b></h3><br>";
	my $ip_op = inet_ntoa((gethostbyname("$line"))[4]);;
	if ($connect eq '') {($connect, $ip_op) = op_Connect($line);}#для приемников
	print "<h3>IP: <b>$ip_op</b></h3><br>" if ($ip_op ne '');
	print "<p>Скроссирован на <a href=\"javascript:{}\" id=\"my_a\" onclick=\"isSW(this)\">$connect</a></p>" if ($connect ne '');
	
	print "<p>$problem</p></div>";
	$id = 666;
	goto END;		
}
$p->close();
		
		
		
		
		
   my ($session, $error) = Net::SNMP->session
        (
            -retries => "1",
            -hostname => $line,
            -version => "1",
            -community => "icomm",
            -port => 161,
            -timeout => "1",
            -translate => [-octetstring => 0x0]
        );
		if  ( !($session->get_request("$snmp_oid"))) {
                ($session, $error) = Net::SNMP -> session
				(  
			-timeout => $snmptimeout,
              -retries => "1",
            -hostname => $line,
            -version => "1",
            -community => "public",
            -port => 161,
            -timeout => "1",
            -translate => [-octetstring => 0x0]
 );

}
my	$result = $session->get_request("$snmp_oid");
unless (defined $result) {
print " <div id=\"back2\"><h3><br><br><br><br><font color = 'red'>$line</font> не отвечает по snmp.</h3></div>";
$id = 666;
goto END;
}

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
	$id = 4;
	}

    #DGS-1210-10P/ME/A1 
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.76.35.1" )
	{
	$getFireware = '.1.3.6.1.4.1.171.10.76.35.1.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.76.35.1.1.30.0';
	$id = 5;
	}
	    #DGS-1210-10/ME/B1
elsif ( $result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.76.35.2")
	{
	$getFireware = '.1.3.6.1.4.1.171.10.76.35.2.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.76.35.2.1.30.0';
	$id = 5;
	}

    #DGS-1210-10P/ME/A1 
elsif ( $result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.76.32.1")
	{
	$getFireware = '.1.3.6.1.4.1.171.10.76.32.1.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.76.32.1.1.30.0';
	$id = 6;
	}

#DGS-3700-12G
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.102.1.2")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.11.1.9.4.1.11.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 7;
	}

#DGS-1210-28/ME/A1
	elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.76.28.1")
	{
	$getFireware = '.1.3.6.1.4.1.171.10.76.28.1.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.76.28.1.1.30.0';
	$id = 8;
	}

#DGS-3420-26SC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.119.6")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.11.1.9.4.1.11.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 9;
	
	}

#DGS-3627G
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.70.8")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.11.1.9.4.1.11.1';
	$getSn = '.1.3.6.1.4.1.171.12.1.1.12.0';
	$id = 10;
	}

#DGS-3420-28SC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.119.2")
	{
	$getFireware = '.1.3.6.1.4.1.171.12.11.1.9.4.1.11.1';
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
	$id = 14;
	}

#DES-1210-28/ME-B3   
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.75.15.3")
	{
	$getFireware = '.1.3.6.1.4.1.171.10.75.15.3.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.75.15.3.1.30.0';
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
	$getSn = '.1.3.6.1.4.1.259.6.10.94.1.1.3.1.10.1';
	$getFireware = '.1.3.6.1.4.1.259.6.10.94.1.1.3.1.6.1';
	$id = 19;
	}

#EDGE-Core ECS3510-28T  
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.259.10.1.27.101")
	{
	$getFireware = '.1.3.6.1.4.1.259.10.1.27.1.1.3.1.6.1';
	$getSn = '.1.3.6.1.4.1.259.10.1.27.1.1.3.1.10.1';
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
	$temOid= '.1.3.6.1.4.1.2011.5.25.31.1.1.1.1.11.67108873';
	$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.67108873';
	$id = 24;
	}

  #Huawei S5300-28X-LI-24S-AC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.221")
	{
	$temOid= '.1.3.6.1.4.1.2011.5.25.31.1.1.1.1.11.67108873';
	$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.67108873';
	$id = 25;
	}

	  # Catalyst 4500 L3
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.917" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.788")
	{
	$getFireware = '.1.3.6.1.4.1.9.2.1.73.0';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.1';
	$temOid= '.1.3.6.1.4.1.9.9.13.1.3.1.3.1';
	$id = 26;
	}
	
		  # Catalyst C2960
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.716" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.694" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.799" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.696")
	{
	$getFireware = '.1.3.6.1.4.1.9.2.1.73.0';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.1001';
	$temOid= '.1.3.6.1.4.1.9.9.13.1.3.1.3.1005';
	$id = 27;
	}

	#FiberHome S4820-28T-X
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.3807.1.482816" )
{
$id = 28;
# $getFireware = '.1.3.6.1.4.1.9.2.1.73.0';
# 	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.1001';
# 	$temOid= '.1.3.6.1.4.1.9.9.13.1.3.1.3.1005';
}

#FiberHome S4820-52T-X
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.3807.1.485201")
{
$id = 29;
# $getFireware = '.1.3.6.1.4.1.9.2.1.73.0';
# 	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.1';
# 	$temOid= '.1.3.6.1.4.1.9.9.13.1.3.1.3.1005';
}

#Cisco ME340x
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.780")
{
$id = 30;
$getFireware = '.1.3.6.1.4.1.9.2.1.73.0';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.1001';
	$temOid= '.1.3.6.1.4.1.9.9.13.1.3.1.3.1005';
}

#Cisco ME360x
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.1250")
{
$id = 33;
$getFireware = '.1.3.6.1.4.1.9.2.1.73.0';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.1001';
	$temOid= '.1.3.6.1.4.1.9.9.13.1.3.1.3.1005';
}

#Cisco c7600
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.863")
{
$id = 34;
$getFireware = '.1.3.6.1.4.1.9.2.1.73.0';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.1';
	$temOid= '.1.3.6.1.4.1.9.9.13.1.3.1.3.92';
}

#Quidway S5624P 
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.10.1.43")
{
$id = 31;
$temOid= '.1.3.6.1.4.1.2011.5.25.31.1.1.1.1.11.67108873';
$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.67108873';
}

#Quidway S9303
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.170.1")
{
$id = 32;
$temOid= '.1.3.6.1.4.1.2011.5.25.31.1.1.1.1.11.67108873';
$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.67108867';
}

#Lambda PRO 72
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.11195.1")
{
$id = 35;
#Получаем уровни сигнала
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.11195.1.5.5.1.4.1');
 $powerA = $snmptemp -> {'.1.3.6.1.4.1.11195.1.5.5.1.4.1'};

$snmptemp = $session -> get_request('.1.3.6.1.4.1.11195.1.5.5.1.4.2');
 $powerB = $snmptemp -> {'.1.3.6.1.4.1.11195.1.5.5.1.4.2'};

    #Активный канал
 $snmptemp = $session -> get_request('1.3.6.1.4.1.5591.1.5.13.1.4.0');
 $ActivChanel = $snmptemp -> {'1.3.6.1.4.1.5591.1.5.13.1.4.0'};
 if ($ActivChanel == 1){$ActivChanel = 'A';}
  elsif ($ActivChanel == 2){$ActivChanel = 'B';}
 #Тест
 #$snmptemp = $session -> get_request('.1.3.6.1.4.1.11195.1.1.17.0');
 #$test = $snmptemp -> {'.1.3.6.1.4.1.11195.1.1.17.0'};
 
   #Выходной сигнал
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.11195.1.5.16.1.2.2');
 $out = $snmptemp -> {'.1.3.6.1.4.1.11195.1.5.16.1.2.2'};
#Получаем температуру
 $snmptemp = $session -> get_request('1.3.6.1.4.1.5591.1.3.1.13.0');
 $term = $snmptemp -> {'1.3.6.1.4.1.5591.1.3.1.13.0'};
 #Напряжение
 $snmptemp = $session -> get_request('1.3.6.1.4.1.5591.1.5.19.1.2.2');
 $volt = $snmptemp -> {'1.3.6.1.4.1.5591.1.5.19.1.2.2'};

#Получаем версию ПО
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.11195.1.5.2.0');
 $soft = $snmptemp -> {'.1.3.6.1.4.1.11195.1.5.2.0'};
 
    #Получаем IP
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.5591.1.3.1.9.0');
 $ip = $snmptemp -> {'.1.3.6.1.4.1.5591.1.3.1.9.0'};
 
 #Получаем MAC
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.5591.1.3.2.7.0');
 $hexmac = $snmptemp -> {'.1.3.6.1.4.1.5591.1.3.2.7.0'};
$mac = unpack('H16', $hexmac);
$mac =~ m/^(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)$/;
$mac = join '-',($1, $2, $3,$4,$5,$6);


$device = "Lambda PRO 72";

}

#sdo3002
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.32108.1.7" )
{
$id = 36;
#Получаем уровни сигнала
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.7.2.2.0');
 $powerA = $snmptemp -> {'.1.3.6.1.4.1.32108.1.7.2.2.0'};
$snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.7.2.3.0');
 $powerB = $snmptemp -> {'.1.3.6.1.4.1.32108.1.7.2.3.0'};
  #Выходной сигнал
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.7.2.4.0');
 $out = $snmptemp -> {'.1.3.6.1.4.1.32108.1.7.2.4.0'};
   #Активный канал
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.7.2.1.0');
 $ActivChanel = $snmptemp -> {'.1.3.6.1.4.1.32108.1.7.2.1.0'};
 if ($ActivChanel == 1){$ActivChanel = 'A';}
  elsif ($ActivChanel == 2){$ActivChanel = 'B';}
#Получаем температуру
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.7.2.5.0');
 $term = $snmptemp -> {'.1.3.6.1.4.1.32108.1.7.2.5.0'};
 #Напряжение
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.7.2.6.0');
 $volt = $snmptemp -> {'.1.3.6.1.4.1.32108.1.7.2.6.0'};
 #Получаем версию ПО
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.7.1.3.0');
 $soft = $snmptemp -> {'.1.3.6.1.4.1.32108.1.7.1.3.0'};
 
  #Получаем IP
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.7.4.1.3.0');
 $ip = $snmptemp -> {'.1.3.6.1.4.1.32108.1.7.4.1.3.0'};
 
  #Получаем MAC
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.7.1.4.0');
 $mac = $snmptemp -> {'.1.3.6.1.4.1.32108.1.7.1.4.0'};
$mac =~ s/\:+//g;
$mac =~ m/^(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)$/;
$mac = join '-',($1, $2, $3,$4,$5,$6);


$device = "sdo3002";

}

#sdo3001
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.32108.1.8" )
{
$id = 37;
#Получаем уровни сигнала
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.8.2.2.0');
 $powerA = $snmptemp -> {'.1.3.6.1.4.1.32108.1.8.2.2.0'};
$snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.8.2.3.0');
 $powerB = $snmptemp -> {'.1.3.6.1.4.1.32108.1.8.2.3.0'};
    #Активный канал
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.8.2.1.0');
 $ActivChanel = $snmptemp -> {'.1.3.6.1.4.1.32108.1.8.2.1.0'};
 if ($ActivChanel == 1){$ActivChanel = 'A';}
  elsif ($ActivChanel == 2){$ActivChanel = 'B';}
  #Выходной сигнал
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.8.2.4.0');
 $out = $snmptemp -> {'.1.3.6.1.4.1.32108.1.8.2.4.0'};
#Получаем температуру
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.8.2.5.0');
 $term = $snmptemp -> {'.1.3.6.1.4.1.32108.1.8.2.5.0'};
 #Напряжение
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.8.2.6.0');
 $volt = $snmptemp -> {'.1.3.6.1.4.1.32108.1.8.2.6.0'};
 #Получаем версию ПО
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.8.1.3.0');
 $soft = $snmptemp -> {'.1.3.6.1.4.1.32108.1.8.1.3.0'};
   #Получаем IP
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.8.4.1.3.0');
 $ip = $snmptemp -> {'.1.3.6.1.4.1.32108.1.8.4.1.3.0'};
   #Получаем MAC
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.8.1.4.0');
 $mac = $snmptemp -> {'.1.3.6.1.4.1.32108.1.8.1.4.0'};
$mac =~ s/\:+//g;
$mac =~ m/^(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)$/;
$mac = join '-',($1, $2, $3,$4,$5,$6);

$device = "sdo3001";

}

#OR862-I
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.17409.1")
{
$id = 38;
#Получаем уровни сигнала
my $snmptemp = $session -> get_request('1.3.6.1.4.1.17409.1.9.3.1.2.1');
 $powerA = $snmptemp -> {'1.3.6.1.4.1.17409.1.9.3.1.2.1'};
$snmptemp = $session -> get_request('1.3.6.1.4.1.17409.1.9.3.1.2.2');
 $powerB = $snmptemp -> {'1.3.6.1.4.1.17409.1.9.3.1.2.2'};
     #Активный канал
 $snmptemp = $session -> get_request('1.3.6.1.4.1.17409.1.9.26.0');
 $ActivChanel = $snmptemp -> {'1.3.6.1.4.1.17409.1.9.26.0'};
 if ($ActivChanel == 1){$ActivChanel = 'A';}
  elsif ($ActivChanel == 2){$ActivChanel = 'B';}
  elsif ($ActivChanel == 3){$ActivChanel = 'Manual A';}
  elsif ($ActivChanel == 4){$ActivChanel = 'Manual B';}
    #Выходной сигнал
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.9.5.1.4.1');
 $out = $snmptemp -> {'.1.3.6.1.4.1.17409.1.9.5.1.4.1'};
 if ( length $out == 4)
 {
 $out =~ s/(...)/$1./;
 }
 else
 {
 $out =~ s/(..)/$1./;
 }
     #Напряжение
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.9.8.1.2.1');
 $volt = $snmptemp -> {'.1.3.6.1.4.1.17409.1.9.8.1.2.1'};
 
#Получаем температуру
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.3.3.2.2.1.12.1');
 $term = $snmptemp -> {'.1.3.6.1.4.1.17409.1.3.3.2.2.1.12.1'};
 #Получаем версию ПО
 $snmptemp = $session -> get_request('.1.3.6.1.2.1.1.1.0');
 $soft = $snmptemp -> {'.1.3.6.1.2.1.1.1.0'};
  $soft =~ s/^(.+)\s.+/$1/; #удаляем все после первого пробела
    #Получаем IP
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.9.100.1.3.1');
 $ip = $snmptemp -> {'.1.3.6.1.4.1.17409.1.9.100.1.3.1'};
 

$device = "OR862-S2";
}

#OR862-I новый
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.17409.1.10.1.0" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.17409.1.10")
{
$id = 39;
#Получаем уровни сигнала
my $snmptemp = $session -> get_request('1.3.6.1.4.1.17409.1.10.5.1.2.1');
 $powerA = $snmptemp -> {'1.3.6.1.4.1.17409.1.10.5.1.2.1'};
$snmptemp = $session -> get_request('1.3.6.1.4.1.17409.1.10.5.1.2.2');
 $powerB = $snmptemp -> {'1.3.6.1.4.1.17409.1.10.5.1.2.2'};
      #Активный канал
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.10.13.1.2.1');
 $ActivChanel = $snmptemp -> {'.1.3.6.1.4.1.17409.1.10.13.1.2.1'};
 
 if ($ActivChanel == 1){$ActivChanel = 'A';}
  elsif ($ActivChanel == 2){$ActivChanel = 'B';}
    #Выходной сигнал
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.10.11.1.4.1');
 $out = $snmptemp -> {'.1.3.6.1.4.1.17409.1.10.11.1.4.1'};
 if ( length $out == 4)
 {
 $out =~ s/(...)/$1./;
 }
 #else
 #{
 #$out =~ s/(..)/$1./;
 #}
   #Серийный номер
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.3.3.2.2.1.5.1');
 $Serial = $snmptemp -> {'.1.3.6.1.4.1.17409.1.3.3.2.2.1.5.1'};
     #Напряжение
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.10.19.1.2.2');
 $volt = $snmptemp -> {'.1.3.6.1.4.1.17409.1.10.19.1.2.2'};
 
#Получаем температуру
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.3.3.2.2.1.12.1');
 $term = $snmptemp -> {'.1.3.6.1.4.1.17409.1.3.3.2.2.1.12.1'};
 #Получаем версию ПО
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.3.3.2.2.1.19.1');
 $soft = $snmptemp -> {'.1.3.6.1.4.1.17409.1.3.3.2.2.1.19.1'};
 if ($result->{$snmp_oid} eq ".1.3.6.1.4.1.17409.1.10")
{
 $snmptemp = $session -> get_request('.1.3.6.1.2.1.1.1.0');
 $soft = $snmptemp -> {'.1.3.6.1.2.1.1.1.0'};
}
 $soft =~ s/^(.+)\s.+/$1/; #удаляем все после первого пробела
    #Получаем IP
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.3.1.9.0');
 $ip = $snmptemp -> {'.1.3.6.1.4.1.17409.1.3.1.9.0'};
   #Получаем MAC
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.3.2.1.1.1.0');
 $mac = $snmptemp -> {'.1.3.6.1.4.1.17409.1.3.2.1.1.1.0'};
$mac = unpack('H12', $mac);
$mac =~ s/\:+//g;
$mac =~ m/^(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)$/;
$mac = join '-',($1, $2, $3,$4,$5,$6);
$device = "OR862-I";

}

#tuz19-2003
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.32108.1.9")
{
$id = 40;
#Получаем уровни сигнала
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.9.2.2.0');
 $powerA = $snmptemp -> {'.1.3.6.1.4.1.32108.1.9.2.2.0'};
$snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.9.2.3.0');
 $powerB = $snmptemp -> {'.1.3.6.1.4.1.32108.1.9.2.3.0'};
  #Активный канал
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.9.2.1.0');
 $ActivChanel = $snmptemp -> {'.1.3.6.1.4.1.32108.1.9.2.1.0'};
 if ($ActivChanel == 1){$ActivChanel = 'A';}
  elsif ($ActivChanel == 2){$ActivChanel = 'B';}
   #Выходной сигнал
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.9.2.4.0');
 $out = $snmptemp -> {'.1.3.6.1.4.1.32108.1.9.2.4.0'};
#Получаем температуру
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.9.2.5.0');
 $term = $snmptemp -> {'.1.3.6.1.4.1.32108.1.9.2.5.0'};
 #Напряжение
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.9.2.6.0');
 $volt = $snmptemp -> {'.1.3.6.1.4.1.32108.1.9.2.6.0'};
#Получаем версию ПО
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.9.1.3.0');
 $soft = $snmptemp -> {'.1.3.6.1.4.1.32108.1.9.1.3.0'};
   #Получаем IP
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.9.4.1.3.0');
 $ip = $snmptemp -> {'.1.3.6.1.4.1.32108.1.9.4.1.3.0'};
   #Получаем MAC
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.9.1.4.0');
 $mac = $snmptemp -> {'.1.3.6.1.4.1.32108.1.9.1.4.0'};


$device = "tuz19-2003";
}





	else {
		print " <div id=\"back\"><font color = 'red'>$line</font> -неизвестное устройство.</div>";

exit;
		}		
#---------------------------------------------------------------------------------------------------------------------------------------------------------

if ($id < 35) { #коммутаторы		
#get Upтime
my $snmptemp = $session -> get_request(".1.3.6.1.2.1.1.3.0");
$uptime = $snmptemp -> {".1.3.6.1.2.1.1.3.0"};

#Прошивка
$snmptemp = $session -> get_request("$getFireware");
$firmware = $snmptemp -> {"$getFireware"};
if ($id==27 || $id==28 || $id==29 || $id==30 || $id==26 || $id==33){$firmware=~ s/.+\/(.+)/$1/}

#Серийник
$snmptemp = $session -> get_request("$getSn");
$serial = $snmptemp -> {"$getSn"};

#Устройство
$snmptemp = $session -> get_request(".1.3.6.1.2.1.1.1.0");
$device = $snmptemp -> {".1.3.6.1.2.1.1.1.0"};
if ($id == 24 || $id == 25 || $id == 31 || $id == 32  ){
	$device =~ /^(.+)\s/;
	$device = $1;
	}
	if ($id == 26 ){
	
	$device = "Catalyst 4500 L3 Switch";
	}
	if ($id == 27 ){
	
	$device = "Catalyst C2960";
	}
	if ($id == 29 ){$device = "FiberHome S4820-52T-X";}
	if ($id == 28 ){$device = "FiberHome S4820-28T-X";}
	if ($id == 30 ){$device = "Cisco ME340x";}
	if ($id == 33 ){$device = "Cisco ME360x";}
	if ($id == 34 ){$device = "Cisco c7600";}
	if ($id == 22 || $id == 23 ){
	$device = "H3C";
	}
	$device =~ s/FE L2 Switch//;
	$device =~ s/Fast Ethernet Switch//;
	
	#get CPU
 if ($id == 14 || $id == 4 || $id == 5 || $id == 6 || $id == 8){
$snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.2.100.1.1.0");
 $cpu = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.2.100.1.1.0"};
 }
  elsif ($id == 26 || $id == 27 || $id == 28 || $id == 29 || $id == 30 || $id==33 || $id==34){
$snmptemp = $session -> get_request(".1.3.6.1.4.1.9.9.109.1.1.1.1.5.1");
 $cpu = $snmptemp -> {".1.3.6.1.4.1.9.9.109.1.1.1.1.5.1"};
 }
 elsif ($id == 15 ){
$snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.3.100.1.1.0");
 $cpu = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.3.100.1.1.0"};
 }
 elsif ( $id == 20){
 eval{
  %snmplldpnei_hash = %{$session -> get_table(".1.3.6.1.4.1.259.10.1.27.1.39.2.1")};
	foreach my $ipaddoid (keys %snmplldpnei_hash)
	{
		$cpu = $snmplldpnei_hash{$ipaddoid};
	}
	};
 }
  elsif ( $id == 19){
 eval{
  %snmplldpnei_hash = %{$session -> get_table(".1.3.6.1.4.1.259.6.10.94.1.39.2.1")};
	foreach my $ipaddoid (keys %snmplldpnei_hash)
	{
		$cpu = $snmplldpnei_hash{$ipaddoid};
	}
	};
 }
  elsif ($id == 24 || $id == 25 || $id == 31 || $id == 32){
eval{
  %snmplldpnei_hash = %{$session -> get_table(".1.3.6.1.4.1.2011.6.3.4.1.2")};
	foreach my $ipaddoid (keys %snmplldpnei_hash)
	{
		$cpu = $snmplldpnei_hash{$ipaddoid};
	}
	};
 }
 else{
$snmptemp = $session -> get_request("1.3.6.1.4.1.171.12.1.1.6.1.0");
 $cpu = $snmptemp -> {"1.3.6.1.4.1.171.12.1.1.6.1.0"};
 }
 
  #get IP
 eval{
 if ($id == 24 || $id == 25 || $id == 27 || $id == 32 || $id == 28 || $id == 29){
  %snmplldpnei_hash = %{$session -> get_table(".1.3.6.1.2.1.4.20.1.1")};
	foreach my $ipaddoid (keys %snmplldpnei_hash)
	{
		$IPaddres = $snmplldpnei_hash{$ipaddoid};
		push @ipOID, "$IPaddres";
		$IPaddres = $ipOID[0];
	}
 }
 elsif ($id == 26){
 $snmptemp = $session -> get_request(".1.3.6.1.4.1.9.2.1.5.0");
 $IPaddres = $snmptemp -> {".1.3.6.1.4.1.9.2.1.5.0"};
 }
 else {
 %snmplldpnei_hash = %{$session -> get_table(".1.3.6.1.2.1.4.20.1.1")};
	foreach my $ipaddoid (keys %snmplldpnei_hash)
	{
		$IPaddres = $snmplldpnei_hash{$ipaddoid};
	}
	}
	};		 
	
#get Mac
$snmptemp = $session -> get_request(".1.3.6.1.2.1.17.1.1.0");
$mac = $snmptemp -> {".1.3.6.1.2.1.17.1.1.0"};
my @arraylocalmac = $mac =~ /[0-9A-Fa-f]{2}/g; if(@arraylocalmac == 6){$mac = join "", @arraylocalmac;$mac =~ tr/A-F/a-f/;}else{$mac = unpack('H12', $mac)}
$mac =~ m/^(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)$/;
$mac = join '-',($1, $2, $3,$4,$5,$6);
	
#Температура для длинков 32*
	if ($id == 1 || $id == 2 || $id ==3 || $id ==7 || $id == 9 || $id == 11|| $id == 24|| $id == 25|| $id == 26  || $id == 27  || $id == 28  || $id == 29  || $id == 30 || $id == 31|| $id == 32 || $id == 33 || $id == 34){
	$snmptemp = $session -> get_request("$temOid");
	$tem = $snmptemp -> {"$temOid"};
	}	
}	
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if ($id >34 ) {
#Варианты значений
if ( length $powerA == 1)
{
if ( $powerA eq "0")
{
$powerA = "0";
}
else
{
$powerA = "0.$powerA";
}
}
elsif ( length $powerA == 3)
{
$powerA =~ s/(..)/$1./;
}
elsif ( length $powerA == 2)
{
if ( $powerA =~ /[-]/)
{
$powerA =~ s/.(.)/-0.$1/;
}
else
{
$powerA =~ s/(.)/$1./;
}
}
elsif ( length $powerA == 4)
{
if ( $powerA eq "-200")
{
$powerA = "low";
}
elsif ( $powerA =~ /[-]/)
{
$powerA =~ s/.(..)/-$1./;
}
else{
$powerA =~ s/(...)/$1./;
}
}
if ( length $powerB == 1)
{
if ( $powerB eq "0")
{
$powerB = "0";
}
else
{
$powerB = "0.$powerB";
}
}
elsif ( length $powerB == 2)
{
if ( $powerB =~ /[-]/)
{
$powerB =~ s/.(.)/-0.$1/;
}
else
{
$powerB =~ s/(.)/$1./;
}
}
elsif ( length $powerB == 3)
{
$powerB =~ s/(..)/$1./;
}
elsif ( length $powerB == 4)
{
if ( $powerB eq "-200")
{
$powerB = "low";
}
elsif ( $powerB =~ /[-]/)
{
$powerB =~ s/.(..)/-$1./;
}
else{
$powerB =~ s/(...)/$1./;
}
}
if ( length $volt == 2)
{
$volt =~ s/(.)/$1./;
}
else 
{
$volt =~ s/(..)/$1./;
}
#Критические уровни
 $color = 'black';
  if ( $powerA > 2.5) {$color = 'blue';}
  if ( $powerA < -9) {$color = 'blue';}
  if ( $powerA eq 'low') {$color = 'blue';}
  $powerA = "<font color = '$color'>$powerA</font>";
  
 $color = 'black';
  if ( $powerB > 2.5) {$color = 'blue';}
  if ( $powerB < -9) {$color = 'blue';}
  if ( $powerB eq 'low') {$color = 'blue';}
  $powerB = "<font color = '$color'>$powerB</font>";

  $color = 'black';
  if ( $volt > 26) {$color = 'blue';}
  $volt = "<font color = '$color'>$volt</font>";
  
   $color = 'black';
  if ( $out < 96) {$color = 'blue';}
  $out = "<font color = '$color'>$out</font>";
  
  }
#----------------------------------------------------------------------------------------------------------------------------------------------	
	
$session->close();  
if ($id <35 && $id != 666){
my ($problem, $connect) = FundRing($line);
print "<div id=\"back2\">";
print "<center><font color='brown'><h2>$line</h2> </font>";
print "
<form method='post' action='http://10.40.254.109/op/sw/monitor/cabel_ajax.pl' target=\"_blank\" id=\"len\">
   <input type='image' src =\"Ruler.png\" name='name' value=\"$line\" id=\"inputtext\"> 
  </form></center>";
  
print "<h3><i>Модель:</i> <b>$device</b><br>

<i>S/N: </i><b>$serial</b><br>
<i>MAC: </i> <b>$mac</b><br>
<i>IP: </i><b>$IPaddres</b><br>
<i>Загрузка процессора: </i><b>$cpu%</b><br>";
 if ($tem != undef) 
{
print "<i>Температура:</i> <b>$tem C</b><br>";
}
print "<i>Uptime: </i><b>$uptime</b><br></h3><br>";
 if ($connect ne '') 
{
print "<p><i>Скроссирован на:</i> <b><a href=\"javascript:{}\" id=\"my_a\" onclick=\"isSW(this)\">$connect</a></b></p>";
}
print "<div class = \"form-row\">";
  print "<div class = \"col-5\">
<form method='post' action='http://10.40.254.109/op/sw/mapnet.pl' target=\"_blank\" id=\"knopka\" style=\"float: right;\">
    <button type=\"submit\" class=\"btn btn-info mb-2\"  name='name' value=\"$line\" >Карта</button>
  </form>";
  print "</div>";
    print "<div class = \"col-5\">";
print "
<form method='post' action='http://10.40.254.109/op/sw/sw_web.pl' target=\"_blank\" id=\"knopka\" style=\"float: right;\">
   <button type=\"submit\" class=\"btn btn-warning mb-2\"  name='name' value=\"$line\" >Подробнее</button>
  </form>";
  
print "</div>";
 print "</div>"; 
print "</div>";
}

if ($id > 34 && $id != 666){
my ($connect, $ip_op) = op_Connect($line);
print "<div id=\"back2\">";
print "<center><font color='brown'><h2>$line</h2> </font></center><br>";
print "<h3><i>Модель:</i> <b>$device</b><br>
<i>Вход А</i>: <b>$powerA dBm </b><BR>
<i>Вход B</i>: <b>$powerB dBm</b> <BR>
<i>Выход</i>:<b>$out dBuV</b> <BR>
<i>Активный вход</i>: <b>$ActivChanel</b> <BR>
<i>Температура</i>: <b>$term °C</b> <BR>";
if ($result->{$snmp_oid} ne ".1.3.6.1.4.1.35702.3.5"){
print "<i>Напряжение</i>: <b>$volt V</b> <BR>";
}
if ($result->{$snmp_oid} ne ".1.3.6.1.4.1.17409.1" &&  $result->{$snmp_oid} ne ".1.3.6.1.4.1.35702.3.5"){
print "<i>MAC</i>: <b>$mac</b> <BR>";
}
print "<i>IP</i>: <b>$ip</b> <BR></h3>";

 if ($connect ne '') 
{
print "<br><p><i>Скроссирован на:</i> <b><a href=\"javascript:{}\" id=\"my_a\" onclick=\"isSW(this)\">$connect</a></b></p>";
}

print "

<form method='post' action='http://10.40.254.109/op/op_web.pl' target=\"_blank\"  >
   <button type=\"submit\" class=\"btn btn-warning mb-2\" id=\"knopka_op\" name='name' value=\"$line\" >Подробнее</button>
  </form>";
print "</div>";

}
END:

print "<form action=\"modul_sw.pl\" method=\"post\"  target=\"area\" id=\"my_form\">";
print "<input type=\"hidden\" name=\"name2\" value=\"one\" id=\"my_input\">";

print "<center><div id=\"log\">";
print "<center><font color='brown'><div class=\"title_log\"><h2>Журнал аварий:</h2></div> </font></center><br><div class=\"text\">";

my @df_output = qx (cat /var/www/html/op/sw/monitor/shpd_logs.txt |grep -E  -i '($line)');
my @reversed = reverse(@df_output); 
foreach my $text(@reversed) 
{
$text =~ s/(.+)\sУстройство\s\S+\sнедоступно/$1 не отвечает/;
$text =~ s/(.+)\sУстройство\s\S+\sдоступно/$1 сервис восстановлен/;
if ($text =~ /Уровни сигналов/){$text =~ s/^\S+\s//;}

print "<h3>$text<br></h3>";
}

print "</div>";
print qq~
<div class="d-flex justify-content-center">
<div class="spinner-grow text-info  d-none" role="status">
  <span class="sr-only">Loading...</span>
</div>
</div>
</div></center>

~;
print qq~



 
	
<script>  	
	\$('#len').submit(function() { 					// событие при активации формы
	var dataString = \$("#inputtext").val();		// значение в переменную
    \$.ajax({ 										// create an AJAX call...
		
        data: "name=" + dataString,					//передаем name=значению
        type: \$(this).attr('method'), 				// GET or POST
        url: \$(this).attr('action'), 				// метод актион из формы
		beforeSend: function () {					// выполнить перед началом загрузки
			\$('.spinner-grow').removeClass('d-none');
			\$('.text').addClass('d-none');
			\$('div.title_log h2').text("Поехали мерять...");
		},
		complete: function () {						//выполнить по окончанию загрузки
    
			\$('.spinner-grow').addClass('d-none');
		},
        success: function(response) { 				// on success..
            \$('#log').html(response); 				// update the DIV
        }
    });
    return false; 									// cancel original event to prevent form submitting
});
   </script> 
   	


  ~; 
  print qq~
<div id=\"zyoma\">nnzimin\@mts.ru</div>
</body></html>
~;
print "</body>";
  

sub FundRing{
my $sw = shift;
my $base_rings = 'ring_base.txt';
my $result;
my $connect;

#say $sw;
my @ring_list;
my @df_output2 = qx(cat $base_rings| grep $sw);


foreach my $ring_main (@df_output2){

@ring_list = split /,\s/, $ring_main;
  last;
}
#Смотрим куда подключен
foreach my $ring (@ring_list){

if ($ring eq $sw) {last;}
$connect = $ring;

}
#Ищем где проблема
	foreach my $ring (@ring_list){
		my $p = Net::Ping->new("tcp", 2);
		$p->{'port_num'} = 23;
			unless ($p->ping($ring,$pingtimeout)){
			$result = "Проблема на <font color ='blue'>$ring</font>";
			
			last;
			}
			
		$p->close();
	}
	
	
	


return ($result, $connect);
}

sub op_Connect{
my $op = shift;
my $base_op = 'op_base.txt';
my $result;

my $string = qx(cat $base_op| grep $op);

if ($string =~ /^\S+\s(\S+)\s(\S+)/){
my $dev =$1;
my $ip =$2;
return ($dev, $ip);
 }
}