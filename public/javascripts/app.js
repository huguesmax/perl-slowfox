		
//defini les fenetres  aModal avec les methodes .showModal() ou .hideModal() d'affichage de la fenetre Modal 
var aModal;
	aModal = aModal || (function () {
	    var pleaseWaitDiv = $("#myModal");
	return {
        showModal: function() { pleaseWaitDiv.modal({backdrop:'static',keyboard:false });
        }, 
        hideModal: function () {pleaseWaitDiv.modal('hide');}, }; 
        })();

//fonction getFileWithModalDisplay a appeler pour ouvrir une modal en spécifiant ouverture true ou  fermeture false, et un message

    var Modal;
    var getFileWithModalDisplay = function( show, message){
	    if(show){
	    //alert(message);
	    $("#modal-label").html(message);
	    aModal.showModal();
	    $("#progressBar").css({'width':'100%'});//valeur initiale dans la progress-bar
	    Modal = setInterval(repeat, 1000);
	    }else{
	    //alert("je cache la fenetre modale");
	    clearInterval(Modal);
	    aModal.hideModal();
		  }};
		  
//cette fonction appel l'url /code et reçoit une valeur ou la string onFerme
    function repeat(){ $.get("/code", function(data) {
	    if (data.id === "onFerme"){
		      getFileWithModalDisplay(false);
		}else{
        	//on peut faire progresser la barre petit à petit
        	    // si session Comment existe il remplace la valeur de modal-label
	          if ( data.Comment != "" ) { $("#modal-label").html(data.Comment); }
        	//	$("#progressBar").css({'width':monX+'%'});
        	//on ne fait rien on laisse ma modale
        	       }
	       }); 
    };
  
$(".modalButton").click(function(event){
	var name =$(this).html();
        getFileWithModalDisplay(true,"Nous génerons votre fichier pour: \""+ name + "\"");
  
    });

//fonction pour la page dossier affiche cache les infos client
	$("#Clientinfos").click(function(){
	$("#infoClient").toggle();
	});

// bouton affiche nouvelle hotline
    $("#showNewHot").click(function(){
        $("#newhotline").toggle();
    });
//fonction à la selection des hotline pour mise a jour

	function updateHl(){
		//numero de dossier:
	var numero = $(".radioHl:checked").attr("value");
		$.get(numero, function(data) {
			setHotlineForm(data);
		});
	}
	function setHotlineForm(objson){
		$("#NumHL").html(objson.NumHL);
		$("#DateHL").html(objson.DateHL);
		$("#CodeTechnicien").html(objson.CodeTechnicien);
		var ouverture = new Date (objson.HeureHL);
		$("#HeureHL").html(objson.HeureHL);
		$("#AppelEntrantSortant").html(objson.AppelEntrantSortant);
		var cloture = new Date (objson.HeureHLClos);
		$("#HeureHLClos").html(objson.HeureHLClos);
		$("#spent").html(objson.duree);
		$('#listPanne option[value="'+objson.Panne+'"]').prop('selected', true);
		$('#listPanne').attr('disabled', 'disabled');
		$('#listAction option[value="'+objson.Action+'"]').prop('selected', true);
		$('#listAction').attr('disabled', 'disabled');
		$("#MemoPanne").html(objson.MemoPanne);
		$('#MemoAction').html(objson.MemoAction);
	}
	
	//fonction pour voir les commentaire historique entre les lignes des dossier
	function updateDossier (obj) {
		var numDossier = $(".radioDossier:checked").attr("value");
		var place= obj.id;
		$(".ajout1").remove();
		$("#"+obj.id).parent().parent().after("<td class='ajout1' colspan='6' id='ajout1'></td>");
		$.ajax({
                url: "/sav/hotline/dossier/"+numDossier,
                dataType: "html",
                success:function(data){
                    $("#ajout1").html(data);
                    }
                });
	}

//afecte les infos client à la livraison
	$("#infosClient").click(function(){
		$("#denomination").val( $("#inf-denomin").html() );
		$("#adress").val( $("#inf-adress").html() );
		$("#codepostal").val( $("#inf-cp").html() );
		$("#ville").val( $("#inf-ville").html() );
	});
	
//affecte les infps client facturation à la livraison
		$("#factuClient").click(function(){
		$("#denomination").val( $("#fac-denomin").html() );
		$("#adress").val( $("#fac-adress").html() );
		$("#codepostal").val( $("#fac-cp").html() );
		$("#ville").val( $("#fac-ville").html() );
	});

//Gestion du bouton de post du nouveau dossier
		$("#postNew").click(function(e){
			e.preventDefault();
			if ($("#etatDossier").val()==="0"){
                        alert ("Séléctionnez un état de dossier SVP ! ");
                        return;
                    }
			var Thedata= $("#newinput").serialize();
			var add ="&NomClientFacturation="+$("#fac-denomin").html()+"&AdresseFacturation="+$("#fac-adress").html()+
			"&CodePostalFacturation="+$("#fac-cp").html()+"&VilleFacturation="+$("#fac-ville").html();
			Thedata +=add.toString();
			var urlform=$("#newinput").attr('action');
			
			$.post(urlform,Thedata,function(data){
				window.location = "/sav/repair/"+$("#client").val();
			});

		});

		$("#stockPlus").click(function(){
			var Sortie="";
			var categorie;
			var tpe=0;
			var numParc=new Array();
			var listCategorie=new Array();
			var compare;
			var post='ok';
			//$(".parc:selected").html().each( function(index){
				$(".parc:checked").each(function(i){
    				numParc[i]       =($(this).val());
    				var numContrat   =$(this).parent().next().html();
    				numContrat       =numContrat.replace(/(\r\n|\n|\r)/gm,"");
                    numContrat       =$.trim(numContrat);
                    		
    				var categorie    =$(this).parent().next().next().html();
    				categorie        =categorie.replace(/(\r\n|\n|\r)/gm,"");
    				categorie        =$.trim(categorie);
    				listCategorie[i] =numParc[i]+":"+categorie;
    				//si il y à déja 
    				if (compare){
    					if (compare==numContrat){
    						//ok
    					}else{
	    				post='ko';
	    				alert("Un numero de contrat unique par dossier");
    					}
    				}else{
    					compare =numContrat;
    				}
    				if(/^TPE/.test(categorie)){
    					tpe=1;
    				}
    			});
    		//on test si il n'y a pas déjà un TPE
    		if (compare){
    			$(".categorie").each(function(i){
    				if(/^TPE/.test(categorie)){
    					tpe=1;
    				}
    			});
    		}
			//On fait le bilan
			if (tpe ===1 && post ==='ok'){
				var url="/sav/stock/plus/"+$("#dossier").val();
				$.post(url,"numParc="+numParc.toString()+"&listeCat="+listCategorie.toString(),function(data){
				window.location = "/sav/repair/"+$("#client").val();
			});
			}else{
				alert("Selectioner obligatoirement un materiel TPE: la Catégorie commence par TPE ");
			}
		});
		
		$("#stockMoins").click(function(){
			var numStock=new Array();
			$(".stock:checked").each(function(i){
				numStock[i] =($(this).val());
			});
			var url="/sav/stock/moins/"+$("#dossier").val();
				$.post(url,"numParc="+numStock.toString(),function(data){
				window.location = "/sav/repair/"+$("#client").val();
		});
		});		

        $("#postNewHot").click(function(){
            var post = "ok";
            if ($("#appel_diag").html()===""){
                alert("Veuillez séléctionner un diagnostic");
                post = "ko";
                return;
            }
            if ($("#appel_action").html()===""){
                alert("Veuillez séléctionner une action");
                post = "ko";
                return;
            }
            if(post ==="ok"){
                var url = $("#addhotline").attr('action');
                var data = $("#addhotline").serialize();
                $.post(url,data,function(){
                    if ($("#dossier").val()==="NOUVEAU DOSSIER" || $("#appel").val()!==""){
                        window.location = "/sav/recapitulatif/";        
                    }else{
                        window.location = "/sav/hotline/";
                    }
                
            });
            }//fin if
             });//fin click
    
    //click icon param parc pour les voir
        $(".parametre").click(function(){
            showParcParam($(this));
            //alert ($(this).attr('numP'));
            //mettre le css .parametre over mouse link je crois
            //demandr les infos et les presenter
            
        });
                    
       //fonction pour voir les parametre des parcs
    function showParcParam (obj) {
        var numParc = obj.attr('numP');
        $(".ajoutparam").remove();
        obj.parent().parent().after("<tr class='ajoutparam alert-warning'><td>Numero Parc</td><td>Opérateur</td><td>Abonnement</td><td>Passerelle 1</td><td>Passerelle 2</td>"
        +"<td>Port1</td><td>Port2</td></tr><tr class='ajoutparam alert-warning' id='infoParc'><td id='info1'></td><td id='info2'></td><td id='info3'></td><td id='info4'></td>"
        +"<td id='info5'></td><td id='info6'></td><td id='info7'></td></tr><br class='ajoutparam'><br class='ajoutparam'><br class='ajoutparam'>");
        $.get("/sav/params/"+numParc, function(data) {
            setParamForm(data);
        });
    }
    function setParamForm(objson){
        $("#info1").html(objson.NumParc);
        $("#info2").html(objson.Operateur);
        $("#info3").html(objson.Abonnement);
        $("#info4").html(objson.Passerelle);
        $("#info5").html(objson.PasserelleSecours);
        $("#info6").html(objson.Port);
        $("#info7").html(objson.PortSecours);
            }
    
        $("#AnnulerNew").click(function(){
           var r = confirm("Voulez-vous annuler ce dossier ?");
                if (r == true){
                      window.location = "/sav/search";
                      }
                    else{
                      x = "You pressed Cancel!";
                      } 
                                
            });
            
       $("#EnregistrerEtCloturer").click(function(){
           var r = confirm("Enregister et cloturer ce dossier ?");
                if (r == true){
			window.location = "/sav/enregisterC/"+$("#client").val();
                      }
                    else{
                      x = "You pressed Cancel!";
                      } 
                                
            });
       $("#EnregistrerEtEnvoyer").click(function(){
           var r = confirm("Enregister et Transferer ce dossier au niveau 2 ?");
                if (r == true){
			window.location = "/sav/enregisterN2/"+$("#client").val();
                      }
                    else{
                      x = "You pressed Cancel!";
                      } 
                                
            });
            
    //boutons ajout daig et panne dans newHotline
   
    $("#DiagPlus").click(function(){
        var date = $("#appel_date").html();
        var texteselect= $("#select_diag option:selected").text();
        var commentaireDiag= $("#commentaireDiagManuel").val();
        $("#appel_diag").html( $("#appel_diag").html()+ date +" "+ texteselect+" "+commentaireDiag+ " \n");
        $("#commentaireDiagManuel").val('')
        
    });
    
    $("#ActionPlus").click(function(){
        var date_action = $("#appel_date").html();
        var texteselectaction= $("#select_Action option:selected").text();
        var commentaireAction= $("#commentaireActionManuel").val();
        $("#appel_action").html( $("#appel_action").html()+ date_action +" "+ texteselectaction+" "+commentaireAction+ " \n");
        $("#commentaireActionManuel").val('');
    });
    
    $("#DiagMoins").click(function(){
        var texte = $("#appel_diag").html();
        var split = texte.split("\n");
        var lon = split.length;
        if (lon === 0){
            return;
            }
        else if (lon === 1){
            $("#appel_diag").html('');
            }
        else{
            var newtexte ="";
        for (var i=0; i<lon-2;i++){
            if(split[i]){
            newtexte= newtexte.concat(split[i]);
            newtexte = newtexte.concat(" \n");
            }
        }
      
        $("#appel_diag").html('');
        $("#appel_diag").html(newtexte);
          }
    });
    
    $("#ActionMoins").click(function(){
        var texte = $("#appel_action").html();
        var split = texte.split("\n");
        var lon = split.length;
        if (lon === 0){
            return;
            }
        else if (lon === 1){
            $("#appel_action").html('');
            }
        else{
            var newtexte ="";
        for (var i=0; i<lon-2;i++){
            if(split[i]){
            newtexte= newtexte.concat(split[i]);
            newtexte = newtexte.concat(" \n");
            }
        }
      
        $("#appel_action").html('');
        $("#appel_action").html(newtexte);
          }
        
    });
   
    
// Fonction pour la partie Recouvrement
///////////////////////////////////////////


// Bloquer si aucune action n'a été séléctionner
$("#postNewAction").click(function(e){

	    var action    = $("input:radio[name=action]:checked").val();
	    var cloturer  = $( "input:checkbox[name=cloturer]:checked" ).val();
	    var inputFile = $( "input:file[name=filename]").val();

	    if ( action ) { 

            } else {
			alert("Attention Vous devez séléctionner une action pour enregister");
			e.preventDefault(); // pour bloquer le poste du navigateur
			return;
	    }

	    if ( action === "cloture" && cloturer !=="on" ) { 

		        alert("Attention: Vous devez confirmer la cloture en cochant la case \"Cloturer ce dossier\" ");
                        e.preventDefault(); // pour bloquer le poste du navigateur
                        return; 
	    }

	     if ( action !== "cloture" && cloturer ==="on" ) { 

		        alert("Attention: Vous cloturez sans avoir séléctionné une action \"Cloturer ce dossier et joindre un certificat...\" ");
                        e.preventDefault(); // pour bloquer le poste du navigateur
                        return; 
	    }
	     
	    if ( action === "cloture" && inputFile ==="" ) { 

		    	 alert("Attention: Pour cloturer vous devez joindre un certificat d'irrecouvrabilité ");
                        e.preventDefault(); // pour bloquer le poste du navigateur
                        return; 
	    }






});

// Mise en recouvrement Admin

$("#postNewActionR").click(function(e){

	    var Montant = $("#MontantRecouvrement").val();

	    if ( Montant > 0) { 

            } else {
			alert("Erreur, Vous devez indiquer un Montant Valide a Recouvrir");
			e.preventDefault(); // pour bloquer le poste du navigateur
			return;
	    }
});









