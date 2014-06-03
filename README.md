 
# SlowFox Dance 2014 #
> slow down your FireFox :-)
> (Version Française plus bas.)

created by Hugues MaX huguesmax[at]gmail.com

Based on Perl Dancer 1 [http://www.dancer.org](http://www.dancer.org)

Directly Inspired from [http://cowbell.cancan.cshl.edu/](http://cowbell.cancan.cshl.edu/)

Inspired from [perlmaven.com](http://perlmaven.com/getting-started-with-perl-dancer-on-digital-ocean)

## What is SlowFox ? ##

SlowFox is a Dancer 1 application for your Entreprise - this is a collection of web
pages pre formated to show you how to use and develop using
 
- [Perl](http://www.perl.org)
- [Dancer framwork](http://perldancer.org/) 
- [Mysql](http://www.mysql.com/)
- [Redis Key-Value Session Store](http://redis.io/)
- [Twitter Bootstrap](http://getbootstrap.com/)
- [JQuery](http://jquery.com/)   

## What I can do whith SlowFox ##
As you want ( the world is not engouth ) I use SlowFox for my Job, I developpe a software to manage some customers....

## How to Install SlowFox ##
You need a modern distro as Redhat 6.X/Centos 6.x/Fedora or Debian 7 / Ubuntu 12/ 14



    Debian/Ubuntu : sudo apt-get install Redis mysql-server mysql curl  

Or Redhat/Centos/Fedora :

in French    
	
	yum install 'Outils de développement' 
	yum groupinstall 'Prise en charge Perl'

in English
	yum install 'Development Tools'
	yum install 'Perl tools' 
	yum install Redis mysql-server mysql curl perl-ExtUtils* mysql-devel wget
	

Perl Dancer, SlowFox need lot of perl Module, the best way to install all this modules is to 
use [Cpanminus](https://metacpan.org/pod/App::cpanminus).

 
As root user


    curl -L http://cpanmin.us | perl - App::cpanminus

for Debian/Ubuntu


    curl -L http://cpanmin.us | perl - --sudo App::cpanminus



You can use also yum or apt-get.


    
    cpanm Dancer YAML Template JSON Redis Dancer::Session::Redis   Dancer::Plugin::Email Dancer::Plugin::Database
    Dancer::Plugin::Auth::RBACCrypt::Eksblowfish::Bcrypt DateTime::Format::Strptime Tie::IxHash Spreadsheet::ParseExcel
    Spreadsheet::WriteExcel Modern::Perl DateTime::Format::MySQL   DateTime::Format::Duration Dancer::Plugin::Redis
    HTML::Strip Daemon::Control Net::Server

And


    cpanm Server::Starter

And

    cpanm Net::Server::SS::PreFork

And

    cpanm Starman   DBD::mysql


And Wait..... Cup of coffee Time....

## OK now we can start: ##

cd /home

[download lastest version of slowfox](https://github.com/huguesmax/perl-slowfox/archive/master.zip)






















 