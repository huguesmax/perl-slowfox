package money30::downloads;
use Dancer ':syntax';
use Dancer::Plugin::Database;	#Connexion a la base de données Mysql
use DBI;			#Connexion a la base de données A SAV
use DateTime::Format::Strptime;	#Gestion des Date		
use Tie::IxHash;
use Dancer::Plugin::Ajax;



get '/downloads' => sub {
		return template 'money30/downloads' => {
		};
       
	
};
true;
