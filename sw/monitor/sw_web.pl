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

my $width = '380';
my %hashLLDPdescription=();
my $lldp_description;
my $lldp_port_number;
my %hashLLDP=();
my @vlanMemberUn2;
my $rootPortOid ='.1.3.6.1.2.1.17.2.7';
my $snmp_oid = '.1.3.6.1.2.1.1.2.0';
my $ip;
my $input;
my @vlanDB;
my @NOvlan;
my $getVlanTable =".1.3.6.1.2.1.17.7.1.4.2.1.3.0";
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
my $oidIp ='IP-MIB::ipAdEntAddr';
my $IPaddres;
my @ipOID;
my $cpu;
my $getHash ='.1.3.6.1.2.1.17.7.1.4.3.1.2';
my $getHashUn ='.1.3.6.1.2.1.17.7.1.4.3.1.4';
my @hash;
my @vlanMember;
my @vlanMemberUn;
my $vlanMember;
my $vlanMemberUn;
my $vlanName;
my @last1;
my @last2;
my $tem;
my $dns;
my $temOid= '.1.3.6.1.4.1.171.12.11.1.8.1.2.1';
my $temp_port;
my $name_port;
my %hash = ();
my %hashVlan = ();
my $keyP;
my $valueP;
my $rootPort;
my @vlanPortTemm;
my $lldpPortNumberOid = '.1.0.8802.1.1.2.1.4.1.1.7';
my $base_rings = '/home/nnzimin/ring_base.txt';

print "Content-type: text/html\n\n";
$my_cgi = new CGI;
 $input = $my_cgi->param('name');


#chomp ($input = <STDIN>);
$input =~ s/\s+//g;

print qq~

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
 <title> Данные с коммутаторов ШПД</title>
  <link rel="shortcut icon" href="favicon.ico" type="image/x-icon">
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
  <link rel="stylesheet" href="http://10.40.254.109/op/style.css">
</head>
<body>
  <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
   
   <script type="text/javascript">
  if (navigator.userAgent.search(/MSIE/) > 0 || navigator.userAgent.search(/NET CLR /) > 0) {window.location.replace("http://10.40.254.109/op/sw/monitor/ie.html");};
   function isSW(obj) {
    var str = obj.text;
   document.getElementById('my_input').value = str;
	document.getElementById('my_form').submit();
	
   }

  </script>  
  
  <script src="http://10.40.254.109/op/header.js"></script>

  
  <center><p>Введите IP адрес или доменное имя коммутатора ШПД.</p>
    <div id="wrapper">
  <form method='post' action='sw_web.pl'>
  <div class="form-row">
    <div class="col-auto">
      <input type="text" name='name' value="$input" class="form-control mb-2" id="inlineFormInput" placeholder="IP или DNS" style="float:left; width: 250px;">
    </div>
    <div class="col-auto">
      <button type="submit" class="btn btn-danger mb-2">Получить данные</button>
    </div>
  </div>
</form>
 

 <select size="1" class="form-control form-control-sm mb-2" id="Select" onchange="document.getElementById('inlineFormInput').value= this.value" style="float:left; width: 250px;">
    <option value="">Магистральные узлы</option>
		<option value="10.228.116.156">dm1-kdr-ats2 40 лет Победы 43</option>
		<option value="10.228.116.163">dm1-kdr-ats3 Маркса 14</option>
		<option value="10.228.116.160">dm1-kdr-ats4 Репино 20</option>
		<option value="10.228.116.149">dm2-kdr-ats4 Репино 20</option>
		<option value="10.228.116.180">dm1-kdr-ats6 Северная 279</option>
		<option value="10.228.116.140">dm2-kdr-ats6 Северная 279</option>
		<option value="10.228.116.159">dm1-kdr-70lo34-p8</option>
	<option value="10.228.116.171">dm2-kdr-70lo34-p8</option>
	<option value="10.228.116.162">dm3-kdr-70lo34-p8</option>
	<option value="10.228.117.234">dm1-kdr-averkieva6-p3</option>
	<option value="10.228.117.235">dm2-kdr-averkieva6-p3</option>
		<option value="10.228.79.90">dm1-kdr-blago48-p3</option>
		<option value="10.228.79.196">qx1-kdr-blago4-p4</option>
			<option value="10.228.104.88">dm1-kdr-vkrug28-2-p4</option>
	<option value="10.228.104.120">dm2-kdr-vkrug28-2-p4</option>
	<option value="10.228.117.240">dm1-kdr-vkrug65-p3</option>
	<option value="10.228.79.219">qx1-kdr-gidro43-p2</option>
	<option value="10.228.119.209">dm1-kdr-garazh77-1-p3</option>
		<option value="10.228.74.144">dm1-kdr-dimit137-p3</option>
		<option value="10.228.119.150">dm1-kdr-dushis49-p2</option>
	<option value="10.228.119.196">dm2-kdr-dushis49-p2</option>
		<option value="10.228.104.247">dm1-kdr-zip48-p3</option>
			<option value="10.228.126.29">dm1-kdr-esenina131-p4</option>
		<option value="10.228.126.30">dm2-kdr-esenina131-p4</option>
		<option value="10.228.126.31">dm3-kdr-esenina131-p4</option>
		<option value="10.228.64.242">dm4-kdr-esenina131-p4</option>
			<option value="10.228.126.121">qm1-kdr-esenina131-p4</option>
		<option value="10.228.79.10">qx1-kdr-ignat63-p3</option>
	<option value="10.228.79.91">qx1-kdr-ignat4-p2</option>
		<option value="10.228.118.72">dm1-kdr-ishunina7</option>
	<option value="10.228.116.161">dm1-kdr-ignat35-p4</option>
	<option value="10.228.116.155">dm2-kdr-ignat35-p4</option>
	<option value="10.228.76.33">qx1-kdr-ignat35-p4</option>
	<option value="10.228.70.75">dm1-kdr-krasnpar248-p3</option>
	<option value="10.228.117.89">dm1-kdr-kotlyarova17-p1</option>
	<option value="10.228.117.147">dm2-kdr-kotlyarova17-p1</option>
	<option value="10.228.117.148">dm3-kdr-kotlyarova17-p1</option>
	<option value="10.228.118.37">dm1-kdr-kazbek7-p1</option>
	<option value="10.228.118.64">dm2-kdr-kazbek7-p1</option>
	<option value="10.228.119.15">dm1-kdr-karasun320</option>
<option value="10.228.119.175">dm1-kdr-korenov69-p1</option>
<option value="10.228.116.151">qm1-kdr-lukjanenko95-2</option>
<option value="10.228.126.81">dm1-kdr-morskaya54</option>
<option value="10.228.126.200">qx1-kdr-morskaya11-p2</option>
<option value="10.228.79.132">dm1-kdr-nevki15-p3</option>
	<option value="10.228.72.200">dm1-kdr-razved28-p3</option>
	<option value="10.229.123.142">dm1-kdr-pokryshk4-10-p2</option>
	<option value="10.228.77.11">dm1-kdr-prioz13-p6</option>
	<option value="10.228.73.179">dm1-kdr-stavr182</option>
	<option value="10.228.74.145">dm1-kdr-stavr232</option>
	<option value="10.228.74.254">qx1-kdr-selez76-p3</option>
	<option value="10.228.116.154">dm1-kdr-sormo185-p1</option>
<option value="10.228.78.200">dm2-kdr-sormo185-p1</option>
<option value="10.228.77.10">qx1-kdr-sormo102-p1</option>

	<option value="10.228.77.6">dm1-kdr-urals194-p8</option>
	<option value="10.228.77.9">dm1-kdr-urals154-2-p2</option>
	
	<option value="10.228.78.191">dm1-kdr-urals178-p5</option>
	<option value="10.228.78.194">dm1-kdr-tulae12-p3</option>
	<option value="10.229.127.152">dm1-kdr-trosheva33-p4</option>
		<option value="10.228.76.18">dm1-kdr-trudo23-p4</option>
		<option value="10.229.127.152">dm1-kdr-trosheva33-p4</option>
	

	</select>
	 </div>



~;

print " <title> Данные с коммутаторов ШПД</title>";

if ($input eq '') {exit;} 
 
if ($input =~ /^(\D)(?=\w)/)  # Найти цифру за которой стоит '-'
{
$input =~ s/(\w+)\.\w+/$1/;
}
eval{
			#Получаем NS запись
			$dns = gethostbyaddr(inet_aton($input), AF_INET)
  or die "Can't resolve $input: $!\n";
$dns =~ s/(\w+)\.\w+/$1/; #отрезаем .local
};
my $p = Net::Ping->new("tcp", 2);
$p->{'port_num'} = 23;
    
if ($p->ping($input,0.500)){
        
    $p->close();
 }
	else{
         print "<div class=\"layer\"><font size ='17pt'><center> <font color = 'red'>$input</font>  не отвечает.</font></div>";
print "</center>";
		 
		exit;
        $p->close();
        } 



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
unless (defined $result) {
print " <div class=\"layer\"><font size ='17pt'><center> <font color = 'red'>$input</font>  не отвечает по snmp.</font></div>";

exit;
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
	    #DGS-1210-10/ME/B1
elsif ( $result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.76.35.2")
	{
	$getFireware = '.1.3.6.1.4.1.171.10.76.35.2.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.76.35.2.1.30.0';
	$getRev = '.1.3.6.1.4.1.171.10.76.35.2.1.2.0';
	$id = 5;
	}

    #DGS-1210-10P/ME/A1 
elsif ( $result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.76.32.1")
	{
	$getFireware = '.1.3.6.1.4.1.171.10.76.32.1.1.3.0';
	$getSn = '.1.3.6.1.4.1.171.10.76.32.1.1.30.0';
	$getRev = '.1.3.6.1.4.1.171.10.76.32.1.1.2.0';
	$id = 6;
	$getVlanTable =".1.3.6.1.4.1.171.10.76.32.1.7.6.1.1";
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
	$getRev = '.1.3.6.1.4.1.171.10.76.28.1.1.2.0';
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
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.92" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.80" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.229")
	{
	$width ='425';
	$temOid= '.1.3.6.1.4.1.2011.5.25.31.1.1.1.1.11.67108873';
	$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.67108873';
	$id = 24;
	}

  #Huawei S5300-28X-LI-24S-AC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.221")
	{
	$width ='410';
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

	#Cisco C3750ME
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.574")
{
$id = 28;
$getFireware = '.1.3.6.1.4.1.9.2.1.73.0';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.1001';
	$temOid= '.1.3.6.1.4.1.9.9.13.1.3.1.3.1005';
}

#Cisco C2950
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.359")
{
$id = 29;
$getFireware = '.1.3.6.1.4.1.9.2.1.73.0';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.1';
	$temOid= '.1.3.6.1.4.1.9.9.13.1.3.1.3.1005';
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
$width ='410';
$id = 31;
$temOid= '.1.3.6.1.4.1.2011.5.25.31.1.1.1.1.11.67108873';
$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.67108873';
}

#Quidway S9303
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.170.1")
{
$width ='410';
$id = 32;
$temOid= '.1.3.6.1.4.1.2011.5.25.31.1.1.1.1.11.67108873';
$getFireware = '1.3.6.1.2.1.47.1.1.1.1.10.67108867';
	$getSn = '1.3.6.1.2.1.47.1.1.1.1.11.67108867';
}

	else {
		print " <div class=\"layer\"><font size ='17pt'><center> <font color = 'red'>$input</font> -неизвестное устройство.</font></div>";

exit;
		}
	
#Ревизия для 1210	

if ($id == 4 || $id == 5 || $id ==6 || $id ==8 || $id == 14 || $id == 15){
	$snmptemp = $session -> get_request("$getRev");
	$rev = $snmptemp -> {"$getRev"};
	}
	#Температура для длинков 32*
	if ($id == 1 || $id == 2 || $id ==3 || $id ==7 || $id == 9 || $id == 11|| $id == 24|| $id == 25|| $id == 26  || $id == 27  || $id == 28  || $id == 29  || $id == 30 || $id == 31|| $id == 32 || $id == 33 || $id == 34){
	$snmptemp = $session -> get_request("$temOid");
	$tem = $snmptemp -> {"$temOid"};
	}
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
	if ($id == 29 ){$device = "Catalyst C2950";}
	if ($id == 28 ){$device = "Catalyst C3750ME";}
	if ($id == 30 ){$device = "Cisco ME340x";}
	if ($id == 33 ){$device = "Cisco ME360x";}
	if ($id == 34 ){$device = "Cisco c7600";}
	if ($id == 22 || $id == 23 ){
	$device = "H3C";
	}
#get sysName
$snmptemp = $session -> get_request(".1.3.6.1.2.1.1.5.0");
 $sysname = $snmptemp -> {".1.3.6.1.2.1.1.5.0"};
 if ($id==27 || $id==28 || $id==29 || $id==30 || $id==26 || $id==33 || $id==34) {$sysname =~ s/^(.+)\.\baaanet.ru/$1/;}
 
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
 if ($id == 24 || $id == 25 || $id == 27 || $id == 32){
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
#Влан на 1 порту
$snmptemp = $session -> get_request(".1.3.6.1.2.1.17.7.1.4.5.1.1.1");
my $vlan_p1 = $snmptemp -> {".1.3.6.1.2.1.17.7.1.4.5.1.1.1"};

#get Mac
$snmptemp = $session -> get_request(".1.3.6.1.2.1.17.1.1.0");
$mac = $snmptemp -> {".1.3.6.1.2.1.17.1.1.0"};
my @arraylocalmac = $mac =~ /[0-9A-Fa-f]{2}/g; if(@arraylocalmac == 6){$mac = join "", @arraylocalmac;$mac =~ tr/A-F/a-f/;}else{$mac = unpack('H12', $mac)}
$mac =~ m/^(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)(\w\w)$/;
$mac = join '-',($1, $2, $3,$4,$5,$6);

#get Upтime
$snmptemp = $session -> get_request(".1.3.6.1.2.1.1.3.0");
$uptime = $snmptemp -> {".1.3.6.1.2.1.1.3.0"};	

#Получаем куда скросирован TechFlow
my $texh_flow = TechFlow($dns);

#Получаем Шлюз
	my $VlanMgmt =0;
		my @RoutAGR;
	   my $rout ='1.3.6.1.2.1.4.22.1.3';
				$result = $session->get_table(
					-baseoid        => $rout,
					-maxrepetitions => 25
				);

				foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) {
					my $RoutDisplay = $session->var_bind_list->{$oid};
					push @RoutAGR,"$RoutDisplay";
					
				}
				
                my $RoutAGRTrue =$RoutAGR[0];
				if ( $id == 10 || $id == 9 || $id == 11 || $id == 7){
				$RoutAGRTrue =$RoutAGR[1];
				}
				if ( $id == 1 || $id == 2 || $id == 3 || $id == 12 || $id == 13 || $id == 16 || $id==33 ){
				$RoutAGRTrue =$RoutAGR[1];
				}
				
				if ( $RoutAGRTrue eq "10.228.122.1"){
				$VlanMgmt = "120";
				}
		elsif ( $RoutAGRTrue eq "10.228.75.1"){
				$VlanMgmt = 130;
				}
				
				elsif ( $RoutAGRTrue eq "10.228.79.1" || $RoutAGRTrue eq "10.228.76.1"){
				$VlanMgmt = 131;
				}
				
				elsif ( $RoutAGRTrue eq "10.228.78.1" || $RoutAGRTrue eq "10.228.77.1" || $RoutAGRTrue eq "10.228.123.129"){
				$VlanMgmt = 132;
				}
				
				elsif ( $RoutAGRTrue eq "10.228.69.1"){
				$VlanMgmt = 133;
				}
				
				elsif ( $RoutAGRTrue eq "10.228.70.1" || $RoutAGRTrue eq "10.228.114.1" || $RoutAGRTrue eq "10.228.119.1" || $RoutAGRTrue eq "10.228.126.1" || $RoutAGRTrue eq "10.228.64.1"){
				$VlanMgmt = 135;
				}

				elsif ( $RoutAGRTrue eq "10.228.71.1" || $RoutAGRTrue eq "10.228.72.1" || $RoutAGRTrue eq "10.228.117.1" || $RoutAGRTrue eq "10.228.104.1" || $RoutAGRTrue eq "10.228.65.1"){
				$VlanMgmt = 136;
				}
					elsif ( $RoutAGRTrue eq "10.228.66.1"){
				$VlanMgmt = 137;
				}
				elsif ( $RoutAGRTrue eq "10.228.118.1" || $RoutAGRTrue eq "10.228.67.1"){
				$VlanMgmt = 138;
				}
					elsif ( $RoutAGRTrue eq "10.228.73.1" || $RoutAGRTrue eq "10.228.74.1" || $RoutAGRTrue eq "10.228.68.1"){
				$VlanMgmt = 139;
				}
			 

 	eval {
	#Имена интерфейсов для Циски
	
 	$snmptemp = $session->get_table(
	        -baseoid        => '.1.3.6.1.2.1.2.2.1.2',
			-maxrepetitions => 5
			);
	
			
	foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) {
		if ($oid =~ /^.1.3.6.1.2.1.2.2.1.2\.([\d]+)$/) {
		 $temp_port = $1;
		
		$name_port = $session->var_bind_list->{$oid};
		#Обрезаем лишнее в именах интерфейсов
			if ($name_port =~ /(\s)(?=Port)/){
		
		$name_port=~ s/^.+\b(Port)/$1/g;
		if ($id == 7 || $id == 9 ||$id == 11 || $id == 13|| $id == 16){
		$name_port=~ s/^(\bPort\s+\d+).+/$1/;
		}
		}
		
		if ($name_port =~ /(,\s)(?=port)/){
		$name_port=~ s/^.+\b(port)/$1/g;
		}
		if ($id == 24) {
		$temp_port = $temp_port - 4;
		}
		if ( $id == 25) {
		$temp_port = $temp_port - 5;
		}
		
		if ( $id == 33) {
		$temp_port = $temp_port - 10100;
		
		if ($temp_port > 100 ){$temp_port = $temp_port - 76; }
		}
			if ( $id == 34) {
		if ($temp_port > 48 ){$temp_port = $temp_port + 206; }
		}
		
		if ( $id == 32) {
		#Костыль для хуавея
     if ($temp_port == 116 || $temp_port == 117 || $temp_port == 118 || $temp_port == 119) {$temp_port=$temp_port-106;}
	 $temp_port = $temp_port + 191;
	 
		}
		$hash{ $temp_port } = $name_port;
		}
		
	#while ( ($temp_port,$name_port) = each %hash) {
  #print "$temp_port => $name_port\n";
}
};
eval{	
	#Определяем root порт
	if ($id == 14){
	$snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.2.6.1.13.0");
 $rootPort = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.2.6.1.13.0"};
	}
		elsif ($id == 15){
	$snmptemp = $session -> get_request(".1.3.6.1.4.1.171.10.75.15.3.6.1.13.0");
 $rootPort = $snmptemp -> {".1.3.6.1.4.1.171.10.75.15.3.6.1.13.0"};
	}
		elsif ($id == 3  || $id == 1){
	$snmptemp = $session -> get_request(".1.3.6.1.2.1.17.2.7.0");
 $rootPort = $snmptemp -> {".1.3.6.1.2.1.17.2.7.0"};
	}
			elsif ($id == 12 || $id == 16 || $id == 2){
	$snmptemp = $session -> get_request(".1.3.6.1.4.1.171.12.15.2.3.1.18.0");
 $rootPort = $snmptemp -> {".1.3.6.1.4.1.171.12.15.2.3.1.18.0"};
	}
	else{
 %snmplldpnei_hash = %{$session -> get_table("$rootPortOid")};
	foreach my $ipaddoid (keys %snmplldpnei_hash)
	{
		$rootPort = $snmplldpnei_hash{$ipaddoid};
		
	}
	}
	};
	
	eval{
	#дескрипшены соседних портов
	$snmptemp = $session->get_table(
	        -baseoid        => '.1.0.8802.1.1.2.1.4.1.1.8',
			-maxrepetitions => 5
			);
	
			
	foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) {
		if ($oid =~ /^.1.0.8802.1.1.2.1.4.1.1.8\.[\d]+\.([\d]+)\.[\d]+$/) {
		my $lldp_description_port = $1;
		$lldp_description = $session->var_bind_list->{$oid};
		
		if ($lldp_description =~ /^\bEthernet Port on unit/) {
		$lldp_description =~ s/^.+\b(port)/$1/g;
		}
		if ($lldp_description =~ /^\bRMON/ || $lldp_description =~ /\bDGS-3420/) {
		$lldp_description =~ s/^.+\b(Port\s\d+).+/$1/g;
		}
			if ($lldp_description =~ /^\bD-Link/ ) {
		$lldp_description =~ s/^.+\b(Port)/$1/g;
		}
			
		
		
		
		$hashLLDPdescription{ $lldp_description_port } = $lldp_description;
		
		}
	}
		

};
	eval{
	#номера соседних портов
	$snmptemp = $session->get_table(
	        -baseoid        => $lldpPortNumberOid,
			-maxrepetitions => 5
			);
	
			
	foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) {
		if ($oid =~ /^$lldpPortNumberOid\.[\d]+\.([\d]+)\.[\d]+$/) {
		my $lldp_number = $1;
		$lldp_port_number = $session->var_bind_list->{$oid};
		#если хеш, очишаем
		unless ($lldp_port_number =~ /^\w\w/) {
		$lldp_port_number = '';
		}
		
		$hashLLDP{ $lldp_number } = $lldp_port_number;
		
		}
	}
		

};

	eval{
	#для хуавея и циски
	$snmptemp = $session->get_table(
	        -baseoid        => '.1.0.8802.1.1.2.1.4.1.1.10',
			-maxrepetitions => 5
			);
	
			
	foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) {
		if ($oid =~ /^.1.0.8802.1.1.2.1.4.1.1.10\.[\d]+\.([\d]+)\.[\d]+$/) {
		my $chekPort = $1;
		my $chekHuawei = $session->var_bind_list->{$oid};
		
		if ($chekHuawei =~ /\bHuawei/ || $chekHuawei =~ /\bCisco/) {
		$hashLLDPdescription{$chekPort} = $hashLLDP{$chekPort};
		}
	}
	
	}
		

};
	eval{
	#Соседи
	$snmptemp = $session->get_table(
	        -baseoid        => $getLldp,
			-maxrepetitions => 5
			);
	
			
	foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) {
		if ($oid =~ /^$getLldp\.[\d]+\.([\d]+)\.[\d]+$/) {
		my $lldp_port = $1;
		
		$lldp = $session->var_bind_list->{$oid};
		
		if ($lldp_port eq $rootPort){
		
		push @lldpDB,"<form method='post' action='sw_web.pl'>$hash{$lldp_port}:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color='green'>$lldp</font> - <font  color='#0489B1'>$hashLLDPdescription{$lldp_port}</font> - <font color='red'><b>root    </b></font><button type=\"submit\" class=\"btn btn-outline-danger btn-sm\" style=\"padding: 0 3px ;\"  value=\"$lldp\" name=\"name\">></button> </form>";

		
		}
		else {
		push @lldpDB,"<form method='post' action='sw_web.pl'>$hash{$lldp_port}:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color='green'>$lldp</font> - <font  color='#0489B1'>$hashLLDPdescription{$lldp_port}   </font><button type=\"submit\" class=\"btn btn-outline-danger btn-sm\" style=\"padding: 0 3px ;\"  value=\"$lldp\" name=\"name\">></button></form>";
		}
		
		}
	}
		

};

eval{
		
	#Вланы
    $snmptemp = $session->get_table(
            -baseoid        => $getVlanTable,
            -maxrepetitions => 5
	         );
              
	foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) {
	if ( $id == 6 ){
	if ($oid =~ /^$getVlanTable\.([\d]+)$/) {
		my $vlan = $1;
	#my $vlan = $session->var_bind_list->{$oid};
	push @vlanDB," $vlan, ";
	}
	}

	else {
	if ($oid =~ /^$getVlanTable\.([\d]+)$/) {
		my $vlan = $1;
		
	#my $vlan = $session->var_bind_list->{$oid};
	push @vlanDB," $vlan, ";
	}		
    }
	}
	};
	eval{
	
	
	
	
	
	
	
							#Не тегированные порты
	$snmptemp = $session->get_table(
					-baseoid        => $getHashUn,
					-maxrepetitions => 5

				);
					foreach my $oid1 (oid_lex_sort(keys(%{$session->var_bind_list}))) {
						if ($oid1 =~ /^$getHashUn\.([\d]+)$/) {
							$vlanMemberUn = $1;
						    my $hash = $session->var_bind_list->{$oid1};
								
$hash = unpack('H16', $hash); #распаковываем хэш в шестнадцатиричную систему
						
						
my $dec_num = sprintf("%064b", hex($hash)); #преобразуем из шестнадцатиричной в в двоичную систему
#print "$hash  - $vlanMember -  $dec_num\n"; 
@hash = ($dec_num =~ /./g); #ложим в масив каждый символ переменной отдельно
#print "\n@hash\n";
my $last_number = 0;
	for (my $i = 0; $i < scalar(@hash); $i++ ){
		if ($hash[$i] == 1) {
		my $pnumber = $i+1;
		if ( $id == 24 || $id == 25){$pnumber = $i;}
		if ( $id == 4 ||  $id == 5 ||  $id == 6 ||  $id == 8 ||   $id == 16){$pnumber = $pnumber - 32;}
		
						
						
			
						
		
		push @vlanMemberUn,"$pnumber, ";
		push @vlanMemberUn2,"$pnumber";
		
		}
		
	}
	
	
	#Убераем последнюю запятую
	my $lastVlan = pop @vlanMemberUn;	
$lastVlan =~ s/..$//;
push @vlanMemberUn," $lastVlan";
						}
						#print "Vlan $vlanMemberUn: @vlanMemberUn\n";
					

						push @last2,"<font color='brown'>U</font>: <b>@vlanMemberUn</b>";
						$hashVlan{$vlanMemberUn}=[@vlanMemberUn2]; #добавляем массив ,без запятых, портов в хеш с ключом - вланом
							
						@vlanMemberUn = undef;
						@vlanMemberUn2 = undef;
						}

						
	#какие порты есть во влане
	
	$snmptemp = $session->get_table(
					-baseoid        => $getHash,
					-maxrepetitions => 5
					);
					

				
					foreach my $oid1 (oid_lex_sort(keys(%{$session->var_bind_list}))) {
				
						if ($oid1 =~ /^$getHash\.([\d]+)$/) {
							$vlanMember = $1;
						    my $hash = $session->var_bind_list->{$oid1};
								
$hash = unpack('H16', $hash); #распаковываем хэш в шестнадцатиричную систему
my $dec_num = sprintf("%064b", hex($hash)); #преобразуем из шестнадцатиричной в в двоичную систему
#print "$hash  - $vlanMember -  $dec_num\n"; 
@hash = ($dec_num =~ /./g); #ложим в масив каждый символ переменной отдельно
#print "\n@hash\n";
my $last_number = 0;
FOR:
	for (my $i = 0; $i < scalar(@hash); $i++ ){
		if ($hash[$i] == 1) {
		
		my $pnumber = $i+1;
		if ( $id == 24 ){$pnumber = $i;}
		if ( $id == 4 ||  $id == 5 ||  $id == 6 ||  $id == 8 ||   $id == 16){$pnumber = $pnumber - 32;}
		
					
		
	push @vlanMember,"$pnumber, ";
        
		#Сверяем каждый порт с элементами хеша массивов, если совпадение есть, удаляем порт из списка
    foreach ( @{$hashVlan{$vlanMember}} )  {
        if ( $_ eq $pnumber) {
	pop @vlanMember;
		
		
						
						
		
		}
    }

	 
		
	 

	
	}	

	}
	
	
	
	#Убераем последнюю запятую
	my $lastVlan = pop @vlanMember;	
$lastVlan =~ s/..$//;
push @vlanMember," $lastVlan";
}


	#print "Vlan $vlanMember: @vlanMember\n";
	push @last1,"<font color='green'><u><b>$vlanMember</b></u></font> <font color='brown'>  T</font>: <b>@vlanMember</b> ";
						@vlanMember = undef;
					
						
				
						}
						

						





	
};
warn $@ if $@;
			
#Cерийник для Эдчкора
if ($id == 20 || $id == 19) {
	%snmplldpnei_hash = %{$session -> get_table("$getSn")};
	foreach my $lldpneioid (keys %snmplldpnei_hash)
	{
		$serial = $snmplldpnei_hash{$lldpneioid};
	}
}
					
#прошивка для эдчкора
if ($id == 20) {
	%snmplldpnei_hash = %{$session -> get_table("$getFireware")};
	foreach my $lldpneioid (keys %snmplldpnei_hash)
	{
		$firmware = $snmplldpnei_hash{$lldpneioid};
	}
}

 
print "<center><br>";
print   "<h4><div id=\"back\">

<div class = \"row\" style=\"font-size:30px;\">
 <div class=\"col-auto\">
 <span class=\"badge badge-success\">$device</span>
</div>
<div class=\"col-auto\">
 <span class=\"badge badge-info\" style = 'background-color: #8A0829'>$sysname</span>
</div>
<div class=\"col-auto\">
 <span class=\"badge badge-info\" style = 'background-color: #8A0829'>$serial</span></div>";
if ($getRev != undef) 
{
 print "<div class=\"col-auto\" >
 <span class=\"badge badge-info\" style = 'background-color: #8A0829'>Rev. $rev</span></div>";
 }



print   "
 <div class=\"col-auto\">
 <span class=\"badge badge-info\" style = 'background-color: #8A0829'>$mac</span></div></div>
 <div class = \"row\" style=\"padding-top: 10px; font-size:30px;\">
  <div class=\"col-auto\">
<span class=\"badge badge-info\" style = 'background-color: #8A0829'>$uptime</span></div>
 <div class=\"col-auto\">
<span class=\"badge badge-info\" style = 'background-color: #8A0829'>$firmware</span></div>";

print "<div class=\"col-auto\">
<span class=\"badge badge-info\" style = 'background-color: #8A0829'>$IPaddres</span></div>
 <div class=\"col-auto\">
 <span class=\"badge badge-info\" style = 'background-color: #8A0829'>$RoutAGRTrue</span></div>
 <div class=\"col-auto\">
 <span class=\"badge badge-info\" style = 'background-color: #8A0829'>CPU $cpu %</span></div>";
  if ($tem != undef) 
{
 print "<div class=\"col-auto\">
 <span class=\"badge badge-info\" style = 'background-color: #8A0829'>t° $tem</span></div>";
 }
 print "</div>";

print qq~
<br>

  <form action="mac_web.pl" target="area" style="float: right;">
   
   <button type="submit" class="btn btn-danger" value="$input" name="name">Таблица коммутации</button>
  </form>
    <form action="ports_web.pl" target="area" style="float: right; margin-right: 10px;">

   <button type="submit" class="btn btn-danger" value="$input" id="status" name="name">Статусы портов</button>
  </form>
  
   <form action="stp_web.pl" target="area" style="float: right; margin-right: 10px;">

   <button type="submit" class="btn btn-danger" value="$input"  name="name">stp</button>
  </form>
    
	<form action="uplink_web.pl" target="area" style="float: right; margin-right: 10px;">

   <button type="submit" class="btn btn-danger" value="$input"  name="name">Uplink</button>
  </form>
  ~;
  #if ($id == 1 || $id == 3 || $id == 2 || $id == 12) {
  print qq~
    
  
  <div class="btn-group" style = "float: right; margin-right: 10px;">
  <button type="button" class="btn btn-danger dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
    Логи
  </button>
  <div class="dropdown-menu">
      <form action="log_web.pl" target="_blank" style="float: right; margin-right: 10px;">
   <button type="submit" class="btn btn-danger dropdown-item" value="$input"  name="name">Сегодня</button>
  </form>
  
    <form action="log_web_2.pl" target="_blank" style="float: right; margin-right: 10px;">
   <button type="submit" class="btn btn-danger dropdown-item" value="$input"  name="name">Вчера</button>
  </form>
  </div>
</div>
  <br>
  ~;


  print "<div class=\"my_container\"><div class=\"box\"> <div class=\"layer1\">";	
  
print "Скроссирован на $texh_flow";
#my %values;
#@values{@lldpDB} = ();
#my @unique_list = keys %values;		
#my @sorted = sort  @unique_list;


@lldpDB = map { $_->[0] }
    sort {  $a->[1] cmp $b->[1] }
    map { [$_, /(\d+)/] } @lldpDB;

@lldpDB = sort @lldpDB;
  print qq~

  <div class="col">
    
      <div class="card-body" style="background-color: #F0E68C; font-size:20px;"><span class="badge badge-info">Соседи</span><br>
       @lldpDB<br>
	   </div>
    
  </div>
<p>
  <button class="btn btn-success btn-sm" type="button" data-toggle="collapse" data-target="#multiCollapseExample2" aria-expanded="false" aria-controls="multiCollapseExample2">Show Vlan</button>
  </p>
  <div class="row">
  <div class="col">
  <div class="collapse multi-collapse" id="multiCollapseExample2">
      <div class="card-body" style="background-color: #F0E68C; font-size:16px;">
	   ~; 
      for (my $i = 0; $i < scalar(@last1); $i++ ){
		print "$last1[$i]  <br>$last2[$i]<br><br>";

	}
	print qq~
	  </div>
    </div>
	  </div>
</div>






</div>

  <div class=\"layer2\">
  <br>
  <div class=\"alert alert-warning\" role=\"alert\"><iframe name=\"area\" width=\"$width\"  height=\"570\" frameborder=\"0\" scrolling=\"auto\"></iframe></div>
  </div>
  </div>
  </div>

 ~; 
print qq~
<script>
window.onload = function () {
document.getElementById('status').click()
}
</script>
   
  
     ~; 
 
	  

	print qq~
	
	
	</h4>
    </div></center>
 ~; 

				print "";
				
$session->close();
print qq~
<div id=\"zyoma\">nnzimin\@mts.ru</div>
</body></html>
~;

sub TechFlow{
my $sw = shift;
my $result;
my @df_output2;

open(FIL,$base_rings);
my @strings = <FIL>;
chomp @strings;
close(FIL);

foreach my $line (@strings){
say "$line";
if ($line =~ /$sw/){

$result = $line;
$result =~ s/(\S+), $sw/$1/;
last;
}
}
return $result;
	}
	
	
	


