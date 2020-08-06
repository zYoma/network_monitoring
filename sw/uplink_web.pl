#!/usr/bin/perl 


use CGI;
use Net::SNMP qw(:snmp);
use strict;
use Fcntl;
use Term::ANSIColor qw(:constants);
use Net::Ping;
use Socket;
use 5.010;

my $lldpPortNumberOid = '.1.0.8802.1.1.2.1.4.1.1.7';
my $rootPortOid ='.1.3.6.1.2.1.17.2.7';
my $snmp_oid = '.1.3.6.1.2.1.1.2.0';
my $getLldp=".1.0.8802.1.1.2.1.4.1.1.9";
my $input;
my $lldp;
my @lldpDB;
my @lldpDB2;
my  $rootPort;
my $id;
my $snmptemp;
my $temp_port;
my $name_port;
my %hash=();
my %snmplldpnei_hash =();
my %hashLLDPdescription=();
my $lldp_description;
my $lldp_port_number;
my %hashLLDP=();
my $my_cgi;

print "Content-type: text/html\n\n";
$my_cgi = new CGI;
 $input = $my_cgi->param('name');
$input =~ s/\s+//g;
#Получаем NS запись
		my	$dns = gethostbyaddr(inet_aton($input), AF_INET)
  or die "Can't resolve $input: $!\n";
$dns =~ s/(\w+)\.\w+/$1/; #отрезаем .local
$input = $dns;
 push @lldpDB,"$input\n";

foreach (@lldpDB)
{
#sleep 1;
$input = $_;
$input =~ s/(.+)\s$/$1/;
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
	
	$id = 1;
	}

#DES-3200-28
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.113.1.3")
	{
	
	$id = 2;
	}

#DES-3200-52/C1
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.113.9.1")
	{
	
	$id = 3;
	}

#DGS-1210-10/ME/A1      #DGS-1210-10/ME 
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.76.42.1")
	{

	$id = 4;
	}

    #DGS-1210-10P/ME/A1 
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.76.35.1" )
	{
	
	$id = 5;
	}

    #DGS-1210-10P/ME/A1 
elsif ( $result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.76.32.1")
	{
	
	$id = 6;
	}

#DGS-3700-12G
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.102.1.2")
	{
	
	$id = 7;
	}

#DGS-1210-28/ME/A1
	elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.76.28.1")
	{
	
	$id = 8;
	}

#DGS-3420-26SC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.119.6")
	{
	
	$id = 9;
	}

#DGS-3627G
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.70.8")
	{
	
	$id = 10;
	}

#DGS-3420-28SC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.119.2")
	{
	
	$id = 11;
	}
#DES-3028
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.63.6")
	{
	
	$id = 12;
	
}

#D-Link DES-3010G
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.63.1.2")
	{
	
	$id = 13;
	}

##DES-1210-28/ME-B2
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.75.15.2")
	{
	
	$id = 14;
	}

#DES-1210-28/ME-B3   
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.75.15.3")
	{
	
	$id = 15;
	}

#DES-3526
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.64.1")
	{

	$id = 16;
	}

#ZyXEL IES-1000 AAM1008-61
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.890.1.5.11.6")
	{
	
	$id = 17;
	}

#ZyXEL GS-4012F
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.890.1.5.8.20")
	{

	$id = 18;
	}

#EDGE-Core ES3528M
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.259.6.10.94")
	{

	$id = 19;
	}

#EDGE-Core ECS3510-28T  
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.259.10.1.27.101")
	{
	
	$id = 20;

	}

#24-port 10/100 + 4-Port Gigabit Switch with CLI and WebView
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.3955.6.9.224.1")
	{
	
	$id = 21;
	}

#H3C S3100-26TP-EI
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.25506.1.246")
	{
	
	$id = 22;
	}

#H3C S3100-16TP-EI
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.25506.1.245")
	{
	
	$id = 23;
	}

#Huawei S2326TP-EI   #Huawei S2328P-EI-AC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.92" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.80" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.229")
	{

	$id = 24;
	}

	   #Huawei S5300-28X-LI-24S-AC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.221" )
	{
	
	$id = 25;
	}

  # Catalyst 4500 L3
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.917" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.788")
	{
	
	$id = 26;
	}
	
		  # Catalyst C2960
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.716" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.694" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.799" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.696")
	{
	
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
	else {
		print "Unknown device\n";
		}







				

		
		
#print "Работаем с $_\nid = $id";
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
#print "Root port - $rootPort\n";

if ($rootPort eq ''){
next;
}



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
		#print "Сосед - $lldp, Порт - $1\n";

  if( $lldp_port == $rootPort ) #если порт  рут
  {
    
	foreach (@lldpDB)
{


 my $data = join "", @lldpDB;
    if ($data =~ /$lldp\n/) { #если в массиве уже есть такой хостнейм
        
       #print "Проверка в массиве Не добавляем $lldp\n\n";
    next;
    }

  else {
  my $data = join "", $lldp;
  if ($data =~ /sdo3002-.+/){
  next;
  }
  else{
  #print "Проверка в массиве Добавляем $lldp\n\n";
		push @lldpDB,"$lldp\n";
		push @lldpDB2,"<br>$lldp - <b>$hashLLDPdescription{$lldp_port}</b>";
		last;
  }
  }
}
	

    
  }
else{#print "Не добавляем $lldp\n\n";
}

}
	}
		

};
$lldp = undef;
$rootPort = undef;
%hashLLDPdescription=();
$lldp_description= undef;
 $temp_port= undef;
 $name_port= undef;
 %hash=();
 my $lldp_port_number;
my %hashLLDP=();
#print "________________________________________________________\n";
$session->close();
}
				

print "<font color ='#8B0000'>Uplink от заданного хоста до корневого коммутатора в stp дереве. Если все настроено верно и протокол корректно отрабатывает - до агрегации.<br>На всех коммутаторах должен быть настроен пратокол lldp.</font><br><br>";
print "\n@lldpDB2\n\n";


