package slowfox::menu;
use Dancer ':syntax';
use Dancer::Plugin::Database;	#Connexion a la base de données Mysql
use DateTime::Format::Strptime;	#Gestion des Date		
use Dancer::Plugin::Ajax;
use Dancer::Plugin::Auth::RBAC;				# Gestion des Access ( Role Base Access )
use Dancer::Plugin::Auth::RBAC::Credentials::MySQL;	# RBAC MySQL
use Dancer::Plugin::Auth::RBAC::Permissions::Config;

my $dbname          = config->{'DBNAME'};

get '/accueil' => sub {

		return template 'slowfox/accueil' => {
        	};
	
		
};

get '/clients' => sub {

		return template 'slowfox/accueil' => {
        	};
	
		
};

get '/outils' => sub {

		return template 'slowfox/accueil' => {
        	};
	
		
};



get '/downloads' => sub {

		return template 'slowfox/accueil' => {
        	};
	
		
};


get '/prelevements' => sub {

		return template 'slowfox/accueil' => {
        	};
	
		
};





true;
