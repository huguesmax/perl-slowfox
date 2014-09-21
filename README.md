 
# SlowFOX Dance  #
> slow down your FireFox :-)

> (Pour la version Française, lire le fichier README-français.md.)

created by Hugues MaX huguesmax[at]gmail.com

Based on Perl Dancer 1 [http://www.dancer.org](http://www.dancer.org)

Freely Directly Inspired from [http://cowbell.cancan.cshl.edu/](http://cowbell.cancan.cshl.edu/)

Freely Inspired from [perlmaven.com](http://perlmaven.com/getting-started-with-perl-dancer-on-digital-ocean)

## What is SlowFOX ? ##

SlowFOX is a Dancer 1 application for your Entreprise - this is a collection of web
pages pre formated to show you how to use and develop using
 
- [Perl](http://www.perl.org)
- [Dancer framwork](http://perldancer.org/) 
- [Mysql](http://www.mysql.com/)
- [Redis Key-Value Session Store](http://redis.io/)
- [Twitter Bootstrap](http://getbootstrap.com/)
- [JQuery](http://jquery.com/)   



## Why Slowfox Name ? ##

see [SlowFOX](https://www.google.com/webhp?output=googleabout&gws_rd=ssl#q=slowfox)

## What I can do whith SlowFOX ##
As you want ( the world is not engouth ) I use SlowFOX for my Job, I developpe a software to manage some customers....

## How to Install SlowFOX ##
You need a modern distro as Redhat 6.4/Centos 6.4/Fedora 18  ( or Debian 7 / Ubuntu 12/ 14 not yet tester) 


Redhat/Centos/Fedora :

	yum -y groupinstall development && yum -y groupinstall perl-runtine
	yum -y install Redis mysql-server mysql curl perl-ExtUtils* mysql-devel wget perl-IO-Socket-SSL 	

Debian/buntu :

	apt-get install libmodule-install-perl redis-server make mysql-server curl libmysqlclient-dev wget libio-socket-ssl-perl libnet-ssleay-perl libssl-dev starman

Perl Dancer, SlowFOX need lot of perl Module, the best way to install all this modules is to 
use [Cpanminus](https://metacpan.org/pod/App::cpanminus).

 
As root user


    curl -L http://cpanmin.us | perl - App::cpanminus

Use cpanminus to intall all modules:


    
    cpanm Dancer YAML Template JSON Redis Dancer::Session::Redis Dancer::Plugin::Database  Dancer::Plugin::Auth::RBAC Crypt::Eksblowfish::Bcrypt DateTime::Format::Strptime Tie::IxHash Modern::Perl  DateTime::Format::MySQL  DateTime::Format::Duration Dancer::Plugin::Redis  HTML::Strip Daemon::Control Net::Server

And


    cpanm Server::Starter 
    
    
And

    cpanm Net::Server::SS::PreFork DBD::mysql

And for Centos/Redhat/Fedora only

    cpanm Starman


And Wait..... Cup of coffee Time....

## OK now we can start: ##


** clone it **
    cd /home

    wget https://github.com/huguesmax/perl-slowfox/archive/master.zip -O slowfox.zip

    unzip slowfox.zip

    cd perl-slowfox-master


## Create database & Load MySQL data ##


    service mysqld start	[OK]
    
    mysql
	mysql> create database slowfox;
	Query OK, 1 row affected (0.00 sec) 

    
    mysql> \quit
	Bye

Load default database ( there are only 2 tables users and voip)

    mysql slowfox < doc/slowfox.sql

login and password for database is default mysql instal


login: root
and there are no password

test mysql with this command

    [root@LocalVM ~]# mysql -u root
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 15
    Server version: 5.5.31-log MySQL Community Server (GPL) by Remi
    
    Copyright (c) 2000, 2013, Oracle and/or its affiliates. All rights reserved.
    
    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    mysql>


if you want to add mysql password ( little bit more secure... :-)  )

[MySQL](http://dev.mysql.com/doc/refman/5.0/fr/set-password.html)

and 
edit config.yml, this section

	plugins:
	    Database:
	        connections:
        	           slowfox:
	                          driver:   'mysql'
	                          database: 'slowfox'
	                          host:     'localhost'
	                          port:     3306
	                          username: 'root'
	                          password: ''
        	                  connection_check_threshold: 10
	                          dbi_params:
	                                      RaiseError: 1
	                                      AutoCommit: 1
	                                      mysql_enable_utf8 : 1
        	                              charset: utf8



and replace password by your password

BECAREFULL this is [YAML](http://en.wikipedia.org/wiki/YAML) file, space and tab are not the same think...


## Stop Default Firewall && apache ##

If you have default RedHat/Centos/Fedora install, firewall will block all connections. ( do that only on your dev server )

    service iptables stop    [OK]
    service httpd stop       [OK]

## First step dance. ##

get you IP:

    ifconfig eth0
    eth0      Link encap:Ethernet  HWaddr 00:0C:29:5A:9C:1C
              inet adr:192.168.0.37  Bcast:192.168.0.255  Masque:255.255.255.0



for me this us 192.168.0.37

launch dancer app, on port 80 ( by default this is on port 3000 )


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

default login/password

**login: admin@admin.fr**

**password: admin**	


^C to stop ./bin/app.pl


   
## How to use Redis ? ##

[Redis](http://redis.io/) is used you sore session information, this very fast server, whith this server you can share session on
multiple server to start high availability of your app. You can also ask to redis who is on line and more...


Redis

    yum install Redis on redhat/Centos

Or 
    apt-get install redis on Debian/Ubuntu

Add perl module: 

    cpanm Dancer::Session::Redis

Add vm.overcommit_memory = 1 à /etc/sysctl.conf

Or 

    sysctrl -w vm.overcommit_memory=1


    chkconfig redis on on redhat/Centos


redis.conf is in slowfox/doc/redis.conf


Redis password is not really necessary on dev server

uncomment  this section at end of config.yml

     redis_session:
         server: '127.0.0.1:6379'
         #password: 'Aemah3aiSahji5PoyeKae0maPhoo7oChOhK8ieyu'
         database: 0
         expire: 14400
         debug: 0
         ping: 5



check Redis is on line with this command

     [root@slowfox]# redis-cli
     redis 127.0.0.1:6379>

    

Stop and start ./bin/appl.pl --port=80 to test


If you have this error , check you redis config

     [root@slowfox]# ./bin/app.pl --port=80
     Could not connect to Redis server at 127.0.0.1:6379: Connexion refused at /usr/local/share/perl5/Dancer/Session/Redis.pm line 109.
            ...propagated at /usr/local/share/perl5/Redis.pm line 587.
     BEGIN failed--compilation aborted at ./bin/app.pl line 2. 




Voila...c'est tout pour aujourd'hui









