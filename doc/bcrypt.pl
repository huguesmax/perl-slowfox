#!/usr/bin/perl

use Crypt::Eksblowfish::Bcrypt;
use Crypt::Random;

my $password = 'eliott';
my $salt     = 'BIfoAOPaIBjYUc1yLfO3ou';
$encrypted = encrypt_password($password, $salt);

#print "Yes the password is $password\n" if check_password($password, $encrypted);
#print "No the password is not smalltest\n" if !check_password('smalltest', $encrypted);

print "Mot de passe en clair : $password\n";
print "Mot de passe en clair : crypté et salé : $encrypted\n";


# Encrypt a password 
sub encrypt_password {
    my $password = shift;

    # Generate a salt if one is not passed
    my $salt = shift || salt(); 
    print "$salt\n";
    # Set the cost to 8 and append a NUL
    my $settings = '$2a$10$'.$salt;

    # Encrypt it
    return Crypt::Eksblowfish::Bcrypt::bcrypt($password, $settings);
}

# Check if the passwords match
sub check_password {
    my ($plain_password, $hashed_password) = @_;

    # Regex to extract the salt
    if ($hashed_password =~ m!^\$2a\$\d{2}\$([A-Za-z0-9+\\.]{22})!) {
        return encrypt_password($plain_password, $1) eq $hashed_password;
    } else {
        return 0;
    }
}

# Return a random salt
sub salt {
    return Crypt::Eksblowfish::Bcrypt::en_base64(Crypt::Random::makerandom_octet(Length=>16));
}
