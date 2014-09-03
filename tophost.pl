#!/usr/bin/perl -w

use LWP::UserAgent;
use HTTP::Request::Common qw(POST);
use HTTP::Cookies;
use HTML::Entities;

my $username = ''; # USERNAME TOPHOST.IT
my $password = ''; # PASSWORD TOPHOST.IT


my $url = 'http://www.tophost.it/th/';

my $file = 'codici.txt';

die("Codici assenti") unless -e $file;

open DAT, $file;
my @codici = <DAT>;
close DAT;


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
  print "Errore login.";
  exit;
 }
 
if ($content =~ /<a href="\/oo\/rin-01.php\?dominio=(.*)"></) {
  my $id = $1;
  my $url = "http://www.tophost.it/oo/rin-01.php?dominio=$id";
  $res = $ua->get($url);
  $content = $res->content;
  
} else {
  print "Errore pagina domini.";
  exit;

}

unless ($content =~ /<form action="\/oo\/rin-01.php" method="post" name="forminvcod">/) {

  print "Errore pagina rinnovo";
  exit;
}

foreach my $codice (@codici) {
  $codice =~ s/\n//;
  print "provo con $codice ..";
  $res = POST 'http://www.tophost.it/oo/rin-01.php',
    [
      invcod     => $codice,
      chd_invcod => 'includi codice sconto'
    ];
    $content = $ua->request($res)->content;

    if ($content =~ /ATTENZIONE: Il codice di invito inserito risulta gia' utilizzato/){
	print "no\n";
    
    } else {
    
	print "Bingo!\t: $codice\n";
	last;
    
    }
    # boni, state boni..
    sleep 1;
}






 
 