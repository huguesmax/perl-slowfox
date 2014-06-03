package money30::prodige;
use Dancer ':syntax';
use Dancer::Plugin::Database;	#Connexion a la base de données Mysql
use DBI;			#Connexion a la base de données A SAV
use DateTime::Format::Strptime;	#Gestion des Date		
use Tie::IxHash;
use Dancer::Plugin::Ajax;
use Dancer::Plugin::Auth::RBAC;				# Gestion des Access ( Role Base Access )
use Dancer::Plugin::Auth::RBAC::Credentials::MySQL;	# RBAC MySQL
use Dancer::Plugin::Auth::RBAC::Permissions::Config;
use Spreadsheet::ParseExcel;
use Spreadsheet::WriteExcel;
use Data::Dumper;
use Modern::Perl;
#Module spécifique 
use POSIX qw/strftime/;                 	        # Formatage des dates
#use experimental 'smartmatch';


get '/prodige' => sub {
 
	
		my $count_client = database('asav')->quick_count('Client',{});
		my $count_not_bic = database('asav')->quick_count('Client', { CoteFinanciere => 'BON' , BIC => undef });	
		return template 'money30/prodige' => {(client=>$count_client,noBic=>$count_not_bic)};
				
#$workbook.close();
		
	
};



get '/prodige/Reporting/:tableName' => sub {

		use Spreadsheet::WriteExcel::Big; 

		my $user               = auth;			# Chargement des droits de l'utilisateur
		my $userId             = session('id'); 	# On recupère l'id de session pour l'utiliser dans le nom du fichier 
		session 'ValueSession' => 1;			# On met a 1 pour forcer la non fermeture de la fenetre modale

		if ( ! $user->asa('prodige') ) { 
				return template 'money30/accueil' => {
						 show_warning => "Désolé mais vous n'avez pas les droits pour consulter cette page - Merci de contacter l'adminstrateur."
				};
		}

		my $query       = params->{'tableName'};				# Parametre passé a la page
		my $dateFile    = strftime('%Y-%m-%d',localtime);
		my $dateQuery   = strftime('%Y-%m',localtime);
		my $file        = '/tmp/Report' .$query.'-'.$userId.'.xls';
		my $filename    = 'Export-' .$query. '-' .$dateFile. '.xls';
		my $sql;
		my $header;
		
		sub ltrim {
		        my $string = shift;
		        $string =~ s/^\s+//;
		        return $string;
		}

		########### EXPORT IMPAYE ######################
		if ($query eq 'Ingenico') {
			$sql =  "SELECT NumDossier, Panne, ACTION FROM asav.HotLineComplet WHERE
			 NumDossier IN (SELECT NumDossier FROM asav.DossierComplet WHERE CodeClient IN ( SELECT CodeClient FROM asav.ClientContrat WHERE 
			 CategorieContrat='BNP5INGENICO' AND CodeClient IN (SELECT CodeClient FROM Client WHERE CategorieClient = 'BNPP'))
			 AND ( DossierComplet.DateCloture >= '2013-11-01 00:00:01' AND DossierComplet.DateCloture <= '2013-12-01 00:00:01')) ORDER BY Panne ASC;";
		$header = "CodePanne;Nbre Appel;Nbre envoi;";
		}
	
#Pour le reporting il faudra comptabiliser le parc 
#combien d'appel par type de panne 
#compter d'envoi type code 910 
#parcourrir
	# my $panne = database('asav')->prepare('SELECT NumDossier, Panne, Action FROM asav.HotLineHistorique where
# NumDossier in (SELECT NumDossier FROM asav.DossierClos where CodeClient in ( SELECT CodeClient FROM asav.ClientContrat where 
# CategorieContrat="BNP5INGENICO" and CodeClient in (select CodeClient from Client where CategorieClient = \'BNPP\'))
# AND ( DossierClos.DateCloture >= "2013-11-01 00:00:01" AND DossierClos.DateCloture <= "2013-12-01 00:00:01")) order by Panne asc;');
	session 'Comment' => "execution de la requete SQL";
	my $panne 		= database('asav')->prepare($sql);
	$panne->execute();
	my $answer 		= $panne->fetchall_arrayref({});
	#print Data::Dumper->Dump($answer);
	#my @a =@{$answer};
	my @ListNumDossier;
	my %h_som_call;	
	my %h_som_envoi;
	foreach my $h_call (@{$answer}){
		my $NumDossier 		=$h_call ->{NumDossier};
		my $Code_Panne 		=$h_call ->{Panne};
		my $Code_Action 	=$h_call ->{Action};
			#my $Memo_Action		=$h_call ->{MemoAction};
		if($Code_Panne){
		if ($NumDossier ~~ @ListNumDossier){
			#ne rien faire
			}else{
		
			$h_som_call{$Code_Panne}++;
		
			if ($Code_Action and $Code_Action == 910 and $Code_Panne ){
				$h_som_envoi{$Code_Panne}++;
				}
			push(@ListNumDossier, $NumDossier);
		
			}
		}
	}
	
	session 'Comment' => "Generation de votre tableau";		
	
	#Creation du fichier XLS & de l'onglet query & des formats
		my $workbook    = Spreadsheet::WriteExcel::Big->new($file);
                   		  $workbook->set_properties( title => $query, author => 'Hugues.BOUHANA@softalys.com', comments => 'www.Softalys.com', );
		my $iSheet      = $workbook->add_worksheet( $query );
		   $iSheet->set_column('A:Z',32);

		my $format1     = $workbook->add_format(bold=>1, size=>11, color=>'red', align=>'center'  );	
		my $format2     = $workbook->add_format(bold=>0, size=>9, color=>'black', align=>'left');
		my $format2Euro = $workbook->add_format(size=>9, color=>'blue',  align=>'left', num_format=>'### ##0.00'.chr(128));	

		#Creation des headers XLS
		my @header = split(';', $header);
		my $ligne = 1;
		my $col   = 0;
		foreach my $header (@header) { 
					$iSheet->write_string($ligne,$col,$header, $format1);
					$col++;
		}
		$ligne++;

		foreach my $k (keys(%h_som_call)){
			$iSheet->write($ligne,0, $k, $format2Euro);
			$iSheet->write($ligne,1, $h_som_call{$k}, $format2Euro);
			$iSheet->write($ligne,2, $h_som_envoi{$k}, $format2Euro);
			$ligne++;
		}
		$workbook->close();
		if ( envoiFichier($file,$filename) ) {
				return template 'money30/prodige' => {
                                                 show_warning => " Il y a eu un erreur, Merci de contacter l'Adminstrateur "
                                };
		} 

};

################## SUB ###############################

sub envoiFichier {
		use File::Copy;
		my $file     = shift;
		my $filename = shift;
		my $PUBLICTMP  = config->{'PUBLICTMP'};	

		if ( -e $file ) {
			move( $file, $PUBLICTMP ) || return 1;	                                # On deplace de /tmp vers public/tmp accessible au web
			session 'ValueSession' => 0;						# On force ValueSession a 0 pour fermer la modale
			session 'Comment'      => "";						# On met a vide
			sleep 1;								# On attend une sec que la modale ce ferme
			send_file( $file, streaming => 1, filename => $filename);
		} else {
			return 1;
		}
}

get '/prodige/AnnulExpress' => sub {
	
		#SELECT NumDossier,Panne, MemoPanne,Action, MemoAction FROM asav.HotLineHistorique where NumDossier =777981 or NumDossier =778544
		
		my $count_client = 8;
		my $count_not_bic = 1;
		my @annulles = database('asav')->quick_select(
			'ClientContrat',
			{ DateAnnulation =>{ 'gt' => '2013-11-15 00:00:01' },Annulation => true},
			{ order_by => 'DateAnnulation', columns => [qw(CodeClient NumContrat TypeContrat Categoriecontrat DateEffet DateEcheance Annulation DateAnnulation MotifAnnulation)] }
		);	
		foreach my $var (@annulles){
				print $var->{CodeClient},"\n";
				print $var->{NumContrat},"\n";
				print $var->{DateAnnulation},"\n";
				                            
			}
};

get '/prodige/Annul0' => sub {
	
		my $count_DossiersClos = database('asav')->quick_count(
			'Dossier',
			{DateCloture =>{ 'lt' => "2013-12-01 00:00:01"},DateCloture => { 'gt' => "2013-11-01 00:00:01"}});
				return $count_DossiersClos;
};
# fournis le nombre de dossier clos en novembre2013
get '/prodige/Annul' => sub {
	
		my $count_DossiersClos = database('asav')->quick_count(
			'DossierClos',
			{DateCloture => {
				ge => '2013-11-01 00:00:01',
				lt => '2013-12-01 00:00:01',
			}});
				return $count_DossiersClos;
		
};
# liste des codes clients
#SELECT CodeClient FROM asav.ClientContrat where 
#CategorieContrat="BNP5INGENICO" and CodeClient in (select CodeClient from Client where CategorieClient = 'BNPP')
#
#Recupere le parc complet 
#recupere les codes client. 
# filtre le parc par code client 
# comptabilise les types de materiel 
#

get '/parc' => sub {
		#Rechercher les infos dans la table ClientParc
		my ($CodeClient, $CodeArticle, $Specifique );
		my $sql = q/SELECT CodeClient, CodeArticle,Specifique FROM ClientParc/;
		my $sth = database('asav')->prepare($sql);
                   $sth->execute();
		my $answer = $sth->fetchall_arrayref({});
		my $clients=0;
		my %h_materiel;

			foreach my $h_call (@{$answer}){
				my $CodeClient 	 = $h_call ->{CodeClient};
				my $CodeArticle  = $h_call ->{CodeArticle};
				my $Specifique	 = $h_call ->{Specifique};
				$clients++;
				$h_materiel{$CodeArticle}++;
			}

		return template 'money30/Reporting' => {
						listesH	=> \%h_materiel,
						#show_success => "Ce Parc Comprend  $clients"		
		};
		# foreach my $k ( keys(%h_materiel)){
			# print "$k ==== $h_materiel{$k} \n";	
		# #print Data::Dumper->Dump({%h_materiel});
		# }	
		# print "nbre client = $clients\n";
	};

ajax '/code' => sub {
	my $code = session('ValueSession');
	my $Comment = session('Comment');
	my $rep;

	if ( $code == 0 ) {
		$rep = "onFerme";
	} else {
		$rep = $code;
	}
	#my $json = JSON->new->allow_nonref;
	#my $json_text   = $json->encode( $rep ); 	
	return { id => $rep, Comment => $Comment};
};

ajax '/prodige/renduFile/:id' => sub {
	
	my $count_client  = database('asav')->quick_count('Client',{});
	my $count_not_bic = database('asav')->quick_count('Client', { CoteFinanciere => 'BON' , BIC => undef });
		sleep 12;
	my $workbook  = Spreadsheet::WriteExcel->new("../public/Prodige.xls");
	my $worksheet = $workbook->add_worksheet();
	   $worksheet->write(0, 0, '$count_client');
	   $worksheet->write(0, 1, 'code_fiche');
	
	$workbook->close();
	
	return send_file($workbook);
		
};
true;
