#!/usr/bin/perl 

package fh_cabel;
require Exporter;
@ISA=qw(Exporter);

$EXPORT[0]=qw(NN);  
use Net::SNMP qw(:snmp);
use strict;
use Fcntl;
use Socket;
use 5.010;

sub NN {
my $line=$_[0];

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


#соберем имена интерфейсов
my %name_port_hash = ();
my $snmptemp = $session->get_table(
            -baseoid        => '.1.3.6.1.4.1.3807.1.8012.2.4.1.2',
            -maxrepetitions => 5
            );
    
            
    foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) {
        if ($oid =~ /^.1.3.6.1.4.1.3807.1.8012.2.4.1.2\.([\d]+)$/) {
            my $num = $1;
            my $name_port = $session->var_bind_list->{$oid};
            $name_port_hash{ $num } = $name_port;

        }
    }
#длины на портах
my @lenhgt_list;
my $snmptemp = $session->get_table(
            -baseoid        => '.1.3.6.1.4.1.3807.1.8012.2.4.1.75',
            -maxrepetitions => 5
            );
    
            
    foreach my $oid (oid_lex_sort(keys(%{$session->var_bind_list}))) {
        if ($oid =~ /^.1.3.6.1.4.1.3807.1.8012.2.4.1.75\.([\d]+)$/) {
         my $num = $1;
        my $cabel_lenght = $session->var_bind_list->{$oid};
        #length:0/0/0/0
        $cabel_lenght=~ s/length:(\S+).+/$1/g;
        push @lenhgt_list, "<h3><b><u>$name_port_hash{$num}</u></b> - Длина пар:   $cabel_lenght<br></h3>";
        #print "<h3><b><u>Порт $name_port_hash{$num}</u></b><br>Длина: $cabel_lenght<br></h3>";
        }
    } 
    return @lenhgt_list;
}