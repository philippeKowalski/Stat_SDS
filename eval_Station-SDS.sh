#!/bin/bash
#
# Evaluation des donnees presentes dans l'archive SDS de l'OVPF
#	Version du 05/04/2022
#
#	Objectif : Determiner quotidiennement la completude de la station sismique sur la periode 'date de debut' - 'date de fin'
#				Destine en particiulier a traiter des periodes du type 'Y-1'-01-01 à Y-12-31 = 2 ans se terminant l'annee en cours	

# Amelioration a prevoir
#	- Davantage de parametres dans fichier de configuration
#	- Un flag pour corcer l evaluation systematique
#   - URGENT ajout de l annee dans les noms de fichiers resultats 


# Initialisation/Definition par defaut de l environnement (repertoires)
# ---------------------------------------------------------------------
#--------Pour Sismo OVPF depuis pitondebredes (machine AEQC)
repMSV=/mnt/pitonbleu/MINISEED_VALIDE
#---- Repertoire pour fichier resultats
repStat="stat-stations"
#---- Repertoire pour listing miniseed du jour et de la veille
repLs="ls-stations"

# Initialisation des variables
verbose=0       # Mode verbose
test=0          # Mode test = debugage pour mise au point des scripts
help=0			# Flag pour le help
dateFin=""
freq=100

# Marqueur de temps pour evaluation des performances
dateJalon=`date`

# Traitement de la ligne de commande
# ---------------------------------------------------------------------
while getopts "s:d:f:n:c:l:b:hvt" option
do
	 case $option in
	   d) dateDebut=$(date -I -d "$OPTARG");;
	   f) dateFin=$(date -I -d "$OPTARG");;
	   n) netCode=$OPTARG;;
	   s) stationCode=$OPTARG;;
	   c) channelCode=$OPTARG;;
	   l) locCode=$OPTARG;;
	   b) repMSV=$OPTARG;;
	   v) verbose=1;;
	   t) verbose=2;;
	   h) help=1;;
	 esac
done

# La partie Help
# ---------------------------------------------------------------------
if [ $help == 1 ]
then
	echo "# DOCUMENTATION DE statSDS.sh"
	echo "#     Realisation de statistiques sur une liste de station d'une archive SDS"
	echo "#     Derniere mise a jour : 04/04/2022 par Ph.K."
	echo "#" 
	echo "# 1 - Objectif"
	echo "# L'objectif du programme est de creer des fichiers contenant les statistiques (pourcentage) de chaque station avec channels et total pour chaque jour"
	echo "#" 
	echo "# 2 - Syntaxe"
	echo "#    ./statSDS.sh [options] -s STA -d yyyy-mm-dd"
	echo "#"
	echo "# Parametres obligatoires :"
	echo "#    -s : code de la station a traiter. Ce code doit être defini dans le fichier configurationStations.txt"
	echo "#    -d : la date de debut de periode a traiter"
	echo "#"
	echo "# Parametres optionnels"
	echo "#    -f : la date de fin de periode a traiter. Defaut : date de debut"
	echo "#"
	echo "#    -n : Network_Code a utiliser. Par defaut recherche dans configrationStationsV2.txt"
	echo "#    -l : Location_Code a utiliser. Par defaut recherche dans configrationStationsV2.txt"
	echo "#    -c : Channel_Code a utiliser (Liste de channels separes par des virgules)."
	echo "#         Par defaut recherche dans configrationStationsV2.txt"
	echo "#"
	echo "#    -b : repertoire de base de l'archive SDS"
	echo "#         En cas d'absence de ce parametre, le repertoire courant est utilise"
	echo "#    -h : Cette documentation"
	echo "#    -v : mode verbose"
	echo "#"
	echo "# 3 - Principes et limitations connues"
	echo "#    - Surcharge des parametres : "
	echo "#		 Les parametres passes dans la ligne de commande surchargent les parametres issus des fichiers de configuration"
	echo "#	   - Les calculs ne sont refaits que si il y a eu une evolution des fichiers de donnees dans l archive SDS"
	echo "#"    

	exit 0; 
fi

# Complementation des parametres indispensables
if [ "$dateFin" = "" ]; then dateFin=$dateDebut; fi

# Affichage eventuel des parametres recuperes par le ligne de commande
if [ $verbose == 1 ] || [ $verbose == 2 ]
then
	echo "-----------------------------------------------------------------------------"
	echo "----- Execution de eval_Station-SDS.sh -----"
	echo "----- Parametres recuperes via la ligne de commande -----"
	echo "----- --- dateDebut="$dateDebut
	echo "----- --- dateFin="$dateFin
	echo "----- --- stationCode="$stationCode
	echo "----- --- rep_SDS="$repMSV
fi

# Verification de l existance de la station dans le fichier configuratioStations.txt
# ---------------------------------------------------------------------
infoStation=`grep $stationCode configurationStations_v2.txt | awk '{ print $3 }'`    
if [ -z $infoStation ]
then
	echo "La station doit exister dans le fichier de configuration !!"
	exit
fi

# Recuperation des parametres dans le fichier de configuartion des stations
if [ -z $channelCode ]; then channelCode=`grep $stationCode configurationStations_v2.txt | awk '{ print $5 }' `; fi
if [ -z $netCode ]; then netCode=`grep $stationCode configurationStations_v2.txt	| awk '{ print $2 }' `; fi
if [ -z $locCode ]; then locCode=`grep $stationCode configurationStations_v2.txt | awk '{ print $4 }' `; fi

# Affichage eventuel des parametres recuperes das le fichier de configuration
if [ $verbose == 1 ] || [ $verbose == 2 ]
then	
	echo "----- Paramèes recuperes via le fichier configurationStations -----"
	echo "----- --- networkCode="$netCode
	echo "----- --- stationCode="$stationCode
	echo "----- --- locCode="$locCode
	echo "----- --- channelCode="${channelCode//,/ }
	echo ">>> Traitement "$netCode"-"$stationCode"-"$locCode"-"$channelCode" debute a "$dateJalon
fi


# ------------- Partie traitements ---------------------------------

# Parametres lies a la date d aujourdhui evaluation desfichiers presents vs ceux d hier
aujourdhui=`date +%Y%m%d`
year=`date +%Y`
hier=$(date +%Y%m%d -d "$aujourdhui -1 day")

# Effacement du fichier du jour s il existe (inutile si execute 1 x/jour)
rm $repLs/$stationCode-$aujourdhui".txt"

# Evaluation de la periode a lister
premierJanvierFin=$(date +%Y -d "$dateFin +1 year")"-01-01"
premierJanvier=`date +%Y -d $dateDebut`"-01-01"
# Listage des annees concernees (Annee derniere + annee en cours en général)
while [ $premierJanvier != $premierJanvierFin ]
do
	ls -lR $repMSV/$(date +%Y -d "$premierJanvier")/$netCode/$stationCode/ >> $repLs/$stationCode-$aujourdhui".txt"
	echo $repMSV/$(date +%Y -d "$premierJanvier")/$netCode/$stationCode/
	premierJanvier=$(date -I -d "$premierJanvier + 1 year")
done

# Renomer stat de la veille >> ".hier"
mv $repStat/$stationCode.txt $repStat/$stationCode".hier"

# Creation du fichier stat du jour
# Creation de la ligne d entete
ligne="Date Total"
for comp in `echo ${channelCode//,/ }` ; do ligne=$ligne" "$comp; done
echo $ligne > $repStat/$stationCode.txt

# Pour tous les jours a evaluer
jour=$dateDebut

jourFin=$(date -I -d "$dateFin + 1 day")
echo $jourFin

echo $channelCode > liste.txt

#Evaluation de la completude des donnees sismo (pitonbleu:/xxx/MINISEED_VALIDE)
while [ "$jour" != $jourFin ]
do
	# Comparaison stat fichier ls du jour avec stat fichier ls de la veille
    anneeJour=`date -d $jour +%Y`
    moisJour=`date -d $jour +%m`
    jourJour=`date -d $jour +%d`
    numJour=`date -d $jour +%j`

	if [ -f $repLs"/"$stationCode"-"$hier ]; then 
		lsJ0=`more $repLs"/"$stationCode"-"$hier | grep $netCode.$stationCode.*.*.D.$anneeJour.$numJour`
	else
		# Cas du premier lancement 
		if [ $verbose == 2 ]; then echo -n "A"; fi
		lsJ0="PasDeDonneesPreExistantes"
	fi
	lsJ1=`more $repLs"/"$stationCode"-"$aujourdhui | grep $netCode.$stationCode.*.*.D.$anneeJour.$numJour`
	
	if [ "$lsJ1" = "$lsJ0" ] 
	then
		# Si les fichiers miniseed n ont pas evolue depuis la veille 
		if [ $verbose == 1 ]; then echo -n "-"; fi
		ligne=`more $repStat/$stationCode".hier" | grep $jour`
		if [ "$ligne" = "" ]; then
			ligne=$jour" 0.00"
			for comp in `echo ${channelCode//,/ }` ; do ligne=$ligne" 0.00"; done
		fi
		if [ $verbose == 2 ]; then echo "Egalite >> "$ligne; fi
	else
		# Si les fichiers miniseed ont evolue depuis hier
		# on doit parcourir les fichiers miniseed
		if [ $verbose == 1 ]; then echo -n "+"; fi
		nbEchSta=0
		nbChan=0
		ligne=""
		
        for comp in `echo ${channelCode//,/ }`
        do
            if [ $verbose == 2 ]; then echo "Fichier evalue :"$repMSV/$anneeJour/$netCode/$stationCode/$comp.D/$netCode.$stationCode.$locCode.$comp.D.$anneeJour.$numJour; fi
			if [ -f $repMSV/$anneeJour/$netCode/$stationCode/$comp.D/$netCode.$stationCode.$locCode.$comp.D.$anneeJour.$numJour ]
            then
				valeur=0
                freq=1
                valeur=`msi $repMSV/$anneeJour/$netCode/$stationCode/$comp.D/$netCode.$stationCode.$locCode.$comp.D.$anneeJour.$numJour -T | grep $stationCode_$locCode_$comp | awk ' BEGIN { val=0 } { val=val + $5 } END { print val } '`		
                retMsi=`msi $repMSV/$anneeJour/$netCode/$stationCode/$comp.D/$netCode.$stationCode.$locCode.$comp.D.$anneeJour.$numJour -T | grep $stationCode_$locCode_$comp `
                freq=`echo $retMsi | awk ' BEGIN { val=0 } { val=val + $4 } END { print val } ' `
                if [ $freq != 0 ]
                then
                    ligne=$ligne" "`echo "scale=2 ; $valeur / ($freq * 864)" | bc`
					nbEchSta=`echo "$valeur + $nbEchSta" | bc`
                else
                    ligne=$ligne" 0.00"
                fi
			else
				ligne=$ligne" 0.00"
            fi
			
			# Statistique niveau station = total des channels
			nbChan=`echo "$nbChan + 1" | bc`
        done

		# calcul total des voies (en supposant tous les canaux a la meme frequence)
		if [ $nbChan != 0 ]
		then
			ligne=`echo "scale=2 ; $nbEchSta / ($freq * 864 * $nbChan)" | bc`" "$ligne
		else
			ligne="0.00 "$ligne
		fi

	    if [ $verbose == 2 ]; then echo "Inegalite >> "$jour" "$ligne; fi
	
		ligne=$jour" "$ligne
	fi
	# complementation du fichier stat du jour
	echo $ligne >> $repStat/$stationCode".txt"

	# Increment jour
	jour=$(date -I -d "$jour + 1 day")
done

# pour un chronometrage ...
dateJalon=`date`
if [ $verbose == 1 ] || [ $verbose == 2 ]
then 
	echo ""
	echo ">>> Fin Traitement "$netCode"-"$stationCode"-"$locCode"-"$channelCode" a "$dateJalon
fi
