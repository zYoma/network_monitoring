package lldp;
require Exporter;
@ISA=qw(Exporter);

$EXPORT[0]=qw(NN);	
use Net::SNMP qw(:snmp);
use Socket;
####################################################################
sub NN  
{

my $input=$_[0];
my $snmp_oid = '.1.3.6.1.2.1.1.2.0';
my $getLldp=".1.0.8802.1.1.2.1.4.1.1.9";
my $lldp;
my @scanRange;
my @scanRange2;
my %hash=();

my ($session, $snmperror) = Net::SNMP->session
        (
            -retries => "2",
            -hostname => $input,
            -version => "2c",
            -community => "icomm",
            -port => 161,
            -timeout => "2",
            -translate => [-octetstring => 0x0]
        );
		
		


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
	
		
		if ($lldp ne ''){
		if ( $lldp =~ /sdo3002/ || $lldp =~ /tuz19/){next;}
		#my $ip = inet_ntoa((gethostbyname("$lldp"))[4]);
		
		push @scanRange, "$lldp";
		$hash{"$lldp"} = undef;
		}
	}
	
		}
};

$session->close(); 
	foreach my $dev (@scanRange){
	#if ($dev =~ /(\S+-p\d+)\.\S+/){ $dev = $1;print "regu $dev<br>"; }
eval{	
my $ip = inet_ntoa((gethostbyname("$dev"))[4]);
push @scanRange2, "$ip";
};
if ($@) {
		print "<font color = 'red'>Не находит IP для $dev</font><br>";
}

}	

		
	foreach my $dev (@scanRange){
	#print "$dev<br>";
	if ($dev =~ /dm[1-5]-/ || $dev =~ /qm[1-5]-/ || $dev =~ /qx[1-5]-/ || $dev =~ /sm[1-5]-/ || $dev =~ /^s[0-5]-/ || $dev =~ /sdo3002/ || $dev =~ /tuz19/
	|| $dev =~ /d2-nvrsk-volgogradskaya20-p2/
|| $dev =~ /d2-nvrsk-desantnikov24-p1/
|| $dev =~ /d4-nvrsk-kozlova62/
|| $dev =~ /d2-nvrsk-kozlova62/
|| $dev =~ /d3-nvrsk-kozlova62/
|| $dev =~ /d1-nvrsk-suvorovskaya2b-p2/
|| $dev =~ /d2-nvrsk-kunikova9-p4/
|| $dev =~ /d2-nvrsk-vidova167-p10/ 
|| $dev =~ /d2-nvrsk-nabereg9-mkc/  
||$dev =~ /d1-nvrsk-nabereg9-mkc/ 
|| $dev =~ /d2-nvrsk-pionerskaya39-p1/  
||$dev =~ /d3-nvrsk-kunikova9-p4/ 
|| $dev =~ /d2-nvrsk-kunikova9-p4/


	){next;} 
	#$hash{"$dev"} = undef;
	
	my ($session, $snmperror) = Net::SNMP->session
        (
            -retries => "2",
            -hostname => $dev,
            -version => "2c",
            -community => "icomm",
            -port => 161,
            -timeout => "2",
            -translate => [-octetstring => 0x0]
        );
		if (!defined $session) {print "<font color = 'red'>$dev Не отвечает по snmp</font><br>";next;}
#------------------------------------------------------------------	
#если агрегация, скипаем
my $id = 30;
my	$result = $session->get_request("$snmp_oid");
unless (defined $result) {
print " <font color = 'red'>$dev не отвечает по snmp.</font>";
next;
}	
if ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.119.6")
	{
	$id = 1;
	}

#DGS-3627G
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.70.8")
	{
	$id = 2;
	}

#DGS-3420-28SC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.119.2")
	{
	$id = 3;
	}
	  #Huawei S5300-28X-LI-24S-AC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.221")
	{
	$id = 4;
	}

	  # Catalyst 4500 L3
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.917" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.788")
	{

	$id = 5;
	}
	
		  # Catalyst C2960
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.716" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.694" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.799" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.696")
	{

	$id = 6;
	}

	#Cisco C3750ME
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.574")
{
$id = 7;
}

#Cisco C2950
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.359")
{
$id = 8;
}
#Cisco ME340x
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.780")
{
$id = 9;
}

#Cisco ME360x
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.1250")
{
$id = 10;
}

#Cisco c7600
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.9.1.863")
{
$id = 11;
}

#Quidway S5624P 
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.10.1.43")
{
$id = 12;
}

#Quidway S9303
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.170.1")
{
$id = 13;
}

if ($id < 20 ){next;}

#---------------------------------------------------------------

	
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
		if ($lldp ne ''){
			unless(exists($hash{"$lldp"})){
			if ( $lldp =~ /sdo3002/ || $lldp =~ /tuz19/){next;}
			if ($lldp =~ /(\S+-p\d+)\.\S+/){ $lldp = $1;print "regu2 $lldp"; }
			my $ip = inet_ntoa((gethostbyname("$lldp"))[4]);
			$hash{"$lldp"} = undef;
			push @scanRange, "$lldp";
			push @scanRange2, "$ip";
			}
		
		}
	}
		}

};
	
	
	
	$session->close();  
	}
		




return @scanRange2;
}

##################################################################
