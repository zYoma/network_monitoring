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
my $snmptimeout = '1';
my $line;
my $snmp_oid ='.1.3.6.1.2.1.1.2.0';
my $device;
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
my $color = 'red';

print "Content-type: text/html\n\n";
 $my_cgi = new CGI;
 $line = $my_cgi->param('name');
 
$chekping=$ENV{'QUERY_STRING'}; #получаем параметры, переданные скрипту
   (my $name, $chekping) = split(/=/, $chekping);


#chomp ($line = <STDIN>);
$line =~ s/\s+//g;


print qq~

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
 <title> Данные с оптических приемников</title>
  <link rel="shortcut icon" href="favicon.ico" type="image/x-icon">
   <link rel="stylesheet" href="http://10.40.254.109/op/bootstrap/css/bootstrap.min.css" >
  <link rel="stylesheet" href="http://10.40.254.109/op/style.css">
</head>
<body>


   <script type="text/javascript">
  if (navigator.userAgent.search(/MSIE/) > 0 || navigator.userAgent.search(/NET CLR /) > 0) {window.location.replace("http://10.40.254.109/op/sw/monitor/ie.html");};
   function isSW(obj) {
    var str = obj.text;
   document.getElementById('my_input').value = str;
	document.getElementById('my_form').submit();
	
   }

  </script>  
  
 <script src="http://10.40.254.109/op/header.js"></script>
  



  
  <script type="text/javascript">
function CopyToClipboard(containerid) {
if (document.selection) { 
    var range = document.body.createTextRange();
    range.moveToElementText(document.getElementById(containerid));
    range.select().createTextRange();
    document.execCommand("Copy"); 

} else if (window.getSelection) {
    var range = document.createRange();
     range.selectNode(document.getElementById(containerid));
     window.getSelection().addRange(range);
	
     document.execCommand("Copy");
	 window.getSelection().removeAllRanges();
     
}}
  </script>
  


  <center><p>Введите IP адрес или доменное имя приемника КТВ.</p>


  
 <div id="wrapper">
  
  <form method='post' action='op_web.pl'>
  <div class="form-row">
  
    <div class="col-auto">
      <input type="text" name='name' value="$line" class="form-control mb-2" id="inlineFormInput" placeholder="IP или DNS">
    </div>
    <div class="col-auto">
      <button type="submit" class="btn btn-danger mb-2">Получить данные</button>
    </div>
	</div>
	
	</form>
  
 </div>
  
  
  


  </center>




~;
print " <title> Данные с оптических приемников</title>";

if ($line eq '') {goto END;} 

if ($line =~ /^(\D)(?=\w)/)  # Найти цифру за которой стоит '-'
{
$line =~ s/(\w+)\.\w+/$1/;
}
eval{
			#Получаем NS запись
			$dns = gethostbyaddr(inet_aton($line), AF_INET)
  or die "Can't resolve $line: $!\n";
$dns =~ s/(\w+)\.\w+/$1/; #отрезаем .local
};
if ($chekping == 0){
my $p = Net::Ping->new("tcp", 2);
$p->{'port_num'} = 23;
    
        if ($p->ping($line,0.900)){
        
        $p->close();
        }else{
              print "<center>
			  
<div class=\"layer\"><font size ='17pt'><center> <font color = 'red'>$line</font>  не отвечает.</font></div>";

			  print qq~
			  <br> <div class="block2">
    <form  method='post' action="op_web.pl?chekping=2"   >

   <button type="submit" class="btn btn-info" value="$line"  name="name">Пропустить пинг</button>
  </form>

 </div>
  ~;

			   print "</div></center>";
			 
				goto END;
                $p->close();
            }
	}
	



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
                ($session, $error) = Net::SNMP -> session(  -timeout => $snmptimeout,
              -retries => "1",
            -hostname => $line,
            -version => "1",
            -community => "public",
            -port => 161,
            -timeout => "1",
            -translate => [-octetstring => 0x0]
 );
 $snmp_com ="public";
}


				
                            

my $result = $session->get_request("$snmp_oid");
unless (defined $result) {
print " <div class=\"layer\"><font size ='17pt'><center> <font color = 'red'>$line</font>  не отвечает по snmp.</font></div>";

goto END;
}


#Lambda PRO 72
if ($result->{$snmp_oid} eq ".1.3.6.1.4.1.11195.1")
{
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

 if ( $soft ne "1.4.5")
{
$chekSW =1;
}
$device = "Lambda PRO 72";

}

#sdo3002
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.32108.1.7" )
{
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

 if ( $soft ne "1.0.1.5")
{
$chekSW =1;
}
$device = "sdo3002";

}

#sdo3001
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.32108.1.8" )
{
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
 if ( $soft ne "1.0.1.5")
{
$chekSW =1;
}
$device = "sdo3001";

}

#OR862-I
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.17409.1")
{
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
if ($result->{$snmp_oid} eq ".1.3.6.1.4.1.17409.1.10")
{
$device = "OR-862S-2";
}
}

#tuz19-2003
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.32108.1.9")
{
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

 if ( $soft ne "1.0.1.5")
{
$chekSW =1;
}
$device = "tuz19-2003";
}

#EAU-1000/16-C2-220/60-I (C)-BS
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.35702.3.5")
{
   #Серийный номер
my  $snmptemp = $session -> get_request('.1.3.6.1.4.1.35702.3.5.1.2.0');
 $sn = $snmptemp -> {'.1.3.6.1.4.1.35702.3.5.1.2.0'};
   #Версия платы
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.35702.3.5.1.3.0');
 $hwVersion = $snmptemp -> {'.1.3.6.1.4.1.35702.3.5.1.3.0'};
    #Версия прошивки
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.35702.3.5.1.4.0');
 $swVersion = $snmptemp -> {'.1.3.6.1.4.1.35702.3.5.1.4.0'};
     #Активный канал
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.35702.3.5.2.4.0');
 $ActivChanel = $snmptemp -> {'.1.3.6.1.4.1.35702.3.5.2.4.0'};
 #Получаем уровни сигнала
$snmptemp = $session -> get_request('.1.3.6.1.4.1.35702.3.5.2.2.0');
 $powerA = $snmptemp -> {'.1.3.6.1.4.1.35702.3.5.2.2.0'};
$snmptemp = $session -> get_request('.1.3.6.1.4.1.35702.3.5.2.3.0');
 $powerB = $snmptemp -> {'.1.3.6.1.4.1.35702.3.5.2.3.0'};
     #Температура
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.35702.3.5.2.10.0');
 $term = $snmptemp -> {'.1.3.6.1.4.1.35702.3.5.2.10.0'};
 $term =~ s/(..)/$1./;
  #Выходной сигнал
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.35702.3.5.2.6.0');
 $out = $snmptemp -> {'.1.3.6.1.4.1.35702.3.5.2.6.0'};
 $out =~ s/(..)/$1./;
 #Получаем IP
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.35702.2.2.0');
 $ip = $snmptemp -> {'.1.3.6.1.4.1.35702.2.2.0'};
 #Получаем версию ПО
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.35702.3.5.1.4.0');
 $soft = $snmptemp -> {'.1.3.6.1.4.1.35702.3.5.1.4.0'};
 $soft =~ s/^\bswtsamp(.+)/$1/;
 
$device = "EAU-1000/16-C2-220/60-I (C)-BS";
}

#EDFA-1550/33(16*18)
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.17409.1.11")
{
   #Серийный номер
my  $snmptemp = $session -> get_request('.1.3.6.1.2.1.47.1.1.1.1.11.1');
 $sn = $snmptemp -> {'.1.3.6.1.2.1.47.1.1.1.1.11.1'};

    #Версия прошивки
 $snmptemp = $session -> get_request('.1.3.6.1.2.1.47.1.1.1.1.10.1');
 $soft = $snmptemp -> {'.1.3.6.1.2.1.47.1.1.1.1.10.1'};
    
 #Получаем уровни сигнала
$snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.11.3.0');
 $powerA = $snmptemp -> {'.1.3.6.1.4.1.17409.1.11.3.0'};
$snmptemp = $session -> get_request('.1.3.6.1.4.1.35702.3.5.2.3.0');
 $powerB = $snmptemp -> {'.1.3.6.1.4.1.35702.3.5.2.3.0'};
     #Температура
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.35702.3.5.2.10.0');
 $term = $snmptemp -> {'.1.3.6.1.4.1.35702.3.5.2.10.0'};
   #Выходной сигнал
 $snmptemp = $session -> get_request('.1.3.6.1.4.1.17409.1.11.2.0');
 $out = $snmptemp -> {'.1.3.6.1.4.1.17409.1.11.2.0'};
 if ( length $out == 3)
{
$out =~ s/(..)/$1./;
}
$device = "EDFA-1550/33";
}
else 
{
print "<div class=\"layer\"><font size ='17pt'><center> <font color = 'red'>$line</font>  неизвестная модель приемника.</font></div>";
print "</center>";
goto END;
}
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
 $color = 'red';
  if ( $powerA > 2.5) {$color = 'blue';}
  if ( $powerA < -9) {$color = 'blue';}
  if ( $powerA eq 'low') {$color = 'blue';}
  $powerA = "<font color = '$color'>$powerA</font>";
  
 $color = 'red';
  if ( $powerB > 2.5) {$color = 'blue';}
  if ( $powerB < -9) {$color = 'blue';}
  if ( $powerB eq 'low') {$color = 'blue';}
  $powerB = "<font color = '$color'>$powerB</font>";

  $color = 'red';
  if ( $volt > 26) {$color = 'blue';}
  $volt = "<font color = '$color'>$volt</font>";
  
   $color = 'red';
  if ( $out < 96) {$color = 'blue';}
  $out = "<font color = '$color'>$out</font>";
  
$session->close();  


print "<center>
<div id=\"copy\">$dns - $ip - $device</div><button class=\"btn btn-info\" id=\"button1\" onclick=\"CopyToClipboard('copy')\">Копировать</button>
<br><br><h2><div id=\"back\"><font color='brown'><center>$dns</center></font><br>
<font color='white' style = 'background-color: #8A0829'>$device</font>  ver. <b>$soft</b> <BR>";


print "<u>Вход А</u>: <font color='red'>   <b>$powerA </font> dBm </b><BR> <u>Вход B</u>: <font color='red'>   <b>$powerB</font> dBm</b> <BR>";
print "<u>Выход</u>: <font color='red'>   <b>$out</font> dBuV</b> <BR>";
print "<u>Активный вход</u>: <font color='red'>   <b>$ActivChanel</font></b> <BR>";
print "<u>Температура</u>: <font color='red'>   <b>$term</font> °C</b> <BR>";
if ($result->{$snmp_oid} ne ".1.3.6.1.4.1.35702.3.5"){
print "<u>Напряжение</u>: <font color='red'>   <b>$volt</font> V</b> <BR>";
}
if ($result->{$snmp_oid} ne ".1.3.6.1.4.1.17409.1" &&  $result->{$snmp_oid} ne ".1.3.6.1.4.1.35702.3.5"){
print "<u>MAC</u>: <font color='red' size='5px'>   <b>$mac</font></b> <BR>";
}
print "<u>IP</u>: <font color='red' size='6px'>   <b>$ip</font></b> <BR>";
#if ($result->{$snmp_oid} eq ".1.3.6.1.4.1.17409.1.10.1.0" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.17409.1.10"){
#print "<u>S/N</u>: <font color='red' '>  <b>$Serial</b></font><BR>";
#}

print "<u>SNMP</u>: <font color='red' '>  <b>$snmp_com</b></font> </div></h2><BR>";

if ($chekSW == 1)
{
print qq~
<form method='post' action='op_upd_web_new.pl'>
    <br>
    <button class="btn btn-info" value="$line" name="name1">Обновить ПО</button>
  </form>
~;
}
if ($snmp_com eq 'public')
{
print qq~
<form method='post' action='op_snmp_web_new.pl'>
    <br>
    <button class="btn btn-info" value="$line" name="name2">Прописать icomm</button>
  </form>
~;
}
#print "</center>";
print "</center>";
END:
print qq~
<div id=\"zyoma\">nnzimin\@mts.ru</div>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>

</body></html>
~;
