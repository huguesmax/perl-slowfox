package money30::outils;
use Dancer ':syntax';
use Dancer::Plugin::Database;	#Connexion a la base de données Mysql
use DBI;			#Connexion a la base de données ASAV
use DateTime::Format::Strptime;	#Gestion des Date		
use Tie::IxHash;
use Dancer::Plugin::Ajax;



my $tab = 1;
my $bnp;



get '/outils' => sub {

	my @allCommandeBNP = database('asav')->quick_select('CommandeBNP', {generationPDF =>'non'} ); 
	my $allCommandeBNP=@allCommandeBNP;
	$tab = 3 if $allCommandeBNP >0;
	

	#Affichage de la liste des commandes a traiter
	if (params->{cmd} && params->{cmd} eq 'list') {
		 return template 'money30/outils' => {
                        tab      =>  3,
			cmd	 => 'list',
			bnp => \@allCommandeBNP,
                        show_list => "<h3>Liste des commandes BNP</h3>",
        	};
	}

# Si il y a des commande je retourne le bouton à cliquer.
	if ($allCommandeBNP > 0) {
		return template 'money30/outils' => {
				tab      =>  $tab,
				show_loader => "Charger la liste des échéanciers a traiter [ $allCommandeBNP ]",
		};
	}

	if ($allCommandeBNP == 0) {
		return template 'money30/outils' => {
                                tab      =>  $tab,
				show_void  => "Il n'y a pas d'échanciers a traiter",	
		};
       }

	
};

post '/outils' => sub {

	my @allCommandeBNP = database('asav')->quick_select('CommandeBNP', {generationPDF =>'non'} );
        my $allCommandeBNP=@allCommandeBNP;
        $tab = 3 if $allCommandeBNP >0;

	#Affichage de la liste des commandes a traiter
        if (params->{cmd} && params->{cmd} eq 'list') {
                 return template 'money30/outils' => {
                        tab      =>  3,
                        cmd      => 'list',
                        bnp => \@allCommandeBNP,
                        show_list => "<h3>Liste des commandes BNP</h3>",
                };
        }
};



get '/echeancier/:Ckey' => sub {

	 my $Ckey      = params->{Ckey};
	 my $Suivant   = $Ckey+1;
	 my $Precedent = $Ckey-1; 

	 #Recupérer le code Client de la base mysql depuis Ckey


	 my $line       = database('asav')->quick_select('CommandeBNP', {Ckey => params->{Ckey} } );
	 my $CodeClient = $line->{'CodeClient'};
	 my $NumContrat =  'BNP'.$line->{'NumCmd'}; 
#Connexion a la base AccessSAV

		my $dsn      = "DBI:Proxy:hostname=;port=;dsn=DBI:ODBC:";
		my $dbha = DBI->connect($dsn, "", "");
		
		if (!$dbha) {	return template 'money30/error' => {
			 			 show_error => "Erreur de connexion à la base de données Microsoft Access SAV <br/>
								[ Adresse   ] <br />
								Impossible de continuer, merci de contracter l'adminstrateur. "
							 };
		}

		#Update des pramètres de commit et d'erreur.
	        $dbha->{AutoCommit} = 1;			
	        $dbha->{RaiseError} = 1;

		#my $dbha = database('Access');
		

#Rechercher les infos dans la table Client
		my ($NomClient, $Adresse, $Ville, $CodePostal, $NomClientF, $AdresseF, $VilleF, $CodePostalF, $RIB );
		my $sql =q/SELECT NomClient, Adresse, Ville, CodePostal, NomClientF, AdresseF, VilleF, CodePostalF, RIB FROM Client WHERE CodeClient=?/;
		my $stha = $dbha->prepare($sql);
                
		$stha->execute($CodeClient);
		while (my @row=$stha->fetchrow_array()){ $NomClient   = $row[0];
							 $Adresse     = $row[1];
							 $Ville       = $row[2];
							 $CodePostal  = $row[3];
							 $NomClientF  = $row[4];
							 $AdresseF    = $row[5];
							 $VilleF      = $row[6];
							 $CodePostalF = $row[7];
							 $RIB         = $row[8];

                }
		debug "DEBUG0 $NomClient - $Adresse - $Ville - $CodePostal - $NomClientF - $AdresseF - $VilleF - $CodePostalF - $RIB";

#Rechercher les infos dans la table ClientContrat Avec le N° de Contrat ( le client peux avoir plusieurs contrat )
		my ($TypeContrat, $DateRenouvellement, $DateEffet, $DateEchéance, $PrixTotal );
                $sql =q/SELECT TypeContrat, DateRenouvellement, DateEffet, DateEchéance, PrixTotal FROM ClientContrat WHERE NumContrat=?/;
                $stha = $dbha->prepare($sql);
                $stha->execute($NumContrat);

                while (my @row=$stha->fetchrow_array()){ $TypeContrat            = $row[0];
                                                         $DateRenouvellement     = $row[1];
                                                         $DateEffet              = $row[2];
                                                         $DateEchéance           = $row[3];
                                                         $PrixTotal              = sprintf("%.2f", $row[4] );

                }

		debug "DEBUG1: $TypeContrat - $DateRenouvellement - $DateEffet - $DateEchéance - $PrixTotal ";
	
		 if (!$DateEffet) {   return template 'money30/error' => {
                                                 show_error => "Attention Erreur impossible de definir la Date d'etffet pour le Contrat: $NumContrat<br/>
                                                                Impossible de continuer, merci de contracter l'adminstrateur. "
                                                         };
                }



# Rechercher les infos dans la table ClientParc avec le N° de Client & le N° de Contrat

		my (%Equipement, %Forfait );
		my $TotalMaintenance = 0;
                $sql =q/SELECT Spécifique, Quantité, PrixMaintenance FROM ClientParcParcComplet WHERE NumContrat=? AND CodeClient=? /;
                $stha = $dbha->prepare($sql);
                $stha->execute($NumContrat, $CodeClient );
		while (my ($Specifique, $Quantite, $PrixMaintenance) = $stha->fetchrow_array()) {
 
			if ( $Specifique =~/LOG/i && $PrixMaintenance == 0) { } else {
				 $Equipement{$Specifique} = {  
							Specifique      => $Specifique,  
							Quantite        => $Quantite *1, 
				 			PrixMaintenance => $PrixMaintenance
				}
			}
 			$PrixMaintenance=$PrixMaintenance*1;

			if ( $Specifique =~/LOG/i) { } else {

				if ($PrixMaintenance != 0) {
	                                 $Forfait{$Specifique} = {
        	                                                Specifique      => $Specifique,
                	                                        Quantite        => $Quantite *1,
                        	                                PrixMaintenance => $PrixMaintenance*1
	                                 }
				}
				$TotalMaintenance = $TotalMaintenance + $PrixMaintenance;
                        }


		debug "DEBUG2: $Specifique - $Quantite - $PrixMaintenance - $TotalMaintenance";

		}	

# Calcul des échanciers
		my $NombrePrelevement;
                if ($TypeContrat =~/3/) { $NombrePrelevement = 12;}
                if ($TypeContrat =~/4/) { $NombrePrelevement = 16;}
                if ($TypeContrat =~/5/) { $NombrePrelevement = 20;}
		debug "DEBUG3: $NombrePrelevement - $NombrePrelevement";
		
		tie(my %Echeancier, 'Tie::IxHash');
		my $tva = config->{'TVA'};
		my ($montantTotalHT, $montantTVA, $montantTTC);

                #my $analyseur = DateTime::Format::Strptime ->new( pattern => '%d%m/%Y');
                my $analyseur = DateTime::Format::Strptime ->new( pattern => '%Y-%m-%d %H:%M:%S');
		my $dt        = $analyseur->parse_datetime($DateEffet);
                my $DE    = $dt->dmy('/');
		my $dt2;	

                for(my $p=1; $p <= $NombrePrelevement; $p++) {

                        if ($p==1) { $montantTotalHT = sprintf("%.2f", $PrixTotal * 3 + $TotalMaintenance); }
			else 
				   { $montantTotalHT = sprintf("%.2f", $PrixTotal * 3); 
 			}
				     	
			$montantTVA = sprintf("%.2f", $montantTotalHT * $tva);
			$montantTTC = sprintf("%.2f", $montantTotalHT + $montantTVA);

                        #Remplir le Hash
                        $Echeancier{$p} = {     datePrelemvement => $DE,
                                                nombreMensualite => 3,
                                                montantTotalHT   => $montantTotalHT,
                                                montantTVA       => $montantTVA,
                                                montantTTC       => $montantTTC
                        };

                        #Ajouter 3 mois
			#$dt2 = $dt->clone();
                        $DE = $dt->add( months => 3);
			$DE    = $dt->dmy('/');

                }





		#$sql =q/SELECT Spécifique, Quantité, PrixMaintenance FROM ClientParc WHERE NumContrat=? AND CodeClient=300500 /;
		#my $linee       = database('Access')->execute($sql);
		
		

		return template 'money30/echeancier' => {
                        	 line               => $line,		#Objet
				 NumContrat         => $NumContrat,
				 NomClient          => $NomClient,	
				 Adresse            => $Adresse,
				 Ville              => $Ville,
				 CodePostal         => $CodePostal, 
				 NomClientF         => $NomClientF,
				 AdresseF           => $AdresseF,
				 VillesF            => $VilleF,
				 CodePostalF        => $CodePostalF,
				 RIB                => $RIB,

				 TypeContrat        => $TypeContrat,
				 DateRenouvellement => $DateRenouvellement,
				 DateEffet          => $DateEffet,
				 DateEchéance       => $DateEchéance,
				 PrixTotal          => $PrixTotal,
				 Tva		    => 100*$tva,

 				 Equipement         => \%Equipement,
 				 Forfait            => \%Forfait,
				 Echeancier         => \%Echeancier,

				 Ckey               => $Ckey,
				 Suivant            => $Suivant,
				 Precedent          => $Precedent,
	                         show_loader        => "Echéancier N° $Ckey",
	        };

};	


# Upload des fichiers
post '/upload_file_new_client' => sub {
	my $username = param 'username' ;
	
	my $file = request->upload('filename'); 

	my $fh       = $file->file_handle; 		# Handle du fichier
	my $size     = $file->size; 	   		# taille du fichier
	my $filename = $file->filename;			# Nom du fichier envoyé par le client
	my $tempname = substr($file->tempname,5);	# Nom du fichier sur le disque ( substr supprime le /tmp/) avec extension contrairement à la doc 
	my $path     = '/home/money30/DancerM30/public/tmp/';
	$file->copy_to($path);

	return template 'money30/outils' => {
		username => $username,
		show_success => "Chargement du fichier $filename --> [OK]",
                };

	
        };
 

post '/upload_file_impaye' => \&loadImpaye;


true;



###########################################################################################################
#   _____  ____  _    _  _____   _____  _____   ____   _____ _____           __  __ __  __ ______  _____  #
#  / ____|/ __ \| |  | |/   ____| |  _\|  __ \ / __ \ / ____|  _   \   /\   |  \/  |  \/  |  ____|/ ____| #
# | (___ | |  | | |  | | (___   | |__) | |__) | |  | | |  __| |__) |  /  \  | \  / | \  / | |__  | (___   #
#  \___ \| |  | | |  | |\___ \  |  ___/|  _  /| |  | | | |_ |  _  /  / /\ \ | |\/| | |\/| |  __|  \___ \  #
#  ____) | |__| | |__| |____) | | |    | | \ \| |__| | |__| | | \ \ / ____ \| |  | | |  | | |____ ____) | #
# |_____/ \____/ \____/|_____/  |_|    |_|  \_\\____/ \_____|_|  \_/_/    \_|_|  |_|_|  |_|______|_____/  #
#                                                                                                         #
###########################################################################################################
sub loadImpaye {
	my $username = param 'username' ;
        my $file     = request->upload('filename');
        my $fh       = $file->file_handle;              # Handle du fichier
        my $size     = $file->size;                     # taille du fichier
        my $filename = $file->filename;                 # Nom du fichier envoyé par le client
        my $tempname = substr($file->tempname,5);       # Nom du fichier sur le disque ( substr supprime le /tmp/) avec extension contrairement à la doc
        my $path     = '/home/money30/DancerM30/public/tmp/';
	my $fileCom  = $path.$tempname;

        $file->copy_to($path);
        debug "DEBUG4: fichier charger: Nom d'origine $filename Fichier sur le Disque: $path"."$tempname ";

#        return template 'money30/outils' => {
#                username => $username,
#                show_success => "Chargement du fichier d'impayé $filename --> [OK]",
#                };

	# Requetes SQL sur la table Client:
	my $sql_Client      = qq/UPDATE Client SET Client.CoteFinancière='IMPAYE' WHERE CodeClient= ?/;
	# Requetes SQL sur la table ClientContrat ( 2 cas possibles Soit le Champs et defini, soit il ne l'est pas)
	my $sql_NumContrat_defined  = qq/UPDATE ClientContrat SET Condition= Condition + ? WHERE NumContrat = ?/;
	my $sql_NumContrat_undefined  = qq/UPDATE ClientContrat SET Condition= ? WHERE NumContrat = ?/;


#Vérification du type de fichier
	if ($filename =~/\.txt$/i) {
	} else { 
		 return template 'money30/outils' => {
		 username => $username,
                 show_warning => "Erreur, le fichier $filename n'est pas un fichier texte -->[ ERREUR ]",
                };
	} 


# Parcours du fichier TXT et Vérification des données dans la base de données
# ###########################################################################
   open (FILE, $fileCom) ||  return template 'money30/outils' => {
                 username => $username,
                 show_warning => "Erreur, impossible d'ouvrir le fichier  $filename -->[ ERREUR ]",
                };
   my $return;

        while (<FILE>) {
        chomp;
                my  ($date, $societe, $adresse, $vide , $codepostal, $ville, $datep, $montant, $codetri, $CodeClient, $NumContrat, $CodeBanque, $CodeAgence, $Compte , $Motif_refus, $Champs16, $Champs17) = split(";");

        	if ( $Champs16 =~/^(REPRES LOYER)/i ||
	             $Champs16 =~/^(INDEMNITES DE RESILIATION)/i ||
	             $Champs16 =~/^(INDEMNITES DE NON RETOUR TPE)/ ) {
                     $return .= "Ligne non Traitée:( $1 ) $date\t $CodeClient $NumContrat $societe $montant $Motif_refus $Champs16\n";
                     next;
        	} else {
                     $return .= "$date $CodeClient $NumContrat $societe $montant $Motif_refus $Champs16\n";
                }

	}


	return template 'money30/outils' => {
                 username => $username,
		 retour   => $return,
                 show_success => "Fichier $filename chargé avec succès -->[ OK ]",
                };



}



