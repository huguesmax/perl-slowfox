package money30::generationpdf;
use Dancer ':syntax';
use Dancer::Plugin::Database;	#Connexion a la base de données Mysql
use DBI;			#Connexion a la base de données A SAV
use DateTime::Format::Strptime;	#Gestion des Date		
use Tie::IxHash;
use Dancer::Plugin::Ajax;	#Ajax
use Unix::Uptime;
use DateTime;                   # module Gestion des dates en Perl
use PDF::API2;                  # module creation pdf

my $IP          = config->{'IP'};
my $ODBC        = config->{'ODBC'};
my $PORT        = config->{'PORT'};
my $TVA         = config->{'TVA'};
my $PATHPDF     = config->{'PATHPDF'};

#Connexion à la base de données asv
#my $dbh = database('asav');
my $tab = 1;
my $bnp;



post '/generationpdf' => sub {
	my $row    =   database('asav')->quick_select("Securite", { Nom => params->{username}, MotPasse => params->{password}} );

	# si il y pas de réponse c'est que le couple Nom/MotPasse n'existe pas dans la base
        if (!$row) {
                return template 'money30/navbar_login' => {
                        show_warning => "Désolé Mauvais Login ou Mauvais Mot de passe !!",
                };
        }


	#my $sql = 'SELECT Ckey, dateTraitement, NumCmd, CodeClient, NumDossier, Fichier FROM CommandeBNP';
	#my $sth = $dbh->prepare($sql) or die $dbh->errstr;
	#$sth->execute or die $sth->errstr;

	my @allCommandeBNP = database('asav')->quick_select('CommandeBNP', {generationPDF =>'non'} ); 
	my $allCommandeBNP=@allCommandeBNP;
	
	# si il y pas de réponse c'est que le couple Nom/MotPasse n'existe pas dans la base
	if (!$row) {
		return template 'money30/navbar_login' => {
			show_warning => "Désolé Mauvais Login ou Mauvais Mot de passe !!",
		};
	}

	#Lancement des écheancier à traiter.	
	my $output = qx|perl /home/money30/echeancier.pl &|;

	#Retour la generation pdf
		 return template 'money30/generationpdf' => {
                        username =>  params->{username},
                        password =>  params->{password},
			output   =>  $output,
			bnp => \@allCommandeBNP,
                        show_status => "<h3>Il y a <span id='timestamp'> $allCommandeBNP </span> échéanciers a générer en des PDF</h3>",
        	};


	
};

ajax '/getloadavg' => sub {
	my $r=`tail /home/money30/PDF/echeancier.log`;
    {
        timestamp => time,
        flog => $r
    };
};

true;
