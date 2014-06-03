#!/usr/bin/perl

use 5.010;
use Crypt::Eksblowfish::Bcrypt;
use bytes;

if (! $ARGV[0] ) {
	print "please type  $0 myWonderfullPassword\n";
	exit;
}



my $salt ='AIfoBACaIDjYUc1yLfO3ou';
my $length = length($salt);

if ( length($salt) > 16 ) { 
	print "salt length: $length\n";
	print "You salt is > 16 octets, remove some caracteres\n";
}

if ( length($salt) < 16 ) { 
	print "salt length: $length\n";
	print "You salt is < 16 octets, add some caracteres\n";
}


my $settings = '$2a$10$'.$salt;

my $hash =  Crypt::Eksblowfish::Bcrypt::bcrypt($ARGV[0], $settings);

print "Salted Password and bcrypt(ed)  $hash\n";

