package slowfox::clients;
use utf8;
use Dancer ':syntax';
use Dancer::Plugin::Database;	#Connexion a la base de données Mysql
use Dancer::Plugin::Auth::RBAC;                         # Gestion des Access ( Role Base Access )
use Dancer::Plugin::Auth::RBAC::Credentials::MySQL;     # RBAC MySQL
use Dancer::Plugin::Auth::RBAC::Permissions::Config;

my $dbname          = config->{'DBNAME'};


get '/clients' => sub {
		return template 'money30/clients' => {
		};
       
	
};

get '/detailClient/:CodeClient' => sub {
				
		my $user = auth;
		my $CodeClient = params->{'CodeClient'};
		my ( @resultC, @resultCC, @resultCP , @resultCPre);
		my ( %h_PR, %h_statut);
		if ( ! $user->asa('user') ) { 
				return template 'money30/accueil' => {
						 show_warnig => "Désolé mais vous n'avez pas les droits pour consulter cette page - Merci de contacter l'adminstrateur."
				};
		}


		#Recherche des infos sur le client
		if ( $CodeClient ) {

			my ($h_PR, $h_statut )  = getDetailPrelevement($CodeClient);				
			 %h_PR                  = %$h_PR;         # on dé reférence le hash
			 %h_statut              = %$h_statut;     # on dé reférence le hash

			@resultC     = database($dbname)->quick_select('Client', { CodeClient => $CodeClient }, { limit => 1 } );
			@resultCC    = database($dbname)->quick_select('ClientContrat', { CodeClient => $CodeClient } , { order_by =>{ desc => 'DateRenouvellement'}  }  );
			@resultCP    = database($dbname)->quick_select('ClientParcComplet', { CodeClient => $CodeClient }  );
			@resultCPre  = database($dbname)->quick_select('ClientPrelevement', { CodeClient => $CodeClient }, { order_by =>{ desc => 'DatePrelevement'}  }  );

		

		
		} else {
			return template 'money30/accueil' => {
	                                          show_warnig => "Désolé mais vous n'avez pas les droits pour consulter cette page - Merci de contacter l'adminstrateur."
			};
		}

														 
		return template 'money30/detailClient' => {
						CodeClient   => $CodeClient,
						resultC      => \@resultC,
						resultCC     => \@resultCC,
						resultCP     => \@resultCP,
						resultCPre   => \@resultCPre,
						h_PR	     => \%h_PR,
						h_statut     => \%h_statut,			
						show_success => "Vous consultez le Client  N°  $CodeClient"		

		};
		
};







true;
