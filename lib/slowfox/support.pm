package money30::support;
use Dancer ':syntax';
use Dancer::Plugin::Database;	#Connexion a la base de données Mysql
use DBI;			#Connexion a la base de données A SAV
use DateTime::Format::Strptime;	#Gestion des Date		
use Tie::IxHash;
use Dancer::Plugin::Ajax;


my $IP          = config->{'IP'};
my $ODBC        = config->{'ODBC'};
my $PORT        = config->{'PORT'};




get '/support' => sub {
		return template 'money30/support' => {
		};
       
	
};
true;
