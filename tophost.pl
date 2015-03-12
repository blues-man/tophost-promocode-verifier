#!/usr/bin/perl -w
############################################################################
#    Tophost Promo Code Checker                                            #
#    Copyright (C) 2014 by Natale Vinto aka bluesman                       #
#    ebballon@gmail.com                                                    #
#                                                                          #
#    This program is free software; you can redistribute it and#or modify  #
#    it under the terms of the GNU General Public License as published by  #
#    the Free Software Foundation; either version 2 of the License, or     #
#    (at your option) any later version.                                   #
#                                                                          #
#    This program is distributed in the hope that it will be useful,       #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#    GNU General Public License for more details.                          #
#                                                                          #
#    You should have received a copy of the GNU General Public License     #
#    along with this program; if not, write to the                         #
#    Free Software Foundation, Inc.,                                       #
#    59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             #
############################################################################

# v. 0.2 aggiunto supporto STDIN e controllo indipendente dal rinnovo dei propri domini
# v. 0.1 molto molto molto molto molto molto molto grezzo 

use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use HTTP::Cookies;
use HTML::Entities;

my $username = ''; # USERNAME TOPHOST.IT
my $password = ''; # PASSWORD TOPHOST.IT

my $VERSION = '0.2';


my $url = 'http://www.tophost.it/th/';


if (scalar(@ARGV) > 0 && ($ARGV[0] eq "-h" || $ARGV[0] eq "--help")) {
  
  print "Tophost Promo Code Checker v. $VERSION by bluesman\n";
  print "./tophost.pl e incolla i tuoi codici, terminando il tutto con CTRL+D\n";
  print "./tophost.pl < codici.txt\n";
  exit;
}

my $ua        = LWP::UserAgent->new();
my $cookiejar = HTTP::Cookies->new();
$ua->cookie_jar( $cookiejar );
$ua->agent( 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.; Trident/5.0)' );
push @{ $ua->requests_redirectable }, 'POST';



$res = POST 'http://www.tophost.it/th/index.php?option=login',
  [
    username => $username,
    passwd => $password,
    op2			=> 'login',
    lang       		=> 'italian',
    Submit     		=> 'Entra',
  ];

$content = $ua->request($res)->content;

if ($content =~ /<tr align="left"><td><a href="(.*)" class="mainlevel">Stato degli ordini<\/a></) {
    my $path = $1;
    $path = decode_entities($path);
    $res = $ua->get($url . $path);
    $content = $res->content;
    
} else {
  print "Errore login. Controlla username e password.\n";
  exit;
 }

$ua->default_header( 'Referer' => 'http://www.tophost.it/oo/02-dominio.php' );
 
my @input = <>;

die("Nessun codice passato") if scalar(@input) == 0;

print "\nRicevuti " . scalar(@input) . " codici, vediamo un po'\n";

foreach my $codice (@input) {
  $codice =~ s/\n//;
  if (length($codice) < 13){
    print "codice $codice non corretto, passo\n";
    next;
  }
  print "provo con $codice ..";
  $res = POST 'http://www.tophost.it/oo/06-validazione.php?pagchiamante=2',
    [
      nomedominio     => '',
      tld => 'it',
      pacchetto => 'topweb',
      qt => '1',
      pagamento => 'paypal',
      pagamentor => 'codice',
      invcod => $codice,
      Submit => 'avanti'
    ];
    $resp = $ua->request($res);
    
    if ($resp->is_success) {
    
      $content = $ua->request($res)->content;   
      if ($content =~ /ERRORE: Il codice di invito inserito risulta/){
         print "no\n";
      } else {
         print "Bingo!\t: $codice\n";
         last;
      }
    } else {
      print "Errore di rete, conviene riprovare\n";
      exit;
    }
    # boni, state boni..
    sleep 1;
}
