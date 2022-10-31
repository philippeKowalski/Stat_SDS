
    # Essai PhK pour evaluer les donnees presentes dans l'archive SDS de l'OVPF
    # A partir de Creation_lss.sh idem pour l'ERC

    # Initialisation/Definition par defaut de l environnement (repertoires)
    # ---------------------------------------------------------------------
    #---- Repertoire de travail/temporaire
    #------- Cas de l ERC
    # rep_base=/mnt/ERC/Sismo/SDS
    # ------ Cas de l OVPF PitonBleu
    # rep_base=/exports/sensors/DonneesAcquisition/Sismo/MINISEED_VALIDE
    # ------ Cas de l OVPF Pitondebredes (AEQC)
    rep_base=/mnt/pitonbleu/MINISEED_VALIDE
    verbose=0       # Mode verbose
    nohup=0         # A lancer en arriere plan
    remove=0        # Effacement des fichiers pre-existants
    output="Stat"
	percent="on"
	number="off"
    listeStations=""
    dateFin=""
    # listeStationsERC="BON0,BON1,BON2,BON3,BON4,BON5,BON6,DSO0,DSO1,DSO2,DSO3,DSO4,DSO5,DSO6"

	dateDebut="2022-01-18"
	dateFin="2022-01-28"
	channelCode="HHZ,HHN,HHE"
	stationCode="CAM"
	netCode="PF"

	decalYear=0

    while getopts "d:f:b:l:y:vth" option
    do
         case $option in
           d) dateDebut=$(date -I -d "$OPTARG");;
           f) dateFin=$(date -I -d "$OPTARG");;
           l) listeStations=$OPTARG;;
           y) decalYear=$OPTARG;;
           b) rep_base=$OPTARG;;
           v) verbose=1;;
		   t) verbose=2;;						# Pour des tests de developpement
           h) help=1;;
         esac
    done


	#anneeScrutee=$(date +%Y -d "$(date) -$decalYear year")
	echo "Annee scrutee:"$(date +%Y -d "$(date) -$decalYear year")
	
	
	repLs="ls-stations"
	aujourdhui=`date +%Y%m%d`
	hier=$(date +%Y%m%d -d "$aujourdhui -1 day")
	jour=$dateDebut
	jourFin=$(date -I -d "$dateFin +1 day")

