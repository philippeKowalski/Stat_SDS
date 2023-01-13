#!/bin/bash

    # By PhK pour evaluer les donnees presentes dans l'archive SDS de l'OVPF
	# Version du 04/04/2022
	# Reprise pour statistiques annuelles par station
	
		
	# Ameliorations a prevoir
	#   - Recuperation des parametres propres a lenvironnement dans un fichier de conf
	

    # On se place dans le bon repertoire
    cd /home/sysop/Stat_SDS

    # Initialisation/Definition par defaut de l environnement (repertoires)
    # ------ Cas de l OVPF Pitondebredes (AEQC)
    rep_base=/mnt/pitonbleu/MINISEED_VALIDE

	# Modif propres pour annee auto
	decalageAnnee=0

    verbose=0  
	help=0

    listeStations=""
    dateFin=""
	dateDebut=""

	# Listes predefinies
    Test="PRA,PRO,PVD,RER,RVA,SNE,TKR,TTR,VIL"
    Test="PVD,RVA"
    All_OVPF="BLE,BON,BOR,C98,CAM,CAS,CIL,CPR,CRA,CSS,DOD,DSO,ENO,FEU,FJS,FOR,FRE,GBS,GPN,GPS,HDL,HIM,LAC,LCR,MAID,MAT,MVL,NSR,NTR,OBS,PBR,PCR,PER,PHR,PJR,PRA,PRO,PVD,RVA,SNE,TEO,TKR,TTR,TXR,VIL"
    Num_OVPF="BON,BOR,C98,CAM,CAS,CIL,CPR,CRA,CSS,DOD,DSM,DSO,FEU,FJS,FLR,FOR,FRE,GBS,GPN,GPS,HDL,HIM,LAC,MAID,MAT,MVL,OBS,PBR,PHR,PRA,PRO,PVD,RER,RVA,SNE,TKR,TTR,VIL"
    All_REVOSIMA="KNKL,KOUG,GGLO,MTSB,PMZI"
	

    while getopts "d:f:b:l:y:vth" option
    do
         case $option in
           d) dateDebut=$(date -I -d "$OPTARG");;
           f) dateFin=$(date -I -d "$OPTARG");;
           l) listeStations=$OPTARG;;
           b) rep_base=$OPTARG;;
		   y) decalageAnnee=$OPTARG;;
           v) verbose=1;;
		   t) verbose=2;;						# Pour des tests de developpement
           h) help=1;;
         esac
    done

    if [ $help == 1 ]
    then
        echo "# DOCUMENTATION DE eval_SDS.sh"
        echo "#     Realisation de statistiques sur une liste de station d'une archive SDS"
        echo "#     Derniere mise a jour : 04/04/2022 par PhK"
        echo "#" 
        echo "# 1 - Objectif"
        echo "# L'objectif du programme est de creer des fichiers contenant les statistiques de chaque channel de chaque station pour chaque jour"
        echo "# Ce script appel pour chaque station de la liste le script statSDS.sh"
        echo "#" 
        echo "# 2 - Syntaxe"
        echo "#    ./eval_SDS.sh [options] -d yyyy-mm-dd -f yyyy-mm-dd"
        echo "#"
        echo "# Parametres obligatoires :"
        echo "#    - Aucun"
        echo "#"
        echo "# Parametres optionnels"
        echo "#    -l : liste des stations a traiter separees par des virgules ou une liste predefinie"
        echo "#    -d : la date de debut de periode a traiter"
        echo "#    -f : la date de fin de periode a traiter"
		echo "#			  Si non precisee et option '-d' non utilisee, fixee a 31/12 de l annee demandee"
		echo "#			  Si non precisee et option '-d' utilisee, fixee a la date de debut"
        echo "#    -y : decalage d annee : "
		echo "#			  exemple '-y n' fixe l'annee a n annees en arriere et date de debut au 01/01"
		echo "#			  si n est pas precise et option -d non precise, fixee au 01-01 de l annee actuelle"
        echo "#    -b : repertoire de base de l archive SDS. Exemple '/exports/sensors/DonneesAcquisition/Sismo/MINISEED_VALIDE'"
        echo "#    		listes predefinies : Test, All_OVPF, Num_OVPF,All_REVOSIMA"
        echo "#    -h : Cette documentation"
        echo "#    -v : mode verbose"
        echo "#    -t : mode test incluant verose"
        echo "#"
        echo "# 3 - Fonctionnement et prinscipes"
        echo "#	   - Surcharge : les parametres passes par la ligne de commande sont prioritaires"    
        echo "#	   - Date de debut : "    
        echo "#	   		Si elle n est pas precisee, elle est fixee au premier janvier de l annee demandee (voir option -y)"    
        echo "#	   - Date de Fin : "    
        echo "#	   		Si elle n est pas precisee, elle est fixee au premier janvier de l annee demandee"    
        echo "#"    
        echo "#"    

        exit 0
    fi
    
	if [ -z $dateDebut ]
	then 
		anneeScrutee=$(date +%Y -d "$(date) -$decalageAnnee year")
		dateDebut=$(date +%Y -d "$(date) -1 year")"-01-01"
		dateFin=$(date +%Y)"-12-31"
	else
		if [ -z $dateFin ]; then dateFin=$dateDebut; fi
	fi    

    case $listeStations in
        "") listeStations=$Test;;
        "Test") listeStations=$Test;;
        "Num_OVPF") listeStations=$Num_OVPF;;
        "All_OVPF") listeStations=$All_OVPF;;
    esac
 
    # interessant en cas de débuggage
    if [ $verbose == 1 ]
    then
		echo "----- Execution de eval_SDS.sh -----"
        # Affichage des parametres recuperes
        echo "----- Parametres recuperes via la ligne de commande -----"
        echo "----- --- dateDebut="$dateDebut
        echo "----- --- dateFin="$dateFin
        echo "----- --- repbase="$rep_base
        echo "----- --- listeStations="$listeStations
        echo "----- --------------------------------------------- -----"
    fi

    # Debut des traitements (recuperation parametres terminee !)
    # ---------------------------------------------------------------------
    for nomStation in `echo ${listeStations//,/ }`
    do   
		cmd="./Eeval_Station-SDS.sh -d "$dateDebut" -f "$dateFin" -s "$nomStation
		if [ $verbose == 1 ]; then cmd=$cmd" -v"; fi
		if [ $verbose == 2 ]; then cmd=$cmd" -t"; fi
		if [ $verbose == 1 ] || [ $verbose == 2 ]; then echo $cmd; fi
	
		#$cmd
    done
        

