 
# SlowFOX Dance  #
> slow down your FireFox :-)

créé par Hugues MaX huguesmax[at]gmail.com

Basé le framwork Perl Dancer 1 [http://www.dancer.org](http://www.dancer.org)

Inspiré de [http://cowbell.cancan.cshl.edu/](http://cowbell.cancan.cshl.edu/)

Librement inspiré de [perlmaven.com](http://perlmaven.com/getting-started-with-perl-dancer-on-digital-ocean)

## SlowFOX c'est quoi ? ##

SlowFOX is une application web pour les entreprises développée avec le framwork Perl  Dancer  en version 1.
Pour le moment c'est une collection de page web pré formatées avec ces outils librement intégrés
 
- [Perl](http://www.perl.org)
- [Dancer framwork](http://perldancer.org/) 
- [Mysql](http://www.mysql.com/)
- [Redis Key-Value Session Store](http://redis.io/)
- [Twitter Bootstrap](http://getbootstrap.com/)
- [JQuery](http://jquery.com/)   



## Pourquoi le nom de slowFOX ? ##

voir les vidéos de la danse  [SlowFOX](https://www.google.com/webhp?output=googleabout&gws_rd=ssl#q=slowfox)

en + c'est rigolo....


## Mais je fais QUOI avec SlowFOX  ##

Ben.. c'est a vous de voir, mais mois ça me sert pour la construction d'intranet pour des entreprises 
(ou des applications métiers, c'est + la classe ... :-)


## Comment installer slowFOX ##

Vous avez besoin d'un linux récent basé sur ( Redhat 6.4/Centos 6.4/Fedora 18 ou  Debian 7 / Ubuntu 12/ 14 ) 


Pour la documentation, on part d'une installation minimale Centos ou Debian, il est possible de ne pas avoir besoin de tout installer.
Il ce peut que l'installation échoue - il ne faut pas paniquer c'est souvent un problème de bibiliothèque de developpement manquantes.


Redhat/Centos/Fedora :

	yum -y groupinstall development && yum -y groupinstall perl-runtine
	yum -y install Redis mysql-server mysql curl perl-ExtUtils* mysql-devel wget perl-IO-Socket-SSL 	

Debian/buntu :

	apt-get install libmodule-install-perl redis-server redis-doc mysql-server curl libmysqlclient-dev wget libio-socket-ssl-perl libnet-ssleay-perl libssl-dev


SlowFOX a besoin de Perl Dancer et de pas mal de modules Perl. Le + simple c'est installer 

[cpanminus](http://search.cpan.org/dist/App-cpanminus/lib/App/cpanminus.pm)

 
En tant que root ( ajouter sudo pour les "debianistes"  || les "ubuntuistes" )


    curl -L http://cpanmin.us | perl - App::cpanminus

Une fois cpanminus installé, installer les différents modules

    
    cpanm Dancer YAML Template JSON Redis Dancer::Session::Redis Dancer::Plugin::Database
    Dancer::Plugin::Auth::RBAC Crypt::Eksblowfish::Bcrypt DateTime::Format::Strptime Tie::IxHash Modern::Perl 	   
    DateTime::Format::MySQL   DateTime::Format::Duration Dancer::Plugin::Redis
    HTML::Strip Daemon::Control Net::Server

et


    cpanm Server::Starter 
    
    
et

    cpanm Net::Server::SS::PreFork

et

    cpanm Starman DBD::mysql


Bon, ça va être long...vous pouvez aller prendre un café

## Maintenant on peut démarrer ##


** clonner le projet **
    cd /home

    wget https://github.com/huguesmax/perl-slowfox/archive/master.zip -O slowfox.zip

    unzip slowfox.zip

    cd perl-slowfox-master


## Créer la base de données et charger les données ##


    service mysqld start	[OK]
    
    mysql
	mysql> create database slowfox;
	Query OK, 1 row affected (0.00 sec) 

    
    mysql> \quit
	Bye

Charger la base MySQL  ( pour le moment il y a seulement 2 tables: users and voip)

    mysql slowfox < doc/slowfox.sql

Nous utiliserons le login et mot de passe par default


login: root
et le mot de passe est vide

tester la connexion

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


Si vous souhaitez mettre un mot de passe  ( c'est mieux.... :-)  ) voir la doc de 

[MySQL](http://dev.mysql.com/doc/refman/5.0/fr/set-password.html)

et 

éditer le fichier config.yml, aller cette section

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



et modifier le username et password par celui de votre choix

Attention c'est un fichier [YAML](http://en.wikipedia.org/wiki/YAML), les espaces, les tabultations tout est important.


## Arreter le firewall et serveur web Linux  lancé par default  ##

il faut lancer ces commandes. ( A NE PAS FAIRE SUR VOTRE SERVEUR DE PRODUCTION )

    service iptables stop    [OK]
    service httpd stop       [OK]

## Mes premiers pas de danse. ##

Il me faut votre IP:

    ifconfig eth0
    eth0      Link encap:Ethernet  HWaddr 00:0C:29:5A:9C:1C
              inet adr:192.168.0.37  Bcast:192.168.0.255  Masque:255.255.255.0



dans cet exemple j'ai 192.168.0.37

lancer Perl Dancer, sur le port 80 ( par default il demarrera sur le port 3000  si on ne passe aucune option)


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


Aller sur l'adresse  http://192.168.0.37  ( remplacer  192.168.0.37 par votre adresse ip )

Login & Mot de passe par defaut:

**login: admin@admin.fr**

**pwd: admin**	

^C to stop dancer


## Comment utiliser Redis ? ##

[Redis](http://redis.io/)  est un serveur de clef/Valeur très rapide.

Il est utiliser pour stocker les informations de la session de vos utilisateurs. Il permet de commencer
a préparer la haute disponibilité de votre application en partagant ces infos de session sur plusieurs serveurs.


Redis

    yum install Redis on redhat/Centos

Ou
    apt-get install redis on Debian/Ubuntu

ajouter le module Perl:

    cpanm Dancer::Session::Redis

Ajouter

    vm.overcommit_memory = 1 à /etc/sysctl.conf

ou

    sysctrl -w vm.overcommit_memory=1


    chkconfig redis on (redhat/Centos)


redis.conf is in slowfox/doc/redis.conf


Le mot de passe Redis n'est pas vraiment nécessaire sur un serveur de dev.

Décommenté cette section à la fin du fichier config.yml



     redis_session:
         server: '127.0.0.1:6379'
         #password: 'Aemah3aiSahji5PoyeKae0maPhoo7oChOhK8ieyu'
         database: 0
         expire: 14400
         debug: 0
         ping: 5



Vérifier que redis fonctionne

     [root@slowfox]# redis-cli
     redis 127.0.0.1:6379>



arreter et démarrer 

     ^C

     ./bin/appl.pl --port=80


Si vous avez cette erreur c'est que la connexion n'est pas correcte , vérifié votre configuration


     [root@slowfox]# ./bin/app.pl --port=80
     Could not connect to Redis server at 127.0.0.1:6379: Connexion refused at /usr/local/share/perl5/Dancer/Session/Redis.pm line 109.
            ...propagated at /usr/local/share/perl5/Redis.pm line 587.
     BEGIN failed--compilation aborted at ./bin/app.pl line 2.


















