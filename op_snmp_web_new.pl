#!/usr/bin/perl 

use Net::SNMP;
use strict;
use Fcntl;

use Net::Ping;
use Socket;
use POSIX qw(strftime);
use CGI;
use 5.010;
my $snmptimeout = '0.500';
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
my $snmptemp;

print "Content-type: text/html\n\n";
 $my_cgi = new CGI;
 $line = $my_cgi->param('name2');
#chomp ($line = <STDIN>);
$line =~ s/\s+//g;
print "
<style >
	body {
background-color: #ECF6CE;
padding-top: 5%;
}
h2{
    margin: 0; /* Убираем отступы вокруг */
    color: #2E64FE;
	
	font-weight: normal;
	font-size: 25pt;
   }
   h3{
    margin: 0; /* Убираем отступы вокруг */
    padding-left: 35%; /* Поле слева */
	padding-top: 10%;
	font-weight: normal;
	font-size: 25pt;
   }
   
 
   
   .layer {
   padding-top: 5%;
   text-align: center;
   }
  #zyoma {
position: fixed; 
    right: 0; bottom: 0; 
    padding: 10px; 
	 }
p{
font-size: 17pt;
}
</style >";

print qq~

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0//EN">
<html>
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
 <title> Данные с оптических приемников</title>
</head>
<body>
    <style >

input.knopka {
  color: #fff; /* цвет текста */
  text-decoration: none; /* убирать подчёркивание у ссылок */
  user-select: none; /* убирать выделение текста */
  background: rgb(212,75,56); /* фон кнопки */
  padding: .7em 1.5em; /* отступ от текста */
  outline: none; /* убирать контур в Mozilla */
  height:40px;
} 
input.knopka:hover { background: rgb(232,95,76); } /* при наведении курсора мышки */
input.knopka:active { background: rgb(152,15,0); } /* при нажатии */


input.inputField {
font-family: Verdana, sans-serif;
background-color: #E6E5EA;
border: solid 1px #11385F;

width:35%;
height:35px;
font-family: Verdana, sans-serif;
font-size: 90%;
}

 p {
    font-family: Verdana, Arial, Helvetica, sans-serif; 
    font-size: 18pt; /* Размер шрифта в пунктах */ 
   }
   #zyoma {
position: fixed; /* Фиксированное положение */
    right: 0; bottom: 0; /* Левый нижний угол */
    padding: 10px; /* Поля вокруг текста */
	 }
  </style>
  
  
  <center><p>Введите IP адрес или доменное имя приемника КТВ.</p>
  <form method='post' action='op_web.pl'>
    <br><input type='text' name='name' class="inputField" value="$line">
    <input type='submit' class="knopka" value="Получить данные с приемника">
  </form>
  <br>
<a href="http://10.40.254.109/op/ups/">Данные по ИБП</a>&nbsp;&nbsp;&nbsp;<a href="http://10.40.254.109/op/sw/">Данные по коммутаторам</a>
  </center>

</body>
</html>



~;
print " <title> Данные с оптических приемников</title>";




	my $p = Net::Ping->new();
$p->{'port_num'} = (getservbyname("htpp", "tcp") || 23);
    
        if ($p->ping($line,1.900)){
        
        $p->close();
        }else{
              print "<div class=\"layer\"><font size ='17pt'><center> <font color = 'red'>$line</font>  НЕдоступен.</font></div>";
print "</center>";
				exit; ;
                $p->close();
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
print " <h2>$line недоступен</h2>";

exit;
}
 
#Lambda PRO 72
if ($result->{$snmp_oid} eq ".1.3.6.1.4.1.11195.1")
{
$snmptemp = $session->get_request(".1.3.6.1.4.1.11195.1.5.2.0");
  $soft = $snmptemp -> {".1.3.6.1.4.1.11195.1.5.2.0"};

 if ( $soft ne "1.4.5")
{
print "<h2><div class=\"layer\">Версия ПО $soft - не актуальна. Требуется обновление.</div></h2>";
$session->close();  
exit;
}
else 
{
 my ($session, $error) = Net::SNMP->session
        (
            -retries => "1",
            -hostname => $line,
            -version => "1",
            -community => "private",
            -port => 161,
            -timeout => "1",
            -translate => [-octetstring => 0x0]
        ); 
my( @list);
   push( @list, (".1.3.6.1.4.1.11195.1.1.16.0", OCTET_STRING,"icomm"));

	 
 

  my $result = $session->set_request( -varbindlist => [@list]);

  print "<h2><div class=\"layer\">Прописано!</div></h2>";
  $session->close();  
}
}

#sdo3002
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.32108.1.7")
{
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.7.1.3.0');
 my $soft = $snmptemp -> {'.1.3.6.1.4.1.32108.1.7.1.3.0'};
 if ( $soft ne "1.0.1.4")
{
print "<h2><div class=\"layer\">Версия ПО $soft - не актуальна. Требуется обновление.</div></h2>";
$session->close();  
exit;
}
else 
{
 my ($session, $error) = Net::SNMP->session
        (
            -retries => "1",
            -hostname => $line,
            -version => "1",
            -community => "private",
            -port => 161,
            -timeout => "1",
            -translate => [-octetstring => 0x0]
        ); 
my( @list);
    push( @list, (".1.3.6.1.4.1.32108.1.7.4.2.2.0", OCTET_STRING, "icomm"));
 
    
	 
 

  my $result = $session->set_request( -varbindlist => [@list]);

 print "<h2><div class=\"layer\">Прописано!</div></h2>";
    
$session->close();  
}
}
#sdo3001
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.32108.1.8")
{
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.8.1.3.0');
 my $soft = $snmptemp -> {'.1.3.6.1.4.1.32108.1.8.1.3.0'};
 if ( $soft ne "1.0.1.4")
{
print "<h2><div class=\"layer\">Версия ПО $soft - не актуальна. Требуется обновление.</div></h2>";
$session->close();  
exit;
}
else 
{
 my ($session, $error) = Net::SNMP->session
        (
            -retries => "1",
            -hostname => $line,
            -version => "1",
            -community => "private",
            -port => 161,
            -timeout => "1",
            -translate => [-octetstring => 0x0]
        ); 
my( @list);
    push( @list, (".1.3.6.1.4.1.32108.1.8.4.2.2.0", OCTET_STRING, "icomm"));
 
    
	 
 

  my $result = $session->set_request( -varbindlist => [@list]);

 print "<h2><div class=\"layer\">Прописано!</div></h2>";
    
$session->close();  
}
}

#OR862-I
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.17409.1")
{
print "<h2><div class=\"layer\">Прописано!</div></h2>";
}

#OR862-I новый
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.17409.1.10.1.0" || $result->{$snmp_oid} eq ".1.3.6.1.4.1.17409.1.10")
{
 
  
my ($session, $error) = Net::SNMP->session
        (
            -retries => "1",
            -hostname => $line,
            -version => "1",
            -community => "public",
            -port => 161,
            -timeout => "1",
            -translate => [-octetstring => 0x0]
        ); 
my( @list);
   push( @list, (".1.3.6.1.4.1.17409.1.3.1.11.0", OCTET_STRING, "icomm"));
     
     
	 
  my $result = $session->set_request( -varbindlist => [@list]);
  

 print "<h2><div class=\"layer\">Не поддерживается данной версией приемника!<br>Измените значение через web-интерфейс.</div></h2>";
 
  $session->close();  
 #print "<h2><div class=\"layer\">Не доступно на данной модели.</div></h2>";
 
}
#tuz19-2003
elsif ($result->{$snmp_oid} eq ".1.3.6.1.4.1.32108.1.9")
{
my $snmptemp = $session -> get_request('.1.3.6.1.4.1.32108.1.9.1.3.0');
 my $soft = $snmptemp -> {'.1.3.6.1.4.1.32108.1.9.1.3.0'};
 if ( $soft ne "1.0.1.4")
{
print "<h2><div class=\"layer\">Версия ПО $soft - не актуальна. Требуется обновление.</div></h2>";
$session->close();  
exit;
}
else 
{
 my ($session, $error) = Net::SNMP->session
        (
            -retries => "1",
            -hostname => $line,
            -version => "1",
            -community => "private",
            -port => 161,
            -timeout => "1",
            -translate => [-octetstring => 0x0]
        ); 
my( @list);
   push( @list, (".1.3.6.1.4.1.32108.1.9.4.2.2.0", OCTET_STRING, "icomm"));
     
     
	 
  my $result = $session->set_request( -varbindlist => [@list]);
  

 print "<h2><div class=\"layer\">Прописано!</div></h2>";
 
  $session->close();  
}
}
else 
{
print "<div class=\"layer\"><font size ='17pt'><h2> <font color = 'red'>$line</font>  неизвестная модель приемника.</font></div>";
print "</h2>";
exit;
}



$session->close(); 


print "<div id=\"zyoma\">by N.Zimin</div>";