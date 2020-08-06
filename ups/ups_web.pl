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
my $community = 'icomm';
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

print "Content-type: text/html\n\n";


print qq~

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
 <title> Данные с ИБП</title>
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

  <center><p>Выберите устройство ИБП.</p>
   <div id="wrapper">
  <form action="ups_web.pl" method="post" >
  
 
  <div class="form-row">
  <div class="col-auto">
  <select size="1" class="form-control" name='name' id="Select" style="float:left; width: 250px;"  >
    <option disabled>Выберите устройство</option>
	<option value="10.228.123.13">70 лет Октября 34</option>
	 <option value="10.228.123.8">40 лет Победы 43</option>
	  <option value="10.228.123.25">Аверкиева 6</option>
	   <option value="10.228.123.22">Благоева 48</option>
	
	<option value="10.228.123.46">Восточно Кругликовская 28/2 - УЭПС</option>
	<option value="10.228.123.47">Восточно Кругликовская 28/2 - Инвертор</option>
    <option value="10.228.123.40">Восточно Кругликовская 65</option>
    
	<option value="10.228.123.33">Героев Разведчиков 28</option>
	<option value="10.228.123.17">Генерала Трошева 33</option>
	 <option value="10.228.123.31">Душистая 49</option>
	  <option value="10.228.123.41">Зиповская 48</option>
	    <option value="10.228.123.4">Клубная 12а</option>

	<option value="10.228.123.9">Карла Маркса 14</option>
	
	 <option value="10.228.123.50">Казбекская 7 - УЭПС</option>
	 <option value="10.228.123.51">Казбекская 7 - Инвертор</option>

	  <option value="10.228.123.48">Котлярова 17 - УЭПС</option>
	  <option value="10.228.123.49">Котлярова 17 - Инвертор</option>
	  <option value="10.228.123.37">Кореновская 69</option>
	    <option value="10.228.123.45">Красных Партизан 248</option>
	  
	  <option value="10.228.123.52">Лукьяненко 95/2 - УЭПС</option>
	  <option value="10.228.123.44">Лукьяненко 95/2 - Инвертор</option>
	   
	    <option value="10.228.123.53">Есенина 131 - УЭПС</option>
		 <option value="10.228.123.54">Есенина 131 - Инвертор</option>
		
		   <option value="10.228.123.24">Невкипелого 15</option>
		    <option value="10.228.123.23">Игнатова 4</option>
			  <option value="10.228.123.21">Игнатова 35</option>
			   
	 <option value="10.228.123.32">Покрышкина 4/10</option>
	   <option value="10.228.123.6">Приозерная 13</option>
							<option value="10.228.123.10">Репина 20</option>
							
	<option value="10.228.123.28">Симферопольская 30/1 - не МУ</option>
	  <option value="10.228.123.7">Северная 279</option>
	 <option value="10.228.123.18">Сормовская 102</option>
	  <option value="10.228.123.15">Сормовская 185</option>
    <option value="10.228.123.43">Ставропольская 182</option>
	<option value="10.228.123.14">Ставропольская 258</option>
	 <option value="10.228.123.38">Старокубанская 121</option>
	 
	 <option value="10.228.123.20">Тюляева 37/1</option>
			     <option value="10.228.123.19">Тюляева 12</option>
 
				   <option value="10.228.123.11">Уральская 154/2</option>
				     <option value="10.228.123.16">Уральская 178</option>
					    <option value="10.228.123.12">Уральская 194</option>
						<option value="10.228.123.55">Яцкова 9/3</option>
						
						
						 <option disabled>Майкоп</option>
						 <option value="10.228.115.144">Димитрова 13</option>
						  <option value="10.228.115.151">Жуковского 31</option>
						   <option value="10.228.115.152">Жуковского 31</option>
						    <option value="10.228.115.145">Шоссейная 20</option>
							 <option value="10.228.115.143">Юннатов 24</option>
							
						
					     <option disabled>НОВОРОССИЙСК</option>
						 <option value="10.228.91.68">Анапское шоссе 41ж</option>
						  
						 <option value="10.228.91.69">Волгоградская 20</option>
						 <option value="ups-nvrsk-vidova109">Видова 109</option>
						 <option value="10.228.91.77">Видова 167</option>
						 
						  <option value="10.228.91.70">Десантников 24</option>
						  <option value="10.228.91.71">Десантников 65/1</option>
						  <option value="10.228.91.72">Куникова 9</option>
						  <option value="10.228.91.73">Кутузовская 117А</option>
						  <option value="10.228.91.86">Козлова 62 UPS 1</option>
		  <option value="10.228.91.87">Козлова 62 UPS 2</option>
		    <option value="10.228.91.88">Козлова 62 UPS 3</option>
			  <option value="10.228.91.89">Козлова 62 UPS 4</option>
			    <option value="10.228.91.90">Козлова 62 UPS 5</option>
				  <option value="10.228.91.91">Козлова 62 UPS 6</option>
				    <option value="10.228.91.93">Козлова 62 UPS 7</option>
					  <option value="10.228.91.94">Козлова 62 UPS 8</option>
						 
						   <option value="10.228.91.74">Ленина 103</option>
							 <option value="10.228.91.82">Набережная 9</option>
		<option value="10.228.91.78">Пионерская 39</option>
		<option value="10.228.91.75">Суворовская 2б</option>
		<option value="10.228.91.79">Южная 19</option>
							
						 <option value="10.228.91.86">12 мкр 37</option>
						  <option value="10.228.91.84">Ленина 131</option>
						 <option value="10.228.91.85">Ленина 179/3</option>
						 <option value="10.228.91.76">Парковая 62/б</option>
						 <option value="10.228.91.83">Краснозеленых 6</option>	
						  <option disabled>СОЧИ</option>
						 <option value="10.228.98.135">Конституции СССР 12</option> 
							
		 
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



print " <title> Данные с ИБП</title>";

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
my $treshold_bat;
if ($line eq '10.228.123.10'){ $treshold_bat = '';}
elsif ($line eq '10.228.123.4'){ $treshold_bat = '';}
elsif ($line eq '10.228.123.9'){ $treshold_bat = '';}
elsif ($line eq '10.228.123.7'){ $treshold_bat = '';}
elsif ($line eq '10.228.123.8'){ $treshold_bat = '';}
elsif ($line eq '10.228.123.13'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.25'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.22'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.42'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.40'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.33'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.31'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.30'){ $treshold_bat = 2500;}
elsif ($line eq '10.228.123.35'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.37'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.36'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.26'){ $treshold_bat = 760;}
elsif ($line eq '10.228.123.24'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.23'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.21'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.6'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.32'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.28'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.45'){ $treshold_bat = 240;}
elsif ($line eq '10.228.123.18'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.15'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.43'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.14'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.20'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.19'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.11'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.16'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.12'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.17'){ $treshold_bat = 535;}
elsif ($line eq '10.228.123.41'){ $treshold_bat = '';}
elsif ($line eq '10.228.123.44'){ $treshold_bat = '';}
elsif ($line eq '10.228.115.144'){ $treshold_bat = 535;}
elsif ($line eq '10.228.115.151'){ $treshold_bat = 535;}
elsif ($line eq '10.228.115.152'){ $treshold_bat = 535;}
elsif ($line eq '10.228.115.145'){ $treshold_bat = 535;}
elsif ($line eq '10.228.115.143'){ $treshold_bat = 535;}




if ($line eq '10.228.123.54'){ $tec_capacity = 200;}
elsif ($line eq '10.228.123.47'){ $tec_capacity = 80;}
elsif ($line eq '10.228.123.51'){ $tec_capacity = 80;}
elsif ($line eq '10.228.123.49'){ $tec_capacity = 80;}
elsif ($line eq '10.228.123.44'){ $tec_capacity = 80;}

#------------------------------------------------------------------------------------------------
my $alive = ping(hostname => "$line", count => 1,  timeout => 0.900);
 unless ($alive) {
 print "<div class=\"layer\"><font size ='17pt'><center> <font color = 'red'>$line</font>  не доступен.</font></div>";
print "</center>"; 
goto END;
}

	
if ($line eq '10.228.123.47' ) {$community = 'public';}	
if ($line eq '10.228.123.44' ) {$community = 'public';}	
if ($line eq '10.228.123.51' ) {$community = 'public';}	
if ($line eq '10.228.123.49' ) {$community = 'public';}	
if ($line eq '10.228.123.55' ) {$community = 'icomm_UPS';}

if ($line eq '10.228.123.54' ) {$community = 'public';}					
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
#print "$result->{$snmp_oid}";
#Delta
if ($result->{$snmp_oid} eq ".1.3.6.1.4.1.2254.2.4")
{
$id = 1;

#Входящее напряжение
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.4.3');
 $inputU = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.4.3'};
 if ( $inputU < 130) {$color = 'red';}
 $inputU =~ s/(\d\d\d)/$1\./;
 $inputU = "<font color=\'$color\'>$inputU</font>";
 
 
 #Заряд батарей
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.7.8');
 $capBat = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.7.8'};
 $color = 'green';
  if ( $capBat < 100) {$color = 'red';}
   $capBat = "<font color=\'$color\'>$capBat</font>";
 #Состояние 
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.7.1.0');
 $statusBat = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.7.1.0'};
 if ( $statusBat == 0){
 $statusBat = '<font color=\'green\'>Normal</font>';
 }
 elsif ($statusBat == 1){
 $statusBat = 'Weak';
 }
 elsif ($statusBat == 2){
 $statusBat = 'Need replace';
 }
 
   #Заряд батареи
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.7.2.0');
 $st1Bat = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.7.2.0'};
 if ( $st1Bat == 0){
 $st1Bat = '<font color=\'green\'>ok</font>';
 }
 elsif ($st1Bat == 1){
 $st1Bat = 'низкий';
 }
 elsif ($st1Bat == 2){
 $st1Bat = 'очень низкий';
 }
 
    #Выход источника
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.5.1.0');
 $soursOut = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.5.1.0'};
 if ( $soursOut == 0){
 $soursOut = '<font color=\'green\'>normal</font>';
 }
 elsif ($soursOut == 1){
 $soursOut = 'battery';
 }
 elsif ($soursOut == 2){
 $soursOut = 'bypass';
 }
  elsif ($soursOut == 3){
 $soursOut = 'reducing';
 }
  elsif ($soursOut == 4){
 $soursOut = 'boosting';
 }
  elsif ($soursOut == 5){
 $soursOut = 'manualBypass';
 }
   elsif ($soursOut == 6){
 $soursOut = 'other';
 }
   elsif ($soursOut == 7){
 $soursOut = 'none';
 }
 
 
  #Статус батареи
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.7.3.0');
 $stBat = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.7.3.0'};
 if ( $stBat == 0){
 $stBat = 'floating';
 }
 elsif ($stBat == 1){
 $stBat = '<font color=\'green\'>зарядка</font>';
 }
 elsif ($stBat == 2){
 $stBat = '<font color=\'green\'>отдых</font>';
 }
 elsif ($stBat == 3){
 $stBat = 'разрядка';
 }
 
  #Число батарейных модулей
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.3.8');
 $modul = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.3.8'};
 #if ($modul == 0) {$modul =1;}
 $color = 'green';
 
 $modul = "<font color=\'$color\'>$modul</font>";
 
   #Дата последней замены
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.7.10');
 $lastdata = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.7.10'};
 
 $lastdata  =~ s/(\d\d\d\d)(\d\d)(\d\d)/$3.$2.$1/;
 
 
   #Планируемая дата замены
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.7.11');
 $nextdata = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.7.11'};

  $nextdata  =~ s/(\d\d\d\d)(\d\d)(\d\d)/$3.$2.$1/;

 
 #Температура
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.7.9.0');
 $temper = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.7.9.0'};
 $color = 'green';
 if ( $temper > 50) {$color = 'red';}
 $temper = "<font color=\'$color\'>$temper</font>";
  #Входная частота
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.4.2.0');
 $inCz = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.4.2.0'};
 $color = 'green';
 if ( $inCz < 499) {$color = 'red';}
 $inCz  =~ s/(\d\d)/$1\./;
 $inCz = "<font color=\'$color\'>$inCz</font>";
  #Выход источника
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.5.1.0');
 $outIst = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.5.1.0'};
 
  #Выходная мощность
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.5.6.0');
 $outPower = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.5.6.0'};
 $color = 'green';
 if ( $outPower > 1600) {$color = 'red';}
   $outPower = "<font color=\'$color\'>$outPower</font>";
 
  #Выходная частота
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.5.2.0');
 $outCz = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.5.2.0'};
 $color = 'green';
  if ( $outCz < 499) {$color = 'red';}
   
$outCz  =~ s/(\d\d)/$1\./;
$outCz = "<font color=\'$color\'>$outCz</font>";
  #Выходное напряжение
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.5.4.0');
 $outputU = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.5.4.0'};
 $color = 'green';
 if ( $outputU < 180) {$color = 'red';}
 $outputU =~ s/(\d\d\d)/$1\./;
 $outputU = "<font color=\'$color\'>$outputU</font>";
  #Выходной ток
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.5.5.0');
 $outI = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.5.5.0'};
 $color = 'green';
 if ( $outI > 70) {$color = 'red';}
   if ( $outI == 0)
 {

 }
   else
 {
       if ( length $outI == 2)
       {
        $outI =~ s/(\d)(\d)/$1\.$2/;
       }
	   elsif ( length $outI == 1)
       {
        $outI =~ s/(\d+)/0\.$1/;
       }
	   
 
 }
 $outI = "<font color=\'$color\'>$outI</font>";
 
  #Напряжение батареи
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.7.6.0');
 $batareU = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.7.6.0'};
 $color = 'green';
 if ( $batareU < $treshold_bat) {$color = 'red';}
   if ( length $batareU == 3)
 {
 $batareU =~ s/(\d\d)/$1\./;
 }
    if ( length $batareU == 4)
 {
 $batareU =~ s/(\d\d\d)/$1\./;
 }
 $batareU = "<font color=\'$color\'>$batareU</font>";
 
  #Время работы от батареи
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.7.5.0');
 $batareTime = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.7.5.0'};
 $color = 'green';
 $batareTime = "<font color=\'$color\'>$batareTime</font>";
 
    #Уровень нагрузки
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.2254.2.4.5.7.0');
 $nag = $snmptemp -> {'.1.3.6.1.4.1.2254.2.4.5.7.0'};
 $color = 'green';
  if ( $nag > 90) {$color = 'red';}
 
 $nag = "<font color=\'$color\'>$nag</font>";
 #Мощность байпаса
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.6.5.0');
 $powerBay = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.6.5.0'};
 $color = 'green';
  if ( $powerBay > 1600) {$color = 'red';}
 $powerBay = "<font color=\'$color\'>$powerBay</font>";
 
  #Напряжение байпаса
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.6.3.0');
 $uBay = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.6.3.0'};
  $color = 'green';
  if ( $uBay < 180) {$color = 'red';}
  $uBay =~ s/(\d\d\d)/$1\./;
  $uBay = "<font color=\'$color\'>$uBay</font>";
 
   #Частота байпаса
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.6.1.0');
 $czBay = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.6.1.0'};
 $color = 'green';
  if ( $czBay < 499) {$color = 'red';}
  $czBay  =~ s/(\d\d)/$1\./;
  $czBay = "<font color=\'$color\'>$czBay</font>";
 
   #Ток байпаса
my $snmptemp = $session -> get_request('1.3.6.1.4.1.2254.2.4.6.4.0');
 $iBay = $snmptemp -> {'1.3.6.1.4.1.2254.2.4.6.4.0'};
  $color = 'green';
  if ( $iBay < 0) {$color = 'red';}
   $iBay = "<font color=\'$color\'>$iBay</font>";
$device = "Delta";

}
#Enelt PRO
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.935")
{
$id = 2;

  #Заряд батареи
my $snmptemp = $session -> get_request('1.3.6.1.2.1.33.1.2.1.0');
 $stBat = $snmptemp -> {'1.3.6.1.2.1.33.1.2.1.0'};
 if ( $stBat == 1){
 $stBat = 'unknown';
 }
 elsif ($stBat == 2){
 $stBat = '<font color=\'green\'>Normal</font>';
 }
 elsif ($stBat == 3){
 $stBat = 'низкий';
 }
 elsif ($stBat == 4){
 $stBat = 'очень низкий';
 }
 
  #Состояние
my $snmptemp = $session -> get_request('1.3.6.1.2.1.33.1.4.1.0');
 $statusBat = $snmptemp -> {'1.3.6.1.2.1.33.1.4.1.0'};
 if ( $statusBat == 1){
 $statusBat = 'other';
 }
 elsif ($statusBat == 2){
 $statusBat = 'none';
 }
 elsif ($statusBat == 3){
 $statusBat = '<font color=\'green\'>normal</font>';
 }
  elsif ($statusBat == 4){
 $statusBat = 'bypass';
 }
  elsif ($statusBat == 5){
 $statusBat = 'battery';
 }
  elsif ($statusBat == 6){
 $statusBat = 'booster';
 }
  elsif ($statusBat == 7){
 $statusBat = 'reducer';
 }
#Входящее напряжение
my $snmptemp = $session -> get_request('1.3.6.1.2.1.33.1.3.3.1.3');
 $inputU = $snmptemp -> {'1.3.6.1.2.1.33.1.3.3.1.3'};
 $color = 'green';
 if ( $inputU < 130) {$color = 'red';}
 $inputU = "<font color=\'$color\'>$inputU</font>";
 
   #Напряжение батареи
my $snmptemp = $session -> get_request('1.3.6.1.2.1.33.1.2.5.0');
 $batareU = $snmptemp -> {'1.3.6.1.2.1.33.1.2.5.0'};
 $color = 'green';
 if ( $batareU < $treshold_bat) {$color = 'red';}
   if ( length $batareU == 3)
 {
 $batareU =~ s/(\d\d)/$1\./;
 }
    if ( length $batareU == 4)
 {
 $batareU =~ s/(\d\d\d)/$1\./;
 }
 $batareU = "<font color=\'$color\'>$batareU</font>";
 
  #Уровень нагрузки
my $snmptemp = $session -> get_request('.1.3.6.1.2.1.33.1.4.4.1.5');
 $nag = $snmptemp -> {'.1.3.6.1.2.1.33.1.4.4.1.5'};
 $color = 'green';
  if ( $nag > 90) {$color = 'red';}
 
 $nag = "<font color=\'$color\'>$nag</font>";
 
   #Выходное напряжение
my $snmptemp = $session -> get_request('1.3.6.1.2.1.33.1.4.4.1.2');
 $outputU = $snmptemp -> {'1.3.6.1.2.1.33.1.4.4.1.2'};
 $color = 'green';
 if ( $outputU < 180) {$color = 'red';}

 $outputU = "<font color=\'$color\'>$outputU</font>";

  #Входная частота
my $snmptemp = $session -> get_request('1.3.6.1.2.1.33.1.3.3.1.2');
 $inCz = $snmptemp -> {'1.3.6.1.2.1.33.1.3.3.1.2'};
 $color = 'green';
 if ( $inCz < 499) {$color = 'red';}
 $inCz  =~ s/(\d\d)/$1\./;
 $inCz = "<font color=\'$color\'>$inCz</font>";

 
   #Выходная частота
my $snmptemp = $session -> get_request('1.3.6.1.2.1.33.1.4.2.0');
 $outCz = $snmptemp -> {'1.3.6.1.2.1.33.1.4.2.0'};

 $color = 'green';
  if ( $outCz < 499) {$color = 'red';}
  $outCz  =~ s/(\d\d)/$1\./;
$outCz = "<font color=\'$color\'>$outCz</font>";

 #Мощность байпаса
my $snmptemp = $session -> get_request('1.3.6.1.2.1.33.1.5.3.1.4');
 $powerBay = $snmptemp -> {'1.3.6.1.2.1.33.1.5.3.1.4'};
  $color = 'green';
  if ( $powerBay > 1600) {$color = 'red';}
 $powerBay = "<font color=\'$color\'>$powerBay</font>";
 
  #Температура
my $snmptemp = $session -> get_request('1.3.6.1.2.1.33.1.2.7.0');
 $temper = $snmptemp -> {'1.3.6.1.2.1.33.1.2.7.0'};
 $color = 'green';
 if ( $temper > 50) {$color = 'red';}
 $temper = "<font color=\'$color\'>$temper</font>";
 
  #Выходная мощность
my $snmptemp = $session -> get_request('1.3.6.1.2.1.33.1.4.4.1.4');
 $outPower = $snmptemp -> {'1.3.6.1.2.1.33.1.4.4.1.4'};
  $color = 'green';
 if ( $outPower > 1600) {$color = 'red';}
   $outPower = "<font color=\'$color\'>$outPower</font>";
 #Заряд батарей

 
 my %snmplldpnei_hash = %{$session -> get_table("1.3.6.1.2.1.33.1.2.4")};
	foreach my $snmptemp (keys %snmplldpnei_hash)
	{
		$capBat = $snmplldpnei_hash{$snmptemp};
	}
$color = 'green';
  if ( $capBat < 100) {$color = 'red';}
   $capBat = "<font color=\'$color\'>$capBat</font>";
$device = "Enelt PRO";

}

#"Emerson
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.6302.2.1")
{
$id = 3;
$device = "Emerson";

  #Статус батареи
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.6302.2.1.2.1.0');
 $stBat = $snmptemp -> {'.1.3.6.1.4.1.6302.2.1.2.1.0'};
 if ( $stBat == 1){
 $stBat = 'unknown';
 }
 elsif ($stBat == 2){
 $stBat = ' <font color=\'green\'>normal</font>';
 }
 elsif ($stBat == 3){
 $stBat = 'observation';
 }
 elsif ($stBat == 4){
 $stBat = 'warning';
 }
 elsif ($stBat == 5){
 $stBat = 'minor';
 }
 elsif ($stBat == 6){
 $stBat = ' major';
 }
 elsif ($stBat == 7){
 $stBat = 'unmanaged';
 }
 elsif ($stBat == 8){
 $stBat = 'restricted';
 }
 elsif ($stBat == 9){
 $stBat = ' testing';
 }
 elsif ($stBat == 10){
 $stBat = 'disabled';
 }
#Входящее напряжение 1
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.6302.2.1.2.6.1.0');
 $inputU1 = $snmptemp -> {'.1.3.6.1.4.1.6302.2.1.2.6.1.0'};
 $color = 'green';
  if ( $inputU1 < 180000) {$color = 'red';}
 $inputU1 =~ s/(\d\d\d)(.).+/$1\.$2/;
   $inputU1 = "<font color=\'$color\'>$inputU1</font>";
 
 #Входящее напряжение 2
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.6302.2.1.2.6.2.0');
 $inputU2 = $snmptemp -> {'.1.3.6.1.4.1.6302.2.1.2.6.2.0'};
  $color = 'green';
  if ( $inputU2 < 180000) {$color = 'red';}
 $inputU2 =~ s/(\d\d\d)(.).+/$1\.$2/;
 $inputU2 = "<font color=\'$color\'>$inputU2</font>";
 
 #Входящее напряжение 3
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.6302.2.1.2.6.3.0');
 $inputU3 = $snmptemp -> {'.1.3.6.1.4.1.6302.2.1.2.6.3.0'};
  $color = 'green';
  if ( $inputU3 < 180000) {$color = 'red';}
 $inputU3 =~ s/(\d\d\d)(.).+/$1\.$2/;
 $inputU3 = "<font color=\'$color\'>$inputU3</font>";
 
 #Заряд батарей
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.6302.2.1.2.5.3.0');
 $capBat = $snmptemp -> {'.1.3.6.1.4.1.6302.2.1.2.5.3.0'};
   $color = 'green';
  if ( $capBat < 100000) {$color = 'red';}
  if ( length $capBat == 5)
 {
 $capBat =~ s/(..)(.).+/$1.$2/;
 }
   elsif ( length $capBat == 4)
 {
 $capBat =~ s/(.)(.).+/$1.$2/;
 }
 else
 {
 $capBat =~ s/(...)(.).+/$1.$2/;
 }
 $capBat = "<font color=\'$color\'>$capBat</font>";
 
 #Температура
my $snmptemp = $session -> get_request('1.3.6.1.4.1.6302.2.1.2.7.1.0');
 $temper = $snmptemp -> {'1.3.6.1.4.1.6302.2.1.2.7.1.0'};
  $color = 'green';
  if ( $temper > 50000) {$color = 'red';}
 $temper =~ s/(..)(.).+/$1.$2/;
 $temper = "<font color=\'$color\'>$temper</font>";
   #Выходное напряжение
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.6302.2.1.2.2.0');
 $outputU = $snmptemp -> {'.1.3.6.1.4.1.6302.2.1.2.2.0'};
   $color = 'green';
  if ( $outputU < 54000) {$color = 'red';}
 $outputU =~ s/(\d\d)(.).+/$1\.$2/;
 $outputU = "<font color=\'$color\'>$outputU</font>";
   #Выходной ток
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.6302.2.1.2.3.0');
 $outI = $snmptemp -> {'.1.3.6.1.4.1.6302.2.1.2.3.0'};
    $color = 'green';
  if ( $outI > 70000) {$color = 'red';}
 $outI =~ s/(..)(.).+/$1.$2/;
  $outI = "<font color=\'$color\'>$outI</font>";
    #Уровень нагрузки
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.6302.2.1.2.4.0');
 $nag = $snmptemp -> {'.1.3.6.1.4.1.6302.2.1.2.4.0'};
    $color = 'green';
  if ( $nag > 30) {$color = 'red';}
 $nag =~ s/(..)(.).+/$1.$2/;
   $nag = "<font color=\'$color\'>$nag</font>";
}

#Huawei
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.8072.3.2.10")
{
$device = "Huawei";
$id = 4;
#Входящее напряжение
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.2011.6.174.1.3.100.1.1.1');
 $inputU = $snmptemp -> {'.1.3.6.1.4.1.2011.6.174.1.3.100.1.1.1'};
 $inputU =~ s/(\d\d\d)/$1\./;
 
 #Температура
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.2011.6.174.1.2.101.1.4.1');
 $temper = $snmptemp -> {'.1.3.6.1.4.1.2011.6.174.1.2.101.1.4.1'};
 $temper =~ s/(..)(.)/$1.$2/;
 
   #Входная частота
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.2011.6.174.1.3.100.1.4.1');
 $inCz = $snmptemp -> {'.1.3.6.1.4.1.2011.6.174.1.3.100.1.4.1'};
 $inCz  =~ s/(\d\d)/$1\./;
 
    #Выходное напряжение
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.2011.6.174.1.4.100.1.1.1');
 $outputU = $snmptemp -> {'.1.3.6.1.4.1.2011.6.174.1.4.100.1.1.1'};
 $outputU =~ s/(\d\d\d)(.)/$1\.$2/;
 
    #Выходная частота
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.2011.6.174.1.4.100.1.7.1');
 $outCz = $snmptemp -> {'.1.3.6.1.4.1.2011.6.174.1.4.100.1.7.1'};
$outCz  =~ s/(\d\d)/$1\./;

  #Выходной ток
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.2011.6.174.1.4.100.1.4.1');
 $outI = $snmptemp -> {'.1.3.6.1.4.1.2011.6.174.1.4.100.1.4.1'};
   if ( $outI == 0)
   
 {

 }
   else
 {
 $outI =~ s/(\d+)/0\.$1/;
 }
 
   #Напряжение байпаса
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.2011.6.174.1.5.100.1.1.1');
 $uBay = $snmptemp -> {'.1.3.6.1.4.1.2011.6.174.1.5.100.1.1.1'};
  $uBay =~ s/(\d\d\d)/$1\./;
  
     #Частота байпаса
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.2011.6.174.1.5.100.1.4.1');
 $czBay = $snmptemp -> {'.1.3.6.1.4.1.2011.6.174.1.5.100.1.4.1'};
  $czBay  =~ s/(\d\d)/$1\./;

 
   #Напряжение батареи
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.2011.6.174.1.6.100.1.1.1');
 $batareU = $snmptemp -> {'.1.3.6.1.4.1.2011.6.174.1.6.100.1.1.1'};
 
   if ( length $batareU == 3)
 {
 $batareU =~ s/(\d\d)/$1\./;
 }
    if ( length $batareU == 4)
 {
 $batareU =~ s/(\d\d\d)/$1\./;
 }
 
  #Время работы от батареи
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.2011.6.174.1.6.100.1.4.1');
 $batareTime = $snmptemp -> {'.1.3.6.1.4.1.2011.6.174.1.6.100.1.4.1'};
 $batareTime = $batareTime / 60;
 $batareTime=~ s/(\d+\.\d\d)\d+/$1/;

 
    #Уровень нагрузки
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.2011.6.174.1.4.100.1.14.1');
 $nag = $snmptemp -> {'.1.3.6.1.4.1.2011.6.174.1.4.100.1.14.1'};
  #Заряд батарей
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.2011.6.174.1.6.100.1.3.1');
 $capBat = $snmptemp -> {'.1.3.6.1.4.1.2011.6.174.1.6.100.1.3.1'};
 
   #Выходная мощность
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.2011.6.174.1.4.100.1.11.1');
 $outPower = $snmptemp -> {'.1.3.6.1.4.1.2011.6.174.1.4.100.1.11.1'};
}


#"Comet EX 11RT31
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.705.1.2")
{
$id = 5;
$device = "Comet EX 11RT31";

#Входящее напряжение
 $inputU = getSnmp('.1.3.6.1.4.1.705.1.6.2.1.2');
   $inputU =~ s/(\d\d\d)/$1\./;
 $capBat= getSnmp('.1.3.6.1.4.1.705.1.5.2');
 $outputU= getSnmp('1.3.6.1.4.1.705.1.7.2.1.2');
 $outputU =~ s/(\d\d\d)/$1\./;
 $inCz= getSnmp('.1.3.6.1.4.1.705.1.6.2.1.3');
 $inCz =~ s/(\d\d)/$1\./;
 $outCz= getSnmp('1.3.6.1.4.1.705.1.7.2.1.3');
 $outCz =~ s/(\d\d)/$1\./;
 $outI= getSnmp('1.3.6.1.4.1.705.1.7.2.1.5');
  $outI =~ s/(\d+)/0\.$1/;
 $statusBat= getSnmp('1.3.6.1.4.1.705.1.7.3');
    if ($statusBat== 1){$statusBat ='от батареи';}else{$statusBat ='<font color=\'green\'>от сети</font>';}
	$stBat= getSnmp('1.3.6.1.4.1.705.1.7.4');
    if ($stBat== 1){$statusBat ='байпас';}else{$stBat ='<font color=\'green\'>ок</font>';}
	$nag= getSnmp('1.3.6.1.4.1.705.1.7.2.1.4');
	#Время работы от батареи

 $batareTime= getSnmp('.1.3.6.1.4.1.705.1.5.1');
 $batareTime = $batareTime / 60;
 $batareTime=~ s/(\d+\.\d\d)\d+/$1/;
	
	   #Напряжение батареи

 $batareU= getSnmp('.1.3.6.1.4.1.705.1.5.5');
   if ( length $batareU == 3)
 {
 $batareU =~ s/(\d\d)/$1\./;
 }
    if ( length $batareU == 4)
 {
 $batareU =~ s/(\d\d)/$1\./;
 }
 }
 
 #Tehnoliga
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.12980.1")
{
$id = 6;
$device = "Tehnoliga";

#Напряжение инвертора
 my $snmptemp = $session -> get_request('.1.3.6.1.4.1.12980.10.2.1.1.2.1');
  $outputU = $snmptemp -> {'.1.3.6.1.4.1.12980.10.2.1.1.2.1'};
 
 #Напряжение сети
  my $snmptemp = $session -> get_request('.1.3.6.1.4.1.12980.10.2.1.1.3.1');
  $inputU = $snmptemp -> {'.1.3.6.1.4.1.12980.10.2.1.1.3.1'};
   if ( $inputU  == 0){
  $inputU  = '<font color=\'red\'>0</font>';
 }
   
 #Ток Инвертора
   my $snmptemp = $session -> get_request('.1.3.6.1.4.1.12980.10.2.1.1.4.1');
  $outI = $snmptemp -> {'.1.3.6.1.4.1.12980.10.2.1.1.4.1'};
 
  #Ток сети
    my $snmptemp = $session -> get_request('.1.3.6.1.4.1.12980.10.2.1.1.5.1');
 $inI = $snmptemp -> {'.1.3.6.1.4.1.12980.10.2.1.1.5.1'};
 
   #Частота инвертора
    my $snmptemp = $session -> get_request('.1.3.6.1.4.1.12980.10.2.1.1.6.1');
$outCz = $snmptemp -> {'.1.3.6.1.4.1.12980.10.2.1.1.6.1'};

   #Частота сети
     my $snmptemp = $session -> get_request('.1.3.6.1.4.1.12980.10.2.1.1.7.1');
 $inCz = $snmptemp -> {'.1.3.6.1.4.1.12980.10.2.1.1.7.1'};
 
    #Температура
      my $snmptemp = $session -> get_request('.1.3.6.1.4.1.12980.10.2.1.1.8.1');
 $temper = $snmptemp -> {'.1.3.6.1.4.1.12980.10.2.1.1.8.1'};

 #Состояние
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.12980.10.2.1.1.9.1');
 $statusBat = $snmptemp -> {'.1.3.6.1.4.1.12980.10.2.1.1.9.1'};
 if ( $statusBat == 1){
 $statusBat = 'Normal';
 }
 elsif ($statusBat == 2){
 $statusBat = '<font color=\'red\'>напряжение сети ниже нормы</font>';
 }
 elsif ($statusBat == 3){
 $statusBat = '<font color=\'red\'>перегрузка</font>';
 }
  elsif ($statusBat == 4){
 $statusBat = '<font color=\'red\'>тревога</font>';
 }
 
  #Состояние байпаса
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.12980.10.2.1.1.10.1');
$stBat = $snmptemp -> {'.1.3.6.1.4.1.12980.10.2.1.1.10.1'};
 if ( $stBat == 1){
 $stBat = '<font color=\'red\'>off</font>';
 }
 elsif ($stBat == 2){
 $stBat= '<font color=\'red\'>invertor</font>';
 }
 elsif ($stBat == 3){
 $stBat = 'net';
 }
  elsif ($stBat == 4){
 $stBat = '<font color=\'red\'>unknow</font>';
 }

 #Расчет времени бекапа
 $time_beckup = $tec_capacity / (($outputU * $outI / 1000)/ 48 );
 $time_beckup = sprintf("%.02f", $time_beckup);
 
 }
 #------------------------------------------------------------------------------------------
 
 elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.25728")
{
$id = 7;
$device = "УЭПС";

  #Вход 1
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.25728.8900.1.1.2.1');
$line1 = $snmptemp -> {'.1.3.6.1.4.1.25728.8900.1.1.2.1'};
  #Вход 2
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.25728.8900.1.1.2.2');
$line2 = $snmptemp -> {'.1.3.6.1.4.1.25728.8900.1.1.2.2'};
  #Вход 3
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.25728.8900.1.1.2.3');
$line3 = $snmptemp -> {'.1.3.6.1.4.1.25728.8900.1.1.2.3'};
  #Вход 4
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.25728.8900.1.1.2.4');
$line4 = $snmptemp -> {'.1.3.6.1.4.1.25728.8900.1.1.2.4'};

if ($line4 == 0 ) {$line4 = "<font color=\'red\'>Авария сети</font>";} else {$line4 ="Ok";}
if ($line3 == 0 ) {$line3 = "<font color=\'red\'>Батареи разряжены</font>";} else {$line3 ="Ок";}
if ($line2 == 0 ) {$line2 = "<font color=\'red\'>Авария!</font>";} else {$line2 ="Аварий нет";}
if ($line1 == 0 ) {$line1 = "<font color=\'red\'>Авария!</font>";} else {$line1 ="Аварий нет";}

}
 #------------------------------------------------------------------------------------------ 
else 
{
print "<div class=\"layer\"><font size ='17pt'><center> <font color = 'red'>$line</font>  неизвестная модель ИБП.</font></div>";
print "</center>";
goto END;
}



#print "<center>";
print "<center><br><h4>";


if ($id == 3) {
print "<div id=\"back\" >Входное напряжение А: <font color='red'><b>$inputU1</font> V</b><br>";
print "Входное напряжение Б: <font color='red'><b>$inputU2</font> V</b><br> ";
print "Входное напряжение С: <font color='red'><b>$inputU3</font> V</b><br> ";


print "Заряд батарей: <font color='red'><b>$capBat</font> %</b><br>";
print "Выходной ток: <font color='red'><b>$outI</font> A</b><br>  ";
print "Выходное напряжение: <font color='red'><b>$outputU</font> V</b> <br>";
print "Температура: <font color='red'><b>$temper</font> С</b><br> ";
print "Уровень нагрузки: <font color='red'><b>$nag</font> %</b><br> ";
print "Статус ЭПУ: <font color='red'><b>$stBat</font> </b><br><br>";


  print "<right><font color='white' style = 'background-color: #8A0829'>$device</font></right></div>";
}
if ($id == 1) {
print " <div id=\"back\" >Состояние: <font color='red'>   <b>$statusBat</font> </b> <br>";
print "Выход источника: <font color='red'>   <b>$soursOut</font> </b><br>";


print "Заряд батарей:<font color='red'>   <b>$st1Bat</font> </b><br> ";
print "Статус батарей: <font color='red'>   <b>$stBat</font> </b><br> ";
print "Заряд батарей: <font color='red'>   <b>$capBat</font> %</b><br>";
print "Время работы от батареи:<font color='red'>   <b>$batareTime</font> Min</b> <br>";
print "Напряжение батареи: <font color='red'>   <b>$batareU</font> V</b> <br>";


#print "Батареи заменены:    <b>$lastdata </b><br> ";
#print "Планируется:    <b>$nextdata </b><br> ";

print "Входное напряжение: <font color='red'>   <b>$inputU</font> V</b><br> ";
print "Входная частота: <font color='red'>   <b>$inCz</font> Hz</b> <br>";

print "Выходное напряжение: <font color='red'>   <b>$outputU</font> V</b> <br>";
print "Выходная частота: <font color='red'>   <b>$outCz</font> Hz</b><br> ";
print "Выходной ток: <font color='red'>   <b>$outI</font> A</b><br>  ";
print "Выходная мощность: <font color='red'>   <b>$outPower</font> W</b> <br>";




print "Мощность байпаса: <font color='red'>   <b>$powerBay</font> W</b><br> ";
print "Напряжение байпаса: <font color='red'>   <b>$uBay</font> V</b> <br>";
print "Частота байпаса: <font color='red'>   <b>$czBay</font> Hz</b> <br>";
print "Ток байпаса: <font color='red'>   <b>$iBay</font> A</b> <br>";
print "Температура: <font color='red'>   <b>$temper</font> С</b><br> ";
print "Уровень нагрузки: <font color='red'>   <b>$nag</font> %</b> <br>";
print "<span style=\"float:left;\">Число батарейных модулей:    <b>$modul  </b> </span>";
print qq~
<span style=\"float:right;\">
  <form action="modul_ups.pl" method="post"  target="area" >

  <select  name='name2' id="Select2" >
   <option disabled selected value> - </option>
   <option value="0.$line">0</option>
	<option value="1.$line">1</option>
	<option value="2.$line">2</option>
	<option value="3.$line">3</option>
	<option value="4.$line">4</option>
	 </select>
	 
    <input type="image" src="save.jpg" width = '20' height = '20' >
	
  </form></span>
  <br><br>
	
~;
print "<span style=\"float:right;\"><iframe name=\"area\" width=\"40\"  height=\"50\"  frameborder=\"0\" allowtransparency ></iframe></span>";
print "<right><font color='white' style = 'background-color: #8A0829'>$device</font></right></div>";






}
if ($id == 2) {
print "<div id=\"back3\">Состояние: <font color='red'>   <b>$statusBat</font> </b> <br>";
print "Статус батарей: <font color='red'>   <b>$stBat</font> </b><br> ";
print "Входное напряжение: <font color='red'>   <b>$inputU</font> V</b><br> ";
print "Выходное напряжение: <font color='red'>   <b>$outputU</font> V</b> <br>";
print "Заряд батарей: <font color='red'>   <b>$capBat</font> %</b> <br>";


print "Входная частота: <font color='red'>   <b>$inCz</font> Hz</b> <br>";
print "Выходная частота: <font color='red'>   <b>$outCz</font> Hz</b><br> ";


print "Уровень нагрузки: <font color='red'>   <b>$nag</font> %</b> <br>";

print "Мощность байпаса: <font color='red'>   <b>$powerBay</font> W</b><br> ";




print "Выходная мощность: <font color='red'>   <b>$outPower</font> W</b> <br>";

#print "Напряжение батареи: <font color='red'>   <b>$batareU</font> V</b> <br>";
print "Температура: <font color='red'>   <b>$temper</font> С</b><br><br> ";
print "<right><font color='white' style = 'background-color: #8A0829'>$device</font></right>";


  }
  if ($id == 4) {

print "<div id=\"back3\">Входное напряжение: <font color='green'>   <b>$inputU</font> V</b><br> ";
print "Выходное напряжение: <font color='green'>   <b>$outputU</font> V</b> <br>";
print "Заряд батарей: <font color='green'>   <b>$capBat</font> %</b> <br>";
print "Время работы от батареи: <font color='green'>   <b>$batareTime</font> Min</b> <br>";

print "Входная частота: <font color='green'>   <b>$inCz</font> Hz</b> <br>";
print "Выходная частота: <font color='green'>   <b>$outCz</font> Hz</b><br> ";

print "Температура: <font color='green'>   <b>$temper</font> С</b><br> ";
print "Уровень нагрузки: <font color='green'>   <b>$nag</font> %</b> <br>";


print "Напряжение байпаса: <font color='green'>   <b>$uBay</font> V</b> <br>";

print "Частота байпаса: <font color='green'>   <b>$czBay</font> Hz</b> <br>";


print "Выходной ток: <font color='green'>   <b>$outI</font> A</b><br>  ";
print "Выходная мощность: <font color='green'>   <b>$outPower</font> W</b> <br>";

print "Напряжение батареи: <font color='green'>   <b>$batareU</font> V</b> <br><br>";
print "<right><font color='white' style = 'background-color: #8A0829'>$device</font></right>";


}

  if ($id == 5) {
print "<div id=\"back3\">Состояние: <font color='red'>   <b>$statusBat</font> </b> <br>";
print "Статус батарей: <font color='red'>   <b>$stBat</font> </b><br> ";
print "Входное напряжение: <font color='red'>   <b>$inputU</font> V</b><br> ";
print "Выходное напряжение: <font color='red'>   <b>$outputU</font> V</b> <br>";
print "Выходной ток: <font color='red'>   <b>$outI</font> A</b><br>  ";
print "Заряд батарей: <font color='red'>   <b>$capBat</font> %</b> <br>";
print "Входная частота: <font color='red'>   <b>$inCz</font> Hz</b> <br>";
print "Выходная частота: <font color='red'>   <b>$outCz</font> Hz</b><br> ";
print "Уровень нагрузки: <font color='red'>   <b>$nag</font> %</b> <br>";
print "Время работы от батареи: <font color='red'>   <b>$batareTime</font> Min</b> <br>";
print "Напряжение батареи: <font color='red'>   <b>$batareU</font> V</b> <br>";
print "<br><right><font color='white' style = 'background-color: #8A0829'>$device</font></right>";


}

  if ($id == 6) {
print "<div id=\"back3\">Состояние: <font color='green'>   <b>$statusBat</font> </b> <br>";
print "Статус байпаса: <font color='green'>   <b>$stBat</font> </b><br> ";
print "Напряжение инвертора: <font color='green'>   <b>$outputU</font> V</b> <br>";
print "Напряжение сети: <font color='green'>   <b>$inputU</font> V</b><br> ";
print "Ток инвертора: <font color='green'>   <b>$outI</font> mA</b><br>  ";
print "Ток сети: <font color='green'>   <b>$inI</font> mA</b><br>  ";
print "Частота инвертора: <font color='green'>   <b>$outCz</font> Hz</b> <br>";
print "Частота сети: <font color='green'>   <b>$inCz</font> Hz</b><br> ";
print "Температура: <font color='green'>   <b>$temper</font> C</b> <br>";
print "Время резерва: <b><font color='green'> $time_beckup </font>ч.</b><br>";

print "<br><right><font color='white' style = 'background-color: #8A0829'>$device</font></right>";


}

  if ($id == 7) {
print "<div id=\"back3\">Авария 1 степени: <font color='green'>   <b>$line1</font> </b> <br>";
print "Авария 2 степени: <font color='green'>   <b>$line2</font></b><br> ";
print "Статус батарей: <font color='green'>   <b>$line3</font></b><br> ";
print "Статус сети: <font color='green'>   <b>$line4</font></b><br> ";

print "
<br><br>
<div class=\"alert alert-danger\" role=\"alert\"> <h5>
<i><u><b>Авария 1 степени:</b></u></i>&nbsp;&nbsp;-Больше 1 выпрямителя <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-Авария батарейной группы №1 или № 2
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-Отключение батарей
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -Батарея разряжена<br>
<br><i><u><b>Авария 2 степени:</b></u></i> &nbsp;&nbsp;-Авария сети
 <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-Авария нагрузочных автоматов

 <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-Повышенное или пониженное напряжение.</h5>

</div>
";
print "<br><right><font color='white' style = 'background-color: #8A0829'>$device</font></right>";


}

#print "</center>";
print "</center></h4>";
  print qq~
    <center><br><form action="log_ups.pl" target="_blank">

   <button type="submit" class="btn btn-info" value="$line"  name="name">Журнал аварий</button>
  </form>
  <br>
  </center>
  ~;
END:
print "<div id=\"zyoma\">nnzimin\@mts.ru</div>";
print qq~

<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
</body>
</html>";
~;




 
sub getSnmp  {
 my $oid = shift;
   my %snmplldpnei_hash = %{$session -> get_table("$oid")};
	foreach my $ipaddoid (keys %snmplldpnei_hash)
	{
		$otvet = $snmplldpnei_hash{$ipaddoid};
	}
 return $otvet;       
}
$session->close();  