package admin::admin;
use Dancer ':syntax';
use strict;
use warnings;
use utf8;
use Dancer::Plugin::Email;
use Dancer::Plugin::Database;				# Connexion à la base de données Mysql
use Dancer::Plugin::Auth::RBAC;				# Gestion des Access ( Role Base Access )
use Dancer::Plugin::Auth::RBAC::Credentials::MySQL;	# RBAC MySQL
use Crypt::Eksblowfish::Bcrypt;		         	# Encodage et salage des mots de passes
use Data::Dumper;

my $dbname          = config->{'DBNAME'};

#Vérification du chemin passé,  si il contient  /admin l'user doit avoir le role admin
# Sinon c'est une tentative de hack

hook 'before' => sub {

         my $auth = auth();

         if ( request->path_info() =~ /^\/admin/  && $auth->asa('admin') == 0 ) {
                 debug "Attention problème de sécurité dans la partie admin pour user: ";
		 debug session('login') if session('login');
                 redirect '/accueil';

        }


};

# Gestion des comptes utilisateurs
get '/admin/manageaccount' => sub {

		   my $auth = auth();
		   my $id          = session('user')->{id};
		   my $user        = database($dbname)->quick_select('users', { id => $id });
		   my @users       = database($dbname)->quick_select('users', { } );
		   #my $voip        = database($dbname)->quick_select('voip', { id => $id });

		   my $ip          = request->remote_address();
		   my $userAgent   = request->user_agent();
		   my $idSession = session('id');
		  
		   # use Dancer::Plugin::Redis;
		   # use Storable;

		   #Séléctionner la bonne base redis ( la base des sessions c'est la 1 ) 
		    #my $select = redis->select(1);
		    #my $connectedUser = redis->keys('*'); # Compte le nombre de clef
		    #my $redis = Storable::thaw(redis->get($idSession)); # retourne le contenu de la clef de session dé serilalisé

		   # user n'est pas admin 
		   if ( ! $auth->asa('admin') ) {
				   return template 'admin/manageaccount' => {
				                show_warning => "Désolé vous n'êtes pas adminstrateur.",
			           };
		   } else {
				  return template 'admin/manageaccount' => {
					  	name         => $user->{name},
                                          	firstname    => $user->{'firstname'},
	                                        roles        => $user->{'roles'},
        	                                ip           => $ip,
                	                        userAgent    => $userAgent,
						users	     => \@users,
						#redis        => $redis,
						#idSession    => $idSession,
					  	show_success => "Bonjour Adminstrateur :-)",

				                                     };
		  }
		   
};		   

# formulaire pour mettre a jour un mot de passe
get '/admin/password/:idUser' => sub {
                  my $idUser = params->{'idUser'}; 
		  my @users       = database($dbname)->quick_select('users', { } );
		  my $user        = database($dbname)->quick_select('users', { id => $idUser });

                  debug "id user = $idUser";
                                return template 'admin/manageaccount' => {
					  updatePassword => 1,
					  username       => $user->{login},
					  name           => $user->{name},
					  firstname      => $user->{firstname},
					  roles          => $user->{roles},
					  idUser         => $idUser,
					  users	         => \@users,

                                	  show_info => " Attention vous allez changer votre mot de passe. Merci de choisir un mot de passe avec des caractères spéciaux,
                                  des Majuscules / Minuscules, et/ou des Chiffres ",
                        };

};

# post pour la mise a jour du mot de passe
post '/admin/password' => sub {

		   my $idUser           =  params->{'idUser'};
                   my $password         =  params->{password};
                   my $password_confirm =  params->{password_confirm};
		    my @users           =  database($dbname)->quick_select('users', { } );

                   if ( length $password < 1 ) {
                        return template 'admin/manageaccount' => {
					users        => \@users,
                                        show_warning => "Echec de la mise a jour, votre mot de passe me semble un peu trop court.... ( mini 7 caractères )",
                        };
                   }

                   # Les mots de passes correspondent
                   if ( $password eq $password_confirm ) {

                           my $id = session('user')->{id} ;
                           debug "idUser = $idUser";

                           my $bcryptpassword = encrypt_password($password);
                           debug "New password  $bcryptpassword\n";

                           database($dbname)->quick_update('users', { id => $idUser }, { password => $bcryptpassword });

                           return template 'admin/manageaccount'  => {
				   		users        => \@users,
                                                show_success => " Le mot de passe a bien été mis à jour.",
                           };

                  } else {
                           return template 'admin/manageaccount'  => {
				   		users        => \@users,
                                                show_warning => "Echec de la mise à jour,  les deux mots de passe ne correspondent pas. Merci de recommencer",
                           };

                 }
};



#Formulaire pour editer un user 
get '/admin/updateuser/:idUser' => sub {

		  my $idUser      = params->{'idUser'} // ''; 
		  my @users       = database($dbname)->quick_select('users', { } );
		  my $user        = database($dbname)->quick_select('users', { id => $idUser });

                         return template 'admin/manageaccount' => {
					  updateuser   => 1,
					  idUser       => $idUser,
					  login        => $user->{login},
 					  name         => $user->{name},
                                          firstname    => $user->{'firstname'},
					  users	       => \@users,

                                	  show_info => " Attention vous allez un utilisateur",
                        	};

};

# Mise a jour du user 
post '/admin/updateuser' => sub {

		  my $idUser     = params->{'idUser'} // '';
		  my $login      = params->{'email'} // '';
		  my $firstname  = params->{'firstname'} // '';
		  my $name       = params->{'name'} // '';

		  $name      = uc($name);
                  $firstname = ucfirst($firstname);			
		  $login     = lc($login);

		  #debug "$idUser | $login | $firstname |  $name";

		  if ( $idUser && $login && $firstname && $name ) {

			  database($dbname)->quick_update('users', { id => $idUser }, { name => $name, firstname => $firstname, login=> $login  });
			  my @users       = database($dbname)->quick_select('users', { } );
			  my $user        = database($dbname)->quick_select('users', { id => $idUser });

                         return template 'admin/manageaccount' => {
					  id	       => $idUser,
					  login        => $user->{login},
 					  name         => $user->{name},
                                          firstname    => $user->{'firstname'},
					  users	       => \@users,

                                	  show_success => " L'utilisateur $idUser à bien été mis à jour",
                        	};



		} else {

			 my @users       = database($dbname)->quick_select('users', { } );
                         return template 'admin/manageaccount' => {
					  users	       => \@users,

                                	  show_warning => " Erreur l'utilisateur  $idUser n'a pas été mis à jour",
                        	};


		}


};




#Formulaire pour créer un nouvel utilisateur
get '/admin/createaccount' => sub {

		  my @users       = database($dbname)->quick_select('users', { } );
		  my $ROLE_LIST   = config->{'ROLE_LIST'}; 

                                return template 'admin/manageaccount' => {
					  createaccount  => 1,
					  users	         => \@users,
					  roleList	 => $ROLE_LIST,

                                	  show_info => " Attention vous allez créer un nouvel utilisateur",
                        };

};


# Post pour la création d'un nouvel utilisateur
post '/admin/createaccount' => sub {

                  my $login      = params->{'email'} // '';
                  my $firstname  = params->{'firstname'} // '';
                  my $name       = params->{'name'} // '';

		  $name      = uc($name);
		  $firstname = ucfirst($firstname);
		  $login     = lc($login);

		  my $ROLE_LIST   = config->{'ROLE_LIST'}; 

		  # Vérfication si l'user existe deja

		  	 my $checkUser        = database($dbname)->quick_select('users', { login => $login });




		  if ( ! $login || ! $firstname || ! $name ) {

		  		my @users       = database($dbname)->quick_select('users', { } );
                                return template 'admin/manageaccount' => {
					  createaccount  => 1,
					  users	         => \@users,
					  roleList	 => $ROLE_LIST,

                                	  show_warning => " Erreur nous ne pouvons pas enregister des informations [ $name | $firstname | $login ] ",
                        };

		} elsif ( $checkUser->{login} ) {


				 my @users       = database($dbname)->quick_select('users', { } );
                                return template 'admin/manageaccount' => {
					  createaccount  => 1,
					  users	         => \@users,
					  roleList	 => $ROLE_LIST,

                                	  show_warning => " Erreur cet utilisateur $login existe déja",
                        };

				



		 } else {
		
			  my $newRole;
			
			  # On parcours $ROLE_LIST et on attrappe les parametes passer dans le post
			  # Puis on ajoute chaque element a la liste newRole

			  foreach my $roles ( keys %{$ROLE_LIST} ) {
		  		  my $value = params->{$roles} // '';
			  		if ( $value && $value eq 'on' ) { 
						 $newRole .= $roles.",";
					} 
			  }
		  	  #suppression de la dernière virgule
		          $newRole = substr($newRole, 0, -1) if $newRole;

	  		  if ( $newRole && $newRole ne "" ) {  

				my $password = generatePassword();
				my $encrypt_password = encrypt_password($password);

				# Mise a jour de la base de données 
				database($dbname)->quick_insert('users', { name => $name , login => $login, firstname => $firstname, 
										       password => $encrypt_password , roles => $newRole  } );

				#Consultation de la base mis a jour	
		  		my @users       = database($dbname)->quick_select('users', { } );

                                return template 'admin/manageaccount' => {
					  users	         => \@users,

                                	  show_success => " Création de l'utilisateur  $firstname $name : Email : $login avec le mot de passe: $password  ",
                                };

			} else {


				my @users       = database($dbname)->quick_select('users', { } );
                                return template 'admin/manageaccount' => {
						  createaccount  => 1,
						  users	         => \@users,
					  	  roleList	 => $ROLE_LIST,

                                	         show_warning => " Erreur, je ne peux pas crée un utilisateur sans droit, merci de séléctionner un droit",
                                };




			}	





		}


};

#Désactiver un utilisateur
get '/admin/disable/:idUser' => sub {
                  my $auth        = auth();
                  my $idUser      = params->{'idUser'}; 

		  database($dbname)->quick_update('users', { id => $idUser }, { disable => 1 }) if $idUser;

		  my @users       = database($dbname)->quick_select('users', { } );
		  my $user        = database($dbname)->quick_select('users', { id => $idUser });



                                return template 'admin/manageaccount' => {
					  username       => $user->{login},
					  name           => $user->{name},
					  firstname      => $user->{firstname},
					  roles          => $user->{roles},
					  idUser         => $idUser,
					  users	         => \@users,

                                	  show_success => " L'utilisateur $user->{firstname} $user->{name} est maintenant désactivé",
                        };

};

#Activier l'utilisateur
get '/admin/enable/:idUser' => sub {
                  my $auth        = auth();
                  my $idUser      = params->{'idUser'}; 

		  database($dbname)->quick_update('users', { id => $idUser }, { disable => 0 }) if $idUser;

		  my $user        = database($dbname)->quick_select('users', { id => $idUser });
		  my @users       = database($dbname)->quick_select('users', { } );

                                return template 'admin/manageaccount' => {
					  username       => $user->{login},
					  name           => $user->{name},
					  firstname      => $user->{firstname},
					  roles          => $user->{roles},
					  idUser         => $idUser,
					  users	         => \@users,

                                	  show_success => " L'utilisateur $user->{firstname} $user->{name} est maintenant activé",
                        };


};

# Formulaire pour changer les roles 
get '/admin/roles/:idUser' => sub {

                  my $idUser      = params->{'idUser'}; 
		  my @users       = database($dbname)->quick_select('users', { } );
		  my $user        = database($dbname)->quick_select('users', { id => $idUser });
		  my @roleActuel  = split(",", $user->{roles} );
		  my $ROLE_LIST   = config->{'ROLE_LIST'}; 

                  debug "id user = $idUser";
                                return template 'admin/manageaccount' => {
					  rolesUpdate    => 1,
					  username       => $user->{login},
					  name           => $user->{name},
					  firstname      => $user->{firstname},
					  roles          => $user->{roles},
					  idUser         => $idUser,
					  users	         => \@users,
					  roleList	 => $ROLE_LIST,
					  roleActuel     => \@roleActuel,

                                	  show_info => " Attention vous allez changer les droits de $user->{firstname} $user->{name}",
                        };

};


# Mise a jour des roles
post '/admin/updateroles' => sub {
                  my $auth        = auth();
                  my $idUser      = params->{'idUser'} // '';
		  
		  #my @roleActuel  = split(",", $user->{roles} );
		  my $ROLE_LIST   = config->{'ROLE_LIST'};
		  my $newRole;
			
		  # On parcours $ROLE_LIST et on attrappe les parametes passer dans le post
		  # Puis on ajoute chaque element a la liste newRole

		  foreach my $roles ( keys %{$ROLE_LIST} ) {
		  	  my $value = params->{$roles} // '';
			  	if ( $value && $value eq 'on' ) { 
					 $newRole .= $roles.",";
				} 
		  }
		  #suppression de la dernière virgule
		  $newRole = substr($newRole, 0, -1) if $newRole;

		  #debug "id user = $idUser";
		  #debug $newRole;
                
		  if ( $newRole && $newRole ne "" && $idUser) {  

				# Mise a jour de la base de données 
				database($dbname)->quick_update('users', { id => $idUser }, { roles => $newRole });

				#Consultation de la base mis a jour	
			      	my $user        = database($dbname)->quick_select('users', { id => $idUser });
		  		my @users       = database($dbname)->quick_select('users', { } );
		 
                                return template 'admin/manageaccount' => {
					  username       => $user->{login},
					  name           => $user->{name},
					  firstname      => $user->{firstname},
					  roles          => $user->{roles},
					  idUser         => $idUser,
					  users	         => \@users,

                                	  show_success => " Les droits de $user->{firstname} $user->{name} (id n° $idUser )  ont été mis à jour [ $newRole ]",
                                };


		} else { 
				#Consultation de la base mis a jour	
			      	my $user        = database($dbname)->quick_select('users', { id => $idUser });
		  		my @users       = database($dbname)->quick_select('users', { } );
		 

		         return template 'admin/manageaccount' => {
					  username       => $user->{login},
					  name           => $user->{name},
					  firstname      => $user->{firstname},
					  roles          => $user->{roles},
					  idUser         => $idUser,
					  users	         => \@users,

                                	  show_warning => " Erreur les droits de $user->{firstname} $user->{name} (id n° $idUser ) ne peuvent pas être vide",
                                };


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



#Générer un mot de passe aléatoire de 8 caractères non confusant
################################################################

sub generatePassword {
   my $length = 9;
   my $possible = 'abcdefghijkmnpqrstuvwxyz23456789ABCDEFGHJKLMNPQRSTUVWXYZ#$';

   my $password = substr($possible, (int(rand(length($possible)))), 1);

   	while (length($password) < $length) {
     	$password .= substr($possible, (int(rand(length($possible)))), 1);
   	}

   return $password
 } 








true;

