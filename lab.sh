 #!/bin/bash
#set -x

#fonction d'affichage après configuration
function screen {
	echo ""
	echo -e " \e[34m	>>>>>> Configuration summary <<<<<< \e[0m"
	echo ""
	echo -e "\e[92m	--- lab.conf ---\e[0m"
	cat ~/Documents/labs/"$name"/lab.conf 
	echo ""
	for g in $(seq 1 $pc_num)
	do
		node=P"$t"
		echo -e "\e[92m	--- $node.startup ---\e[0m"
		echo ""
		cat ~/Documents/labs/"$name"/"$node".startup  
	done
	echo ""
	for o in $(seq 1 $r)
	do
		node=R"$s"
		echo ""
		echo -e "\e[92m	--- $node.startup ---\e[0m"
		cat ~/Documents/labs/"$name"/"$node".startup 
	done
	echo ""
}

#Creation des répertoires, fichiers .conf .startup
function dir {
	echo ""
	echo -e "\e[34m ------ > Topology Configuration \e[0m"
	echo ""
	#Init variables
	echo "Name of the lab:"
	read name
	echo "Number of PC to create?"
	read pc_num
	echo "Number of Routers to create?"
	read r
	
	if [ "$pc_num" == "0" ] || [ "$r" == "0" ];then
		echo -e "\e[34m ------ > Lab should contains a minimum of 1 router and 1 Pc	\e[0m"
		exit
	fi
	
	#Create lab directory
	if [ ! -d ~/Documents/labs/"$name" ]; then
		mkdir ~/Documents/labs/"$name"
		echo "-> $name lab created at ~/Documents/labs/$name "
		echo ""
	else
		echo "Lab already created"
	fi

	#create lab.conf and lab.dep
	if [ ! -a ~/Documents/labs/"$name"/lab.conf ]; then
		touch ~/Documents/labs/"$name"/lab.conf
		lab_conf #appel à la fonction lab_conf
	fi
	if [ ! -a ~/Documents/labs/"$name"/lab.dep ]; then
		touch ~/Documents/labs/"$name"/lab.dep
	fi

	
	#create PCs
	for a in $(seq 1 $pc_num)
	do
		if [ ! -d ~/Documents/labs/"$name"/P"$a" ]; then 
			mkdir ~/Documents/labs/"$name"/P"$a"
			touch ~/Documents/labs/"$name"/P"$a".startup
			touch ~/Documents/labs/"$name"/P"$a".shutdown
		else
			echo "Directories already created"
		fi
	done
	
	echo -e "\e[34m ------ > Configure Networks Interfaces \e[0m"
	#configure PC network interfaces
	for t in $(seq 1 $pc_num)
	do
		node=P"$t"
		interface="eth0"
		echo ""
		echo "	Configure $node[$interface]"
		network	
		ordi="$t"
		addroute
	done

	#create Routers
	for b in $(seq 1 $r)
	do
		if [ ! -d ~/Documents/labs/"$name"/R"$a" ]; then
			mkdir ~/Documents/labs/"$name"/R"$b"
			touch ~/Documents/labs/"$name"/R"$b".startup
			touch ~/Documents/labs/"$name"/R"$b".shutdown
		fi
	done
	
	#configure Routers network interface
	r_num=$r
	for s in $(seq 1 $r_num)
	do
		node=R"$s"
		echo "Nomber of interfaces on router R$s :"
		read nbinterfacesrouter
		echo""
		for w in $(seq 1 $nbinterfacesrouter)
		do
			interface="eth$w"
			echo "	Configure $node[eth$w]"
			network
		done
	done
	
	#affichage de la configuration 
	screen
	
	echo -e "\e[34m  ------ > Start the lab ? (y or n) \e[0m "
	read ok
	if [ "$ok" ==  "y" ] || [ "$ok" == "Y" ];then
		lstart -d ~/Documents/labs/"$name"
		echo ""
		echo "Halt $labst lab by pressing enter"
		read 
		lhalt -d ~/Documents/labs/"$name"
		lclean
	else
		echo "Configuration done"
	fi
}

#Création des default gateway PC
function addroute 	{
	echo "Gateway for P$ordi : "
	read gw
	ok=`grep "route add" ~/Documents/labs/"$name"/P"$ordi".startup | wc -l`   #wc: word count
	if [ "$ok" == 0 ];then
		echo "route add default gw $gw" >> ~/Documents/labs/"$name"/P"$ordi".startup
	else
		echo "Default gateway already existing"
	fi
	echo ""
}

#Parametrage IPv4 des nodes, fichiers .startup
function network {
	echo "IP address: "
	read ip
	echo "Netmask : x.x.x.x"
	read netmask
	echo "ifconfig $interface $ip netmask $netmask" >> ~/Documents/labs/"$name"/"$node".startup
	echo "ifconfig $interface up" >> ~/Documents/labs/"$name"/"$node".startup
	echo " " >>  ~/Documents/labs/"$name"/"$node".startup
}

#Configuration lab.conf
function lab_conf {
	echo ""
	echo -e "\e[34m  ------ > Configure lab.conf file \e[0m"
	echo ""
	
	#Domain of routers
	if [ $r != 0 ];then
		for v in $(seq 1 $r)
		do
			echo "Numbers of interfaces on R$v:"
			read ni
			for i in $(seq 1 $ni)
				do
					echo "  R$v[eth$i]= "
					read dom
					echo "R$v[eth$i]=$dom " >>  ~/Documents/labs/"$name"/lab.conf 
				done
				echo "" >>  ~/Documents/labs/"$name"/lab.conf 
		done
		echo "" >>  ~/Documents/labs/"$name"/lab.conf 
		
	echo ""
		
	#Domain of PCs
	for g in $(seq 1 $pc_num)
	do
		echo "P$g[eth0]= ?"
		read dom2
		echo "P$g[eth0]=$dom2" >>  ~/Documents/labs/"$name"/lab.conf 
	done
		echo "" 
	else
	if [ "$r" == " " ];then
		echo "Wrong router node number"
	elif [ "$pc_num" == " "];then
		echo "Wrong PC node number"
	fi
	fi
}

#Ajout d'un nouveau noeud 
function add_lab_node {
	if [ -d ~/Documents/labs/"$nom_lab" ] && [ ! -d ~/Documents/labs/"$nom_lab"/"$new_node" ]; then
		mkdir ~/Documents/labs/"$nom_lab"/"$new_node"
		touch ~/Documents/labs/"$nom_lab"/"$new_node".startup
		echo ""
		echo "$new_node and $new_node.startup in lab $nom_lab"
		echo "how many interfaces of $new_node ?"
		read iinterface
		echo ""
		echo "------ > Configure lab.conf file "
		for w in $(seq 1 $iinterface)
		do
			echo "Domain of $new_node[eth$w] :"
			read domain
			echo "$new_node[eth$w]=$domain" >>  ~/Documents/labs/"$nom_lab"/lab.conf
			#appel impossible à la fonction network..
			echo "IP address of $new_node[eth$w]: "
			read ips
			echo "Netmask : x.x.x.x"
			read netmasks
			echo ""
			echo "ifconfig eth$w $ips netmask $netmasks" >> ~/Documents/labs/"$nom_lab"/"$new_node".startup
			echo "ifconfig eth$w up" >> ~/Documents/labs/"$nom_lab"/"$new_node".startup
		done
		if [ -a "$mem_node"  ];then
			echo "wrriten"	
			echo "$new_node[mem]=$mem_node" >> ~/Documents/labs/"$nom_lab"/lab.conf
		fi
		echo " " >> ~/Documents/labs/"$nom_lab"/lab.conf
		echo "New entry in lab.conf:"
		cat  ~/Documents/labs/"$nom_lab"/lab.conf
	else
		if [ ! -d ~/Documents/labs/"$nom_lab" ]; then
			echo "$nom_lab Lab not existing" 
		elif [ -d ~/Documents/labs/"$nom_lab"/"$new_node" ];then
			echo "$new_node  already existing"
		else
			echo "unknown error"
		fi
	fi
}

#supprimer un lab
function delete {
		if [ -d ~/Documents/labs/"$del" ];then
			echo "Sure to delete $del ?(y/n)"
			read ookk
			if [ "$ookk" == "y" ];then
				rm -r ~/Documents/labs/"$del"
				echo "--> $del lab deleted "
			fi
		else
			echo "No such lab to delete"
		fi
}

#afficher les labs
function show {
	cd ~/Documents/labs
	ls 
	if [ "$up" == "-d" ];then
		echo "$njr :"
		cd ~/Documents/labs/"$njr"
		tree
	fi
}

function help {
	echo "		-------------------------------"
	echo "		--- Network Labs Management ---"
	echo "		-------------------------------"
	echo ""
	echo "-c : create and configure new lab"
	echo "-s : start saved lab"
	echo "-d : delete lab configuration [lab_name]"
	echo "-t : compress lab directory"
	echo "-a : show list of Labs -d [lab_name] for details"
	echo " > : -l [lab_name] -n [new_node] (-m [memory]) : add new node to lab "
	echo ""
}

#démarrer le lab
function start {
	echo "which lab starts?"
	read labst
	lstart -d ~/Documents/labs/"$labst"
	echo ""
	echo "Halt $labst lab by pressing enter"
	read 
	lhalt -d ~/Documents/labs/"$labst"
	lclean
}

#compression d'un lab
function compress {
	echo "Compress wich lab ?"
	show
	read dossier
	if [ -d ~/Documents/labs/"$dossier" ];then
		cd ~/Documents/labs/"$dossier"
		if [ -a R1.disk ];then
			rm *.disk
		fi
		cd ..
		echo ""
		echo -e "\e[34m  ------ > Creating archive\e[0m "
		tar -zcvf "$dossier".tar.gz "$dossier"
		echo ""
		echo -e "\e[34m-> $dossier.tar saved at `pwd` \e[0m "
	else
		echo "No $dossier to compress"
	fi
}

#  R-U-N
#init lab directory
if [ ! -d ~/Documents/labs/ ];then
	mkdir ~/Documents/labs
	echo "	  (>> working directory ~/Documents/labs created <<) "
fi

#main
if [ "$1" == "-h" ]; then
	help
elif [ "$1" == "-l" ] && [ "$3" == "-n" ]; then				
	new_node="$4"
	mem_node="$6"
	nom_lab="$2"
	add_lab_node
elif [ "$1" == "-a" ]; then
	echo "		-------------------------------"
	echo "		--- Network Labs Management ---"
	echo "		-------------------------------"
	echo ""
	echo "  Labs saved: "
	up="$2"	
	njr="$3"
	show
elif [ "$1" == "-d" ]; then
	if [ ! -a "$2" ];then
		del="$2"
		delete
	else
		echo "use : -d [name_lab]"
	fi
elif [ "$1" == "-c" ]; then
	dir
elif [ "$1" == "-s" ]; then
	start
elif [ "$1" == "-t" ];then
	compress
else
	help
fi
