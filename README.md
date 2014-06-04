 
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
You need a modern distro as Redhat 6.4/Centos 6.4/Fedora 18  ( or Debian 7 / Ubuntu 12/ 14 not yet tester) 


Redhat/Centos/Fedora :

	yum -y groupinstall development && yum -y groupinstall perl-runtine
	yum -y install Redis mysql-server mysql curl perl-ExtUtils* mysql-devel wget perl-IO-Socket-SSL 	
	

Perl Dancer, SlowFox need lot of perl Module, the best way to install all this modules is to 
use [Cpanminus](https://metacpan.org/pod/App::cpanminus).

 
As root user


    curl -L http://cpanmin.us | perl - App::cpanminus

You can use also yum or apt-get.


    
    cpanm Dancer YAML Template JSON Redis Dancer::Session::Redis Dancer::Plugin::Database
    Dancer::Plugin::Auth::RBAC Crypt::Eksblowfish::Bcrypt DateTime::Format::Strptime Tie::IxHash Modern::Perl 	   
    DateTime::Format::MySQL   DateTime::Format::Duration Dancer::Plugin::Redis
    HTML::Strip Daemon::Control Net::Server

And


    cpanm Server::Starter Dancer::Plugin::Email

And

    cpanm Net::Server::SS::PreFork

And

    cpanm Starman   DBD::mysql


And Wait..... Cup of coffee Time....

## OK now we can start: ##



    cd /home

    wget https://github.com/huguesmax/perl-slowfox/archive/master.zip -O slowfox.zip

    unzip slowfox.zip

    cd perl-slowfox-master


## load mysql data ##


    service mysqld start	[OK]
    
    mysql
	mysql> create database slowfox;
	Query OK, 1 row affected (0.00 sec) 

    
    mysql> \quit
	Bye

    mysql slowfox < doc/slowfox.sql


## Stop Default Firewall && apache ##

If you have default install, firewall will block all connections. ( do that only on your dev server )

    service iptables stop		[OK]
    service httpd stop                  [OK]

## first step dance. ##

get you IP:

    ifconfig eth0
    eth0      Link encap:Ethernet  HWaddr 00:0C:29:5A:9C:1C
              inet adr:192.168.0.37  Bcast:192.168.0.255  Masque:255.255.255.0


    ./bin/app.pl --port 80

    [31482]  core @0.000012> loading Dancer::Handler::Standalone handler in /usr/local/share/perl5/Dancer/Handler.pm l. 45
    [31482]  core @0.000245> loading handler 'Dancer::Handler::Standalone' in /usr/local/share/perl5/Dancer.pm l. 483
    >> Dancer 1.3124 server 31482 listening on http://0.0.0.0:80
    >> Dancer::Plugin::Auth::RBAC::Credentials::MySQL (1.110720)
    >> Dancer::Plugin::Auth::RBAC (1.110720)
    >> Dancer::Plugin::Auth::RBAC::Credentials (1.110720)
    >> Dancer::Plugin::Database::Core (0.06)
    >> Dancer::Plugin::Database::Core::Handle (0.02)
    >> Dancer::Plugin::Database (2.09)
    >> Dancer::Plugin::Auth::RBAC::Permissions (1.110720)
    >> Dancer::Plugin::Ajax (1.00)
    >> Dancer::Plugin::Auth::RBAC::Permissions::Config (1.110720)
    >> Dancer::Plugin::Email (1.0201)
    == Entering the development dance floor ...


Please go to http://192.168.0.37  ( replace 192.168.0.37 by your ip address )
	
   




















