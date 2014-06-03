package slowfox;
use Dancer ':syntax';
use strict;
use warnings;
use utf8;
use Dancer::Plugin::Email;
use Cwd;
use Sys::Hostname;
use Dancer::Plugin::Database;				# Connexion à la base de données Mysql
use Dancer::Plugin::Auth::RBAC;				# Gestion des Access ( Role Base Access )
use Dancer::Plugin::Auth::RBAC::Credentials::MySQL;	# RBAC MySQL
use Crypt::Eksblowfish::Bcrypt;		         	# Encodage et salage des mots de passes
#use Dancer::Plugin::I18N;                              #Intenationalization for Dancer
#use experimental 'smartmatch';				# cpanm experimental and uncomment if you have warings


use admin::admin;		        # Page d'admin du site
use slowfox::accueil;			# Page accueil
#use slowfox::clients;			# Page clients
#use slowfox::outils;			# Page outils
#use slowfox::downloads;			# Page downloads 
#use slowfox::prelevement;		# Page historiques
#use slowfox::support;			# Page support


our $VERSION        = '0.11';
my $sessionDuration = 14400;	       # Durée des sessions en secondes = 4h
my $dbname          = config->{'DBNAME'};

# Pré traitement pour la gestion des sessions
#############################################
hook 'before' => sub {

	# Durée de vie de la session de 4h =14400 si dépassé on deconnect 
	if (session('Time') && session('Time') + $sessionDuration < time()) {
		var requested_path => request->path_info;
                request->path_info('/disconnect');
	}
 
	# Si l'username n'existe pas et si que l'on demande autre chose que /login
	if (! session('username') && request->path_info !~ m{^/login} ) { 
		var requested_path => request->path_info; 
		request->path_info('/login');
	} else {
		#redirect '/login';
		#redirect params->{path} || '/login';
		return template 'slowfox/login';
	}
}; 
##############################################

# Redirect par default sur accueil ( si connecté hook )
get '/' => sub {
         redirect params->{path} || '/accueil';
};


get '/login' => sub {
        # Display a login page; the original URL they requested is available as
        # vars->{requested_path}, so could be put in a hidden field in the form
        template 'slowfox/login', { path => vars->{requested_path} };
};


post '/login' => sub {


#Vérification de l'user ( Mot de passe chiffrés avec l'algorithme bcrypt  )
############################################################################

	my $user = auth( params->{username}, encrypt_password(params->{password}) );

	my $statut = database($dbname)->quick_select('users', { login => params->{username}  });

	if ( ! $user->errors && $statut->{disable} == 0 ) {

		my $ip               = request->remote_address();
		
		database($dbname)->quick_update('users', { login => params->{username}  }, { lastip => $ip });

                session username     => params->{username},
		session Time         => time();
		session ValueSession => 8;
		 
		debug "Connexion Ok pour User: ". params->{username} ." Password: ". params->{password};
				redirect params->{path} || '/accueil';

        } else {
		debug "Connexion Failed pour User: ". params->{username} ." Password: ". params->{password} . " Disable: ". $statut->{disable};
		if ( $statut->{disable} == 0 ) { 
			return template 'slowfox/login' => {
        	                         show_warning => " Désolé Mauvais Login ou Mauvais Mot de passe, Merci de contacter l'adminstrateur !! ",
                	                };
		} else {
			return template 'slowfox/login' => {
        	                         show_warning => " Désolé votre compte a été désactivé, Merci de contacter l'adminstrateur !! ",
                	                };

		}


        }
};

get '/disconnect' => sub {
		my $time     = session('Time');
		my $username = session('username');
		session->destroy();


		debug "Connexion finished for $username @ $time, bye";
		
		if ( $time + $sessionDuration < time() ) { 
			return template 'slowfox/login' => {
                                         show_warning => " ". $username. ", Votre Session a expiré, merci de vous reconnecter ",
	                };

		} else {
			return template 'slowfox/login' => {
					 show_warning => " ". $username. " , Vous êtes maintenant déconnectés de l'application ",
			};
		}
};

get '/password' => sub {
		  my $id = session('user')->{id} ;
		  debug "id user = $id";
		  		return template 'slowfox/password' => {
				  show_info => " Attention vous allez changer votre mot de passe. Merci de choisir un mot de passe avec des caractères spéciaux, 
				  des Majuscules / Minuscules, et/ou des Chiffres ",
                        };
 
};


post '/password' => sub {

		   my $password         =  params->{password};
		   my $password_confirm =  params->{password_confirm};

		   if ( length $password < 6 ) {
			return template 'slowfox/password' => {
				                   show_warning => "Echec de la mise a jour, votre mot de passe me semble un peu trop court.... ( mini 7 caractères )",
			};
		   }

		   # Les mots de passes correspondent
		   if ( $password eq $password_confirm ) {

			   my $id = session('user')->{id} ;
		           debug "id user = $id";

			   my $bcryptpassword = encrypt_password($password); 
			   debug "New password  $bcryptpassword\n";

			   database($dbname)->quick_update('users', { id => $id }, { password => $bcryptpassword });

	                   return template 'slowfox/password' => {
        	                                  show_success => " Votre mot de passe a bien été mis à jour.",
                           };

		  } else {
			   return template 'slowfox/password' => {
				                  show_warning => "Echec de la mise à jour,  les deux mots de passe ne correspondent pas. Ne le perdez pas :-)",
			   };

		 }


};

get '/profil' => sub {

		   my $id          = session('user')->{id} ;
		   my $user        = database($dbname)->quick_select('users', { id => $id });
		   my $ip          = request->remote_address();
		   my $userAgent   = request->user_agent();

                   return template 'slowfox/profil'    => {
			   		  name         => $user->{name},
			   		  prenom       => $user->{firstname},
			   		  roles        => $user->{roles},
					  ip           => $ip, 
					  userAgent    => $userAgent, 
                                          show_success => "Affichage du Profil",
                        };

};

get '/voip' => sub {

		   my $id           = session('user')->{id};
		   my $auth         = auth();
		   my $user         = database($dbname)->quick_select('users', { id => $id });
		   my $voip         = database($dbname)->quick_select('voip',  { id => $id });
		   my $ip           = request->remote_address();
		   my $userAgent    = request->user_agent();

		   #Ip autorisée a utiliser la voip
		   my @ALLOWEDIP    = split(",", config->{'ALLOWEDIP'} );
		   my $VOIPSERVER   = config->{'VOIPSERVER'};
		   my $VOIPPORT     = config->{'VOIPPORT'};
		   my $VOIPCODEC    = config->{'VOIPCODEC'};
		   my $STUNHOST     = config->{'STUNHOST'};
		   my $STUNPORT     = config->{'STUNPORT'};


		    if ( ! $auth->asa('voip') ) {
				   return template 'client/error' => {
				             show_warning => "Désolé il faut avoir le profil VOIP pour voir cette page. Merci de contacter l'adminstrateur",
				   };
		    }

		   if (  $ip ~~ @ALLOWEDIP ) {

			   return template 'voip/voip', {
				   		   name         => $user->{name}, 
						   fistname     => $user->{firstname},
						   voipName     => $voip->{name},
						   voipSecret   => $voip->{secret},
						   ip           => $ip,
						   userAgent    => $userAgent,
						   VOIPSERVER   => $VOIPSERVER,
                   				   VOIPPORT     => $VOIPPORT,
                   				   VOIPCODEC    => $VOIPCODEC,
                   				   STUNHOST     => $STUNHOST,
                   				   STUNPORT     => $STUNPORT,
			   }, { 
						   layout => 'main-voip' 
			   };

		    } else {

			  return template 'slowfox/error' => {
			            show_warning => "Désolé, vous avez bien le profil VOIP mais votre ip: $ip, n'est pas autorisée. Merci de contacter l'adminstrateur",
			  };
		    }
};


# Gestion des comptes utilisateurs
get '/manageaccount' => sub {
		   my $auth = auth();
		   my $id          = session('user')->{id};
		   my $user        = database($dbname)->quick_select('users', { id => $id });
		   my @users       = database($dbname)->quick_select('users', { } );
		   my $voip        = database($dbname)->quick_select('voip', { id => $id });

		   my $ip          = request->remote_address();
		   my $userAgent   = request->user_agent();


	  
		   # user n'est pas admin 
		   if ( ! $auth->asa('admin') ) {
				   return template 'slowfox/manageaccount' => {
				                show_warning => "Désolé vous n'êtes pas adminstrateur.",
			           };
		   } else {
				  return template 'slowfox/manageaccount' => {
					  	name         => $user->{name},
                                          	prenom       => $user->{firstname},
	                                        roles        => $user->{roles},
        	                                ip           => $ip,
                	                        userAgent    => $userAgent,
						users	     => \@users,
					  	show_success => "Bonjour Super Adminstrateur :-)",

				                                     };
		  }
		   
};		   



any  '/search' => sub {
       		my $auth = auth();
	  	my $search = params->{search};
		
		if (! $search ) {
			  return template 'slowfox/result' => {
	                                                       show_warning => "Désolé il n'y a pas de réponses",
		          };
		}

		#SEARCH FOR INGENICO BNP ONLY
		#############################
		my ( @resultC, @resultNom, @resultCC );
		my $motif;

		if ( $auth->asa('client.ingenico') ) {
		    if ( $search =~/^BNP/i) {
                       @resultCC  = database($dbname)->quick_select('ClientContrat', { NumContrat => { like => "$search%" } }, { limit => 10 } );
		       $motif=0;
		    } else {
		       @resultCC  = database($dbname)->quick_select('ClientContrat', { CodeClient => { like => "%$search%" }, NumContrat =>{ like =>"BNP%"}   }, { limit => 10 } );
		       $motif=1;
   		    }		       

			if ( @resultCC ) { 
				  return template 'client/result' => {
						     resultCC  => \@resultCC,
						     motif     => $motif,
				                     show_success => "Voici les resultats possibles ",
			           };

		
			} else {
				  return template 'client/result' => {
	                                                            show_warning => "Désolé il n'y a pas de réponses",
				                                     };
		        }
		}


		#SEARCH ALL USERS 
		#########################
	
		if ( $auth->asa('user')) {
			my $sql =qq/SELECT Client.CodeClient as CC, Client.NomClient,Client.Ville, ClientContrat.NumContrat FROM Client INNER JOIN  ClientContrat 
			          ON (Client.CodeClient = ClientContrat.CodeClient) 
				  WHERE Client.CodeClient LIKE ? LIMIT 10/;

			@resultCC  = database($dbname)->quick_select('ClientContrat', { NumContrat => { 'like' => "%$search%" } }, { limit => 10 } );
			
			$search ='%'. $search. '%';
			my $sth = database($dbname)->prepare($sql);
			$sth->execute($search);
			#@resultC = $sth->fetchall_arrayref;

	       		 if ( @resultCC ) { 
				  return template 'slowfox/result' => {
					  	     resultC      => $sth->fetchall_arrayref({}),
						     resultCC     => \@resultCC,
						     resultNom    => \@resultNom,
				                     show_success => "Voici les resultats possibles ",
			           };

		
			} else {
				  return template 'slowfox/result' => {
	                                                            show_warning => "Désolé il n'y a pas de réponses",
				                                     };
		        }
		}	
};





################## SUB ###############################
#Fonction de cryptage et de salage des mots de passes 

sub encrypt_password {
	  my $password = shift;
	  # obtenir le sel de l'application # 16
	  my $salt = config->{'salt'}; 

	  # Set the cost to 10 and append a NUL
	  my $settings = '$2a$10$'.$salt;

	  # Encrypt it
	  return Crypt::Eksblowfish::Bcrypt::bcrypt($password, $settings);
}



sub trim {
        my $string = shift;
        $string =~ s/\s+//g;
        return $string;
}



true;

