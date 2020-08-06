#!/usr/bin/perl 



use Net::SNMP;
use strict;
use Fcntl;
use Socket;
use CGI;
use 5.010;

my $line;
my $snmp_oid = '.1.3.6.1.2.1.1.2.0';
my $start;
my $lengA;
my $lengB;
my $statA;
my $statB;
my $id;
my $nports =25;
my $my_cgi;

print "Content-type: text/html\n\n";
 $my_cgi = new CGI;
 $line = $my_cgi->param('name');
 $line =~ s/\s+//;
 #my $modul = $1;
 #my $host = $2;
 
 print qq~
<head>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
</head>
<body>

~;

my ($session, $error) = Net::SNMP->session
        (
            -retries => "2",
            -hostname => $line,
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
$start = '.1.3.6.1.4.1.171.12.58.1.1.1.12';
$lengA= '.1.3.6.1.4.1.171.12.58.1.1.1.9';
$lengB= '.1.3.6.1.4.1.171.12.58.1.1.1.10';
$statA= '.1.3.6.1.4.1.171.12.58.1.1.1.5';
$statB= '.1.3.6.1.4.1.171.12.58.1.1.1.6';

	$id = 1;
	}

#DES-3200-28
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.113.1.3")
	{
	$start = '.1.3.6.1.4.1.171.12.58.1.1.1.12';
$lengA= '.1.3.6.1.4.1.171.12.58.1.1.1.9';
$lengB= '.1.3.6.1.4.1.171.12.58.1.1.1.10';
$statA= '.1.3.6.1.4.1.171.12.58.1.1.1.5';
$statB= '.1.3.6.1.4.1.171.12.58.1.1.1.6';
	$id = 2;
	}

#DES-3200-52/C1
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.113.9.1")
	{
	$start = '.1.3.6.1.4.1.171.12.58.1.1.1.12';
$lengA= '.1.3.6.1.4.1.171.12.58.1.1.1.9';
$lengB= '.1.3.6.1.4.1.171.12.58.1.1.1.10';
$statA= '.1.3.6.1.4.1.171.12.58.1.1.1.5';
$statB= '.1.3.6.1.4.1.171.12.58.1.1.1.6';
$nports = 49;
	$id = 3;
	}

#DES-1210-28/ME-B2
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.75.15.2")
	{
	$start = '.1.3.6.1.4.1.171.10.75.15.2.35.1.1.12';
$lengA= '.1.3.6.1.4.1.171.10.75.15.2.35.1.1.9';
$lengB= '.1.3.6.1.4.1.171.10.75.15.2.35.1.1.10';
$statA= '.1.3.6.1.4.1.171.10.75.15.2.35.1.1.5';
$statB= '.1.3.6.1.4.1.171.10.75.15.2.35.1.1.6';
	$id = 14;
	}

#DES-1210-28/ME-B3   
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.171.10.75.15.3")
	{
		$start = '.1.3.6.1.4.1.171.10.75.15.2.35.1.1.12';
$lengA= '.1.3.6.1.4.1.171.10.75.15.2.35.1.1.9';
$lengB= '.1.3.6.1.4.1.171.10.75.15.2.35.1.1.10';
$statA= '.1.3.6.1.4.1.171.10.75.15.2.35.1.1.5';
$statB= '.1.3.6.1.4.1.171.10.75.15.2.35.1.1.6';
	$id = 15;
	}
	
	#Huawei S2326TP-EI   #Huawei S2328P-EI-AC
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.92" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.94"|| $result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.80" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.2011.2.23.229")
	{
		$start = '.1.3.6.1.4.1.2011.5.25.31.1.1.7.1.4';
$lengA= '.1.3.6.1.4.1.2011.5.25.31.1.1.7.1.3';
$statA= '.1.3.6.1.4.1.2011.5.25.31.1.1.7.1.2';
	$id = 24;
	$nports = 29;
	}
	
	#EDGE-Core ES3528M
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.259.6.10.94")
	{

		$start = '.1.3.6.1.4.1.259.6.10.94.1.2.3.1.0';
$lengA= '.1.3.6.1.4.1.259.6.10.94.1.2.3.2.1.6';
$lengB= '.1.3.6.1.4.1.259.6.10.94.1.2.3.2.1.7';
$statA= '.1.3.6.1.4.1.259.6.10.94.1.2.3.2.1.2';
$statB= '.1.3.6.1.4.1.259.6.10.94.1.2.3.2.1.3';
	$id = 26;
	}

#EDGE-Core ECS3510-28T  
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.259.10.1.27.101")
	{
		$start = '.1.3.6.1.4.1.259.10.1.27.1.2.3.1.0';
$lengA= '.1.3.6.1.4.1.259.10.1.27.1.2.3.2.1.6';
$lengB= '.1.3.6.1.4.1.259.10.1.27.1.2.3.2.1.7';
$statA= '.1.3.6.1.4.1.259.10.1.27.1.2.3.2.1.2';
$statB= '.1.3.6.1.4.1.259.10.1.27.1.2.3.2.1.3';
	$id = 25;

	}


	
	else {
		print "Работе с таким коммутатором еще не обучен.\n";
		exit;
		}
	$session->close();

print "<div class= \"alert alert-success\" role=\"alert\">";
print "<h4 class=\"alert-heading\">$line</h4><p>Длина кабеля на портах.</p><hr>";


	 my ($session, $error) = Net::SNMP->session
        (
            -retries => "1",
            -hostname => $line,
            -version => "1",
            -community => "duty615",
            -port => 161,
            -timeout => "1",
            -translate => [-octetstring => 0x0]
        ); 

if ($id < 24) {
my( @list);
for (my $i=1; $i < $nports; $i++) {
    push( @list, ("$start.$i", INTEGER, 1));

	 
 }

  my $result = $session->set_request( -varbindlist => [@list]);
  
  sleep (5);


  
  my( @list);
for (my $i=1; $i < $nports; $i++) {

   my $snmptemp = $session -> get_request("$lengA.$i");
  my  $A = $snmptemp -> {"$lengA.$i"};
  my $snmptemp = $session -> get_request("$lengB.$i");
  my  $B = $snmptemp -> {"$lengB.$i"};
    my $snmptemp = $session -> get_request("$statA.$i");
  my  $s_A = $snmptemp -> {"$statA.$i"};
      my $snmptemp = $session -> get_request("$statB.$i");
  my  $s_B = $snmptemp -> {"$statB.$i"};
  if ($s_A == 0 ){$s_A = 'ок';}
  elsif ($s_A == 1 ){$s_A = 'open';}
    elsif ($s_A == 2 ){$s_A = 'short';}
	  elsif ($s_A == 3 ){$s_A = 'open-short';}
	    elsif ($s_A == 4 ){$s_A = 'crosstalk';}
		  elsif ($s_A == 5 ){$s_A = 'unknown';}
		    elsif ($s_A == 6 ){$s_A = 'count';}
			  elsif ($s_A == 7 ){$s_A = 'no-cable';}
			    elsif ($s_A == 8 ){$s_A = 'other';}
  if ($s_B == 0 ){$s_B = 'ок';}
  elsif ($s_B == 1 ){$s_B = 'open';}
    elsif ($s_B == 2 ){$s_B = 'short';}
	  elsif ($s_B == 3 ){$s_B = 'open-short';}
	    elsif ($s_B == 4 ){$s_B = 'crosstalk';}
		  elsif ($s_B == 5 ){$s_B = 'unknown';}
		    elsif ($s_B == 6 ){$s_B = 'count';}
			  elsif ($s_B == 7 ){$s_B = 'no-cable';}
			    elsif ($s_B == 8 ){$s_B = 'other';}				
  print "<p class=\"mb-0\"><b><u>Порт $i</u></b><br>Пара А: $s_A $A м<br>Пара В: $s_B $B м</p>";

	 
 }
 }
 #------------------------------------------------------------------------------------------------------------------------------------------
 
 if ($id == 24) {
 my( @list);
for (my $i=5; $i < $nports; $i++) {
    push( @list, ("$start.$i", INTEGER, 1));

	 
 }

  my $result = $session->set_request( -varbindlist => [@list]);
  
  sleep (5);
 
  my( @list);
for (my $i=5; $i < $nports; $i++) {

   my $snmptemp = $session -> get_request("$lengA.$i");
  my  $A = $snmptemp -> {"$lengA.$i"};
    my $snmptemp = $session -> get_request("$statA.$i");
  my  $s_A = $snmptemp -> {"$statA.$i"};
      

  if ($s_A == 1 ){$s_A = 'normal';}
    elsif ($s_A == 2 ){$s_A = 'open';}
	  elsif ($s_A == 3 ){$s_A = 'short';}
	    elsif ($s_A == 4 ){$s_A = 'open-short';}
		  elsif ($s_A == 5 ){$s_A = 'CrossTalk';}
		    elsif ($s_A == 6 ){$s_A = 'unknown';}
			  elsif ($s_A == 7 ){$s_A = 'notSupport';}
			  
my $port = $i - 4 ; 
  print "<p class=\"mb-0\"><b><u>Порт $port</u></b><br>Длина: $s_A $A м<br></p>";

	 
 }
 
 }
 #--------------------------------------------------------------------------------------------------------------
 if ($id == 25 || $id == 26) {
my( @list);
for (my $i=1; $i < $nports; $i++) {
    push( @list, ("$start", INTEGER, $i));

	 
 }

  my $result = $session->set_request( -varbindlist => [@list]);
  
  
  sleep (20);


  
  my( @list);
for (my $i=1; $i < $nports; $i++) {

   my $snmptemp = $session -> get_request("$lengA.$i");
  my  $A = $snmptemp -> {"$lengA.$i"};
  my $snmptemp = $session -> get_request("$lengB.$i");
  my  $B = $snmptemp -> {"$lengB.$i"};
    my $snmptemp = $session -> get_request("$statA.$i");
  my  $s_A = $snmptemp -> {"$statA.$i"};
      my $snmptemp = $session -> get_request("$statB.$i");
  my  $s_B = $snmptemp -> {"$statB.$i"};
  if ($s_A == 1 ){$s_A = 'notTested';}
  elsif ($s_A == 2 ){$s_A = 'ok';}
    elsif ($s_A == 3 ){$s_A = 'open';}
	  elsif ($s_A == 4 ){$s_A = 'short';}
	   elsif ($s_A == 5 ){$s_A = 'openShort';}
		elsif ($s_A == 6 ){$s_A = 'crosstalk';}
		   elsif ($s_A == 7 ){$s_A = 'unknown';}
			  elsif ($s_A == 8 ){$s_A = 'Mismatch';}
			    elsif ($s_A == 9 ){$s_A = 'failed';}
					elsif ($s_A == 10 ){$s_A = 'notSupported';}
						elsif ($s_A == 11 ){$s_A = 'noCable';}
							elsif ($s_A == 12 ){$s_A = 'идет тестирование';}
 if ($s_B == 1 ){$s_B = 'notTested';}
  elsif ($s_B == 2 ){$s_B = 'ok';}
    elsif ($s_B == 3 ){$s_B = 'open';}
	  elsif ($s_B == 4 ){$s_B = 'short';}
	    elsif ($s_B == 5 ){$s_B = 'openShort';}
		elsif ($s_B == 6 ){$s_B = 'crosstalk';}
		   elsif ($s_B == 7 ){$s_B = 'unknown';}
			  elsif ($s_B == 8 ){$s_B = 'Mismatch';}
			    elsif ($s_B == 9 ){$s_B = 'failed';}
					elsif ($s_B == 10 ){$s_B = 'notSupported';}
						elsif ($s_B == 11 ){$s_B = 'noCable';}
							elsif ($s_B == 12 ){$s_B = 'идет тестирование';}			
  print "<p class=\"mb-0\"><b><u>Порт $i</u></b><br>Пара А: $s_A $A м<br>Пара В: $s_B $B м<br></p>";
sleep 1;
	 
 }
 }
 #------------------------------------------------------------------------------------------------------------------------------------------

  
  $session->close();



print "</div>";
		
	
