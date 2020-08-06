#!/usr/bin/perl 

use Net::SNMP qw(:snmp);
use strict;
use Fcntl;
use Term::ANSIColor qw(:constants);
use Net::Ping::External qw(ping);
use Socket;
use POSIX qw(strftime);
use CGI;
use 5.010;
my $snmptimeout = '0.500';
my $community = 'public';
my $line;
my $snmp_oid ='.1.3.6.1.2.1.1.2.0';
my $device;
my $inputU;
my $capBat;
my $temper;
my $soft;
my $snmp_com ="icomm";
my $test;
my $out;
my $volt;
my $my_cgi;
my $inCz;
my $outIst;
my $outPower;
my $outCz;
my $outputU;
my $outI;
my $inI;
my $inputU1;
my $inputU2;
my $inputU3;
my $batareU;
my $batareTime;
my $nag;
my $id;
my $powerBay;
my $czBay;
my $uBay;
my $iBay;
my $stBat;
my $st1Bat;
my $statusBat;
my $otvet;
my $soursOut;
my $color = 'green';
my $modul;
my $nextdata;
my $lastdata;
my $line1;
my $line2;
my $line3;
my $line4;
my $treshold_bat = 'none';
my $time_beckup;
my $tec_capacity;
my $inputP;
my $uptime;
my $outputP;
my $in1;
my $in2; 
my $temp;
my $gavno = 'no';

print "Content-type: text/html\n\n";


print qq~

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
 <title> Данные с усилителей</title>
   <link rel="shortcut icon" href="favicon.ico" type="image/x-icon">
    <link rel="stylesheet" href="http://10.40.254.109/op/bootstrap/css/bootstrap.min.css" >
     <link rel="stylesheet" href="http://10.40.254.109/op/style.css">
</head>

  <script type="text/javascript">
  if (navigator.userAgent.search(/MSIE/) > 0 || navigator.userAgent.search(/NET CLR /) > 0) {window.location.replace("http://10.40.254.109/op/sw/monitor/ie.html");};
   function isSW(obj) {
    var str = obj.text;
   document.getElementById('my_input').value = str;
	document.getElementById('my_form').submit();
	
   }

  </script>
  
<body>

 
  
 <script src="http://10.40.254.109/op/header.js"></script>

  <center><p>Выберите усилитель</p>
   <div id="wrapper">
  <form action="ou_web.pl" method="post" >
  
 
  <div class="form-row">
  <div class="col-auto">
  <select size="1" class="form-control" name='name' id="Select" style="float:left; width: 250px;"  >
    <option disabled>Выберите устройство</option>
    <option value="10.229.120.70">40 лет Победы 43</option>
  <option value="10.229.112.202">Аверкиева 6</option>
  <option value="10.229.119.113">Благоева 48</option>
  <option value="10.229.113.4">Восточно Кругликовская 28/2</option>
  <option value="10.229.124.131">Душистая 49</option>
  <option value="10.228.111.194">Есенина 131</option>
   <option value="10.228.111.195">Есенина 131 (2)</option>
   <option value="10.228.111.196">Есенина 131 (3)</option>
   <option value="10.229.114.169">Зиповская 48</option>
     <option value="10.229.119.4">Игнатова 35</option>
	<option value="10.228.107.44">Карасунская 320</option>
   <option value="10.228.111.193">Клубная 12А</option>
    <option value="10.229.114.172">Котлярова 17</option>
    <option value="10.229.114.171">Катлерова 17 (2)</option>
      <option value="10.228.111.190">Кореновская 69</option>
  <option value="10.229.115.43">Карла маркса 14</option>
    <option value="10.229.116.79">Казбекская 7</option>
   <option value="10.229.121.84">Лукъяненко 95/2</option>
  <option value="10.228.111.198">Морская 54</option>
  <option value="10.229.119.165">Невкипелого 15</option>
  <option value="10.229.116.48">Репина 20</option>
    <option value="10.229.116.45">Репина 20 (2)</option>
  <option value="10.229.112.201">Разведчиков 28</option>
  <option value="10.229.117.125">Северная 279</option>
  <option value="10.229.122.64">Сормовская 185</option>
    <option value="10.229.117.124">Северная 279 (2)</option>
  <option value="10.229.118.28">Ставропольская 258</option>
  <option value="10.229.112.200">Трошева 33</option>
  <option value="10.229.120.146">Яцкого 9/3</option>

	 
							
		 
   </select>
   </div>
   <div class="col-auto">
    <input type='submit' class="btn btn-danger mb-2 "  value="Получить данные" >
</div>
</div>
  </form>
  </div>
  </center>

~;



print " <title> Данные с усилителя</title>";

 $my_cgi = new CGI;
 $line = $my_cgi->param('name');
 
#chomp ($line = <STDIN>);
$line =~ s/\s+//g;
if ($line eq '') {goto END;} 
if ($line =~ /^(\D)(?=\w)/)  # Найти цифру за которой стоит '-'
{
$line =~ s/(\w+)\.\w+/$1/;
}

print "      <script type=\"text/javascript\">
for (var i = 0; i <= document.getElementById(\"Select\").options.length - 1; i++) {
if (document.getElementById(\"Select\").options[i].value == \"$line\") {
document.getElementById(\"Select\").selectedIndex = i;
break;
 }
}
</script>";



#------------------------------------------------------------------------------------------------
my $alive = ping(hostname => "$line", count => 1,  timeout => 0.900);
 unless ($alive) {
 print "<div class=\"layer\"><font size ='17pt'><center> <font color = 'red'>$line</font>  не доступен.</font></div>";
print "</center>"; 
goto END;
}


if ($line eq '10.229.119.165') {$community = 'icomm';}	
if ($line eq '10.228.111.194') {$community = 'icomm';} 
if ($line eq '10.229.122.64') {$community = 'icomm';} 
if ($line eq '10.228.111.193') {$community = 'icomm';} 
if ($line eq '10.228.111.195') {$community = 'icomm';} 
if ($line eq '10.229.116.48') {$community = 'icomm';} 
if ($line eq '10.228.111.196') {$community = 'icomm';} 
if ($line eq '10.229.119.113') {$community = 'icomm';} 


if ($line eq '10.229.112.202') {$gavno = 'yes';} 
if ($line eq '10.229.119.113') {$gavno = 'yes';} 
if ($line eq '10.228.111.194') {$gavno = 'yes';} 
if ($line eq '10.228.111.195') {$gavno = 'yes';} 
if ($line eq '10.228.111.196') {$gavno = 'yes';} 
if ($line eq '10.228.111.193') {$gavno = 'yes';} 
if ($line eq '10.229.116.48') {$gavno = 'yes';} 
if ($line eq '10.229.122.64') {$gavno = 'yes';} 
if ($line eq '10.229.117.124') {$gavno = 'yes';} 
if ($line eq '10.229.118.28') {$gavno = 'yes';} 

if ($gavno eq 'yes'){goto GAVNO;}

  my ($session, $error) = Net::SNMP->session
        (
            -retries => "1",
            -hostname => $line,
            -version => "1",
            -community => $community,
            -port => 161,
            -timeout => "1",
            -translate => [-octetstring => 0x0]
        );




				
                            

my $result = $session->get_request("$snmp_oid");
unless (defined $result) {
  print "<div class=\"layer\"><font size ='17pt'><center> <font color = 'red'>$line</font>  не отвечает по SNMP.</font></div>"; 

goto END;
}

 #------------------------------------------------------------------------------------------ 
#EDFA_OSE_DHCP_V1.272C_01
if ($result->{$snmp_oid} eq ".1.3.6.1.4.1.17409.1.11.31")
{
$id = 1;

#Выходной сигнал
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.11.2.0');
 $outputP = $snmptemp -> {'.1.3.6.1.4.1.17409.1.11.2.0'};
#Входной сигнал
 my $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.11.3.0');
  $inputP = $snmptemp -> {'.1.3.6.1.4.1.17409.1.11.3.0'};
 #Аптайм
 my $snmptemp = $session -> get_request('.1.3.6.1.2.1.1.3.0');
  $uptime = $snmptemp -> {'.1.3.6.1.2.1.1.3.0'};
  #Вход1
 my $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.11.9.0');
  $in1 = $snmptemp -> {'.1.3.6.1.4.1.17409.1.11.9.0'};
   #Вход 2
 my $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.11.10.0');
  $in2 = $snmptemp -> {'.1.3.6.1.4.1.17409.1.11.10.0'};

#Температура
 my $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.3.1.13.0');
  $temp = $snmptemp -> {'.1.3.6.1.4.1.17409.1.3.1.13.0'};

$device = 'EFA-1550-31';

$in1 = get_round($in1);
$in2 = get_round($in2);
$outputP  = get_round( $outputP );
$inputP = get_round($inputP);
 $uptime =~ s/......$//;
 }

 
 #------------------------------------------------------------------------------------------ 
 #------------------------------------------------------------------------------------------ 
#EauBs-A10.06
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.35702.3.5")
{
$id = 2;

#Выходной сигнал
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.35702.3.5.2.6.0');
 $outputP = $snmptemp -> {'.1.3.6.1.4.1.35702.3.5.2.6.0'};

 #Аптайм
 my $snmptemp = $session -> get_request('.1.3.6.1.2.1.1.3.0');
  $uptime = $snmptemp -> {'.1.3.6.1.2.1.1.3.0'};
  #Вход1
 my $snmptemp = $session -> get_request('.1.3.6.1.4.1.35702.3.5.2.2.0');
  $in1 = $snmptemp -> {'.1.3.6.1.4.1.35702.3.5.2.2.0'};
   #Вход 2
 my $snmptemp = $session -> get_request('.1.3.6.1.4.1.35702.3.5.2.3.0');
  $in2 = $snmptemp -> {'.1.3.6.1.4.1.35702.3.5.2.3.0'};

#Температура
 my $snmptemp = $session -> get_request('.1.3.6.1.4.1.35702.3.5.2.10.0');
  $temp = $snmptemp -> {'.1.3.6.1.4.1.35702.3.5.2.10.0'};

#девайс
 my $snmptemp = $session -> get_request('.1.3.6.1.4.1.35702.1.1.0');
  $device = $snmptemp -> {'.1.3.6.1.4.1.35702.1.1.0'};

$in1 = get_round($in1);
$in2 = get_round($in2);
$outputP  = get_round( $outputP );
 $uptime =~ s/......$//;
$temp= get_round( $temp );
 }

 #------------------------------------------------------------------------------------------ 
#EDFA SNMP AGENT System
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.17409.1.11")
{
$id = 3;

#Выходной сигнал
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.11.2.0');
 $outputP = $snmptemp -> {'.1.3.6.1.4.1.17409.1.11.2.0'};

 #Аптайм
 my $snmptemp = $session -> get_request('.1.3.6.1.2.1.1.3.0');
  $uptime = $snmptemp -> {'.1.3.6.1.2.1.1.3.0'};
  #Вход
 my $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.11.3.0');
  $in1 = $snmptemp -> {'.1.3.6.1.4.1.17409.1.11.3.0'};

 $uptime =~ s/......$//;
$device = 'EDFA';
$in1 = get_round($in1);
$outputP  = get_round( $outputP );


 }
 #------------------------------------------------------------------------------------------ 
#V1.1 2009/05/07
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.17409.1")
{
$id = 4;

#Выходной сигнал
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.11.2.0');
 $outputP = $snmptemp -> {'.1.3.6.1.4.1.17409.1.11.2.0'};

 #Аптайм
 my $snmptemp = $session -> get_request('.1.3.6.1.2.1.1.3.0');
  $uptime = $snmptemp -> {'.1.3.6.1.2.1.1.3.0'};
  #Вход
 my $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.11.3.0');
  $in1 = $snmptemp -> {'.1.3.6.1.4.1.17409.1.11.3.0'};


$device = 'V1.1 2009/05/07';
$in1 = get_round($in1);
$outputP  = get_round( $outputP );


 }
  #------------------------------------------------------------------------------------------ 
#
elsif ($result->{$snmp_oid} eq "")
{
$id = 5;

#Выходной сигнал
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.34652.99.11.12.0');
 $outputP = $snmptemp -> {'.1.3.6.1.4.1.34652.99.11.12.0'};

 #Аптайм
 my $snmptemp = $session -> get_request('.1.3.6.1.2.1.1.3.0');
  $uptime = $snmptemp -> {'.1.3.6.1.2.1.1.3.0'};
  #Вход
 my $snmptemp = $session -> get_request('.1.3.6.1.4.1.34652.99.11.12.0');
  $in1 = $snmptemp -> {'.1.3.6.1.4.1.34652.99.11.12.0'};



$in1 = get_round($in1);
$outputP  = get_round( $outputP );


 }
 #------------------------------------------------------------------------------------------ 
 #------------------------------------------------------------------------------------------ 
else 
{
print "<div class=\"layer\"><font size ='17pt'><center> <font color = 'red'>$line</font>  неизвестная модель.</font></div>";
print "</center>";
goto END;
}
 #------------------------------------------------------------------------------------------ 
  #------------------------------------------------------------------------------------------ 
   #------------------------------------------------------------------------------------------ 
GAVNO:
if ($gavno eq 'yes'){
my $result= `snmpwalk -v1 -c$community -Oxnqv $line $snmp_oid`;
$result =~ s/\s//;

 #------------------------------------------------------------------------------------------ 
#EauBs-A10.06
if ($result eq ".1.3.6.1.4.1.35702.3.5")
{
$id = 2;

#Выходной сигнал
 $outputP =get_snmpwalk('.1.3.6.1.4.1.35702.3.5.2.6.0');
 #Аптайм
  $uptime =`snmpwalk -v1 -c$community -Oxnv $line .1.3.6.1.2.1.1.3.0`;
   $uptime =~ s/Timeticks:\s\S+\s//;
  #Вход1
  $in1 =get_snmpwalk('.1.3.6.1.4.1.35702.3.5.2.2.0'); 
   #Вход 2
  $in2 =get_snmpwalk('.1.3.6.1.4.1.35702.3.5.2.3.0');

#Температура
  $temp = get_snmpwalk('.1.3.6.1.4.1.35702.3.5.2.10.0');

#девайс
  $device ='ТАРОС EAU-BS';

$in1 = get_round($in1);
$in2 = get_round($in2);
$outputP  = get_round( $outputP );
 $uptime =~ s/......$//;
$temp= get_round( $temp );
 }
  #------------------------------------------------------------------------------------------ 
#
elsif ($result eq "")
{
$id = 5;

#Выходной сигнал
$outputP = get_snmpwalk('.1.3.6.1.4.1.34652.99.11.2');


   #Аптайм
  $uptime = get_snmpwalk_array('.1.3.6.1.4.1.34652.99.11.12');
   $uptime =~ s/Timeticks:\s\S+\s//;
  #Вход
  $in1 =get_snmpwalk('.1.3.6.1.4.1.34652.99.11.1'); 
#Температура
  $temp = get_snmpwalk('.1.3.6.1.4.1.34652.99.11.11');
#девайс
  $device ='Volius';

$in1 = get_round($in1);
$outputP  = get_round( $outputP );
$temp= get_round( $temp );


 }
 #------------------------------------------------------------------------------------------ 
 #------------------------------------------------------------------------------------------

}
 #------------------------------------------------------------------------------------------ 
  #------------------------------------------------------------------------------------------ 
   #------------------------------------------------------------------------------------------ 
#print "<center>";
print "<center><br><h4>";




print " <div id=\"back\" >Вход 1: <font color='red'>   <b>$in1</font> </b>dBm <br>";
if ($id == 1 || $id == 2){
print " Вход 2: <font color='red'>   <b>$in2</font> </b>dBm <br>";
}
print "Выход: <font color='red'>   <b>$outputP</font> </b>dBm <br>";
if ($id == 1 || $id == 2|| $id == 5){
print " Температура: <font color='red'>   <b>$temp</font> </b>C <br>";
}
if ($id != 4 ){
print " Uptime: <font color='red'>   <b>$uptime</font> </b> <br>";
}
print"<br>";
print "<right><font color='white' style = 'background-color: #8A0829'>$device</font></right></div>";





#print "</center>";
print "</center></h4>";

END:
print "<div id=\"zyoma\">nnzimin\@mts.ru</div>";
print qq~

<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
</body>
</html>";
~;


$session->close();  

sub get_round {
my $value = shift;
if ( length $value == 4)
 {
 $value =~ s/(-\d\d)/$1\./;
 }
  if ( length $value == 3)
 {
 $value =~ s/(\d\d)/$1\./;
 }
    if ( length $value == 2)
 {
  if ($value =~ /-/){$value =~ s/(\d)/$1/;}
 else{$value =~ s/(\d)/$1\./;}
 }
 return $value;
}

 



sub get_snmpwalk {
my $oid = shift;
my $answer =`snmpwalk -v1 -c$community -Oxnqv $line $oid`;
$answer =~ s/\s$//;
return $answer;
}

sub get_snmpwalk_array {
my $oid = shift;
my @out = `snmpwalk -v1 -c$community -Oxnv $line $oid`;
my $answer = $out[0];
$answer =~ s/\s$//;
return $answer;
}
