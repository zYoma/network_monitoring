#!/usr/bin/perl 




use strict;
use Fcntl;
use Socket;
use CGI;
use 5.010;





my $name = 'None';


print "Content-type: text/html\n\n";
my $my_cgi = new CGI;
my $line = $my_cgi->param('name');

print " <title> Лог $line</title>";
print "
<style >

	body {
background-color: #ECF6CE;
</style >";

if ($line eq '10.228.123.10'){ $name = 'Репино 20';}
elsif ($line eq '10.228.123.4'){ $name = 'Клубная 12а';}
elsif ($line eq '10.228.123.9'){ $name = 'Карла Маркса 14';}
elsif ($line eq '10.228.123.7'){ $name = 'Северная 279';}
elsif ($line eq '10.228.123.8'){ $name = '40 лет Победы 43';}
elsif ($line eq '10.228.123.13'){ $name = '70 лет Октября 34';}
elsif ($line eq '10.228.123.25'){ $name = 'Аверкиева 6';}
elsif ($line eq '10.228.123.22'){ $name = 'Благоева 48';}
elsif ($line eq '10.228.123.47'){ $name = 'Восточно Кругликовская 28/2';}
elsif ($line eq '10.228.123.40'){ $name = 'Восточно Кругликовская 65';}
elsif ($line eq '10.228.123.33'){ $name = 'Героев Разведчиков 28';}
elsif ($line eq '10.228.123.31'){ $name = 'Душистая 49';}
elsif ($line eq '10.228.123.51'){ $name = 'Казбекская 7';}
elsif ($line eq '10.228.123.49'){ $name = 'Котлярова 17';}
elsif ($line eq '10.228.123.37'){ $name = 'Кореновская 69';}
elsif ($line eq '10.228.123.36'){ $name = 'Морская 11';}
elsif ($line eq '10.228.123.54'){ $name = 'Есенина 131';}
elsif ($line eq '10.228.123.24'){ $name = 'Невкипелого 15';}
elsif ($line eq '10.228.123.23'){ $name = 'Игнатова 4';}
elsif ($line eq '10.228.123.21'){ $name = 'Игнатова 35';}
elsif ($line eq '10.228.123.6'){ $name = 'Приозерная 13';}
elsif ($line eq '10.228.123.32'){ $name = 'Покрышкина 4/10';}
elsif ($line eq '10.228.123.28'){ $name = 'Симферопольская 30/1';}
elsif ($line eq '10.228.123.45'){ $name = 'Красных Партизан 248';}
elsif ($line eq '10.228.123.18'){ $name = 'Сормовская 102';}
elsif ($line eq '10.228.123.15'){ $name = 'Сормовская 185';}
elsif ($line eq '10.228.123.43'){ $name = 'Ставропольская 182';}
elsif ($line eq '10.228.123.14'){ $name = 'Ставропольская 258';}
elsif ($line eq '10.228.123.20'){ $name = 'Тюляева 37/1';}
elsif ($line eq '10.228.123.19'){ $name = 'Тюляева 12';}
elsif ($line eq '10.228.123.11'){ $name = 'Уральская 154/2';}
elsif ($line eq '10.228.123.16'){ $name = 'Уральская 178';}
elsif ($line eq '10.228.123.12'){ $name = 'Уральская 194';}
elsif ($line eq '10.228.123.17'){ $name = 'Генерала Трошева 33';}
elsif ($line eq '10.228.123.41'){ $name = 'Зиповская 48';}
elsif ($line eq '10.228.123.44'){ $name = 'Лукьяненко 95/2';}

elsif ($line eq '10.228.91.68'){ $name = 'Анапское, д. 41/к.Ж';}
elsif ($line eq '10.228.91.70'){ $name = 'Героев Десантников, д. 24';}
elsif ($line eq '10.228.91.71'){ $name = 'Героев Десантников, д. 65/к./1';}
elsif ($line eq '10.228.91.72'){ $name = 'Куникова, д. 9';}
elsif ($line eq '10.228.91.74'){ $name = 'Ленина, д. 103';}
elsif ($line eq '10.228.91.75'){ $name = 'Суворовская, д. 2/к.Б';}
elsif ($line eq '10.228.91.77'){ $name = 'Видова, д. 167';}
elsif ($line eq '10.228.91.78'){ $name = 'Пионерская, д. 39';}
elsif ($line eq '10.228.91.79'){ $name = 'Южная, д. 19';}
elsif ($line eq '10.228.91.82'){ $name = 'Серебрякова, д. 8/к.1';}
elsif ($line eq '10.228.91.86'){ $name = 'мкр. 12-й, д. 37';}
elsif ($line eq '10.228.91.85'){ $name = 'Ленина, д. 179/к.3';}
elsif ($line eq '10.228.91.76'){ $name = 'Парковая, д. 62 б';}
elsif ($line eq '10.228.91.83'){ $name = 'Красно-зеленых, д. 6';}
elsif ($line eq '10.228.91.87'){ $name = 'Козлова, д. 62 UPS 1';}
elsif ($line eq '10.228.91.88'){ $name = 'Козлова, д. 62 UPS 2';}
elsif ($line eq '10.228.91.89'){ $name = 'Козлова, д. 62 UPS 3';}
elsif ($line eq '10.228.91.90'){ $name = 'Козлова, д. 62 UPS 4';}
elsif ($line eq '10.228.91.91'){ $name = 'Козлова, д. 62 UPS 5';}
elsif ($line eq '10.228.91.92'){ $name = 'Козлова, д. 62 UPS 6';}
elsif ($line eq '10.228.91.93'){ $name = 'Козлова, д. 62 UPS 7';}
elsif ($line eq '10.228.91.94'){ $name = 'Козлова, д. 62 UPS 8';}

#Ищем в файле последние события по данному адресу

my $ups_log = 'UPS_logs';

open(FIL,$ups_log);
my @log = <FIL>;
chomp @log;
close(FIL);
my @log_name;


foreach my $str_log(@log) 

{
my $color = 'green';
if ($str_log =~ /$name/){
if ( $str_log =~ /Пропало/ ||  $str_log =~ /Не доступен/ ||$str_log =~ /Падает/ ) {$color = 'red';}
$str_log =~ s/^(\d+):(\d+):(\d+):(\d+):(\d+):\d+\s(.+)/$1 $2 $3 $4 $5 $6/g;
my $date = "<font color = '$color'>$3-$2-$1</font> в <b>$4:$5</b> &nbsp;$6";
print $date;
print "<br>";
}
}
	


			



