package slowfox::accueil;
use Dancer ':syntax';
use Dancer::Plugin::Database;	#Connexion a la base de données Mysql
use DBI;			#Connexion a la base de données A SAV
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
true;
