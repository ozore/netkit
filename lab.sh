 #!/bin/bash

#Creation des répertoires 
function dir {
	#Init variables
	echo "Name of the lab?"
	read name
	echo "Number of PC to create?"
	read pc
	echo "Number of Routers to create?"
	read r
	echo " "
	
	#Create lab directory
	if [ ! -d ~/Documents/labs/"$name" ]; then
		mkdir ~/Documents/labs/"$name"
		echo "Lab created at ~/Documents/labs/$name "
	else
		echo "Lab already created"
	fi

	#create PCs
	for a in $(seq 1 $pc)
	do
		if [ ! -d ~/Documents/labs/"$name"/P"$a" ]; then 
			mkdir ~/Documents/labs/"$name"/P"$a"
			touch ~/Documents/labs/"$name"/P"$a".startup
		else
			echo "Directories already created"
		fi
	done

	#create Routers
	for b in $(seq 1 $r)
	do
		if [ ! -d ~/Documents/labs/"$name"/R"$a" ]; then
			mkdir ~/Documents/labs/"$name"/R"$b"
			touch ~/Documents/labs/"$name"/R"$b".startup
		fi
	done

	#create lab.conf and lab.dep
	if [ ! -a ~/Documents/labs/"$name"/lab.conf ]; then
		touch ~/Documents/labs/"$name"/lab.conf
		#appel à la fonction lab_conf
		lab_conf
	fi
	if [  -a ~/Documents/labs/"$name"/lab.dep ]; then
		touch ~/Documents/labs/"$name"/lab.dep
	fi
}

#Configuration lab.conf
function lab_conf {
	echo ""
	echo "------------ > Configure lab.conf file "
	
	#Domain of routers
	if [ $r != 0 ];then
		for v in $(seq 1 $r)
		do
			echo "Numbers of interfaces on router R$v:"
			read ni
			for i in $(seq 1 $ni)
				do
					echo "R$v[eth$i]= ?"
					read dom
					echo "R$v[eth$i]=$dom " >>  ~/Documents/labs/"$name"/lab.conf 
				done
				echo "" >>  ~/Documents/labs/"$name"/lab.conf 
		done
		echo "" >>  ~/Documents/labs/"$name"/lab.conf 
		
		echo ""
		#Domain of PCs
		for g in $(seq 1 $pc)
		do
			echo "P$g[eth0]= ?"
			read dom2
			echo "P$g[eth0]=$dom2" >>  ~/Documents/labs/"$name"/lab.conf 
		done
		echo ""
		echo "		lab.conf :"
		cat ~/Documents/labs/"$name"/lab.conf 
	else
		echo "Not correct number"
	fi
}

#Ajout d'un nouveau noeud 
function add_lab_node {
	if [ -d ~/Documents/labs/"$nom_lab" ]; then
		mkdir ~/Documents/labs/"$nom_lab"/"$new_node"
		touch ~/Documents/labs/"$nom_lab"/"new_node".startup
		echo ""
		echo "$new_node and $new_node.startup in lab $nom_lab"
		echo "Domain of $new_node :"
		read domain
		echo "$new_node[eth0]=$domain" >>  ~/Documents/labs/"$nom_lab"/lab.conf
		echo "$new_node[mem]=$mem_node" >> ~/Documents/labs/"$nom_lab"/lab.conf
		echo "New entry in lab.conf:"
		cat  ~/Documents/labs/"$nom_lab"/lab.conf
	else
		echo "Lab $nom_lab not existing"
	fi
}

#supprimer un lab
function delete {
	if [ -d ~/Documents/labs/"$del" ];then
		rm -r ~/Documents/labs/"$del"
	else
		echo "No such lab to delete"
	fi
}

#afficher les labs
function show {
	echo "Labs created: "
	cd ~/Documents/labs
	tree
}

function help {
	echo ""
	echo "-c : create lab"
	echo "-d : delete lab "
	echo "-a : show all lab configuration"
	echo "-s : start lab with netkit"
	echo "-d : delete lab configuration"
	echo "-l [lab_name] -n [new_node] -m [memory] : add new node "
	echo "-h : this help page"
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
}


#RUN
echo "		--- Network Labs Management ---"
#init lab directory
if [ ! -d ~/Documents/labs/ ];then
	echo ""
	echo "1) NETKIT tools should be installed and well-configured"
	mkdir ~/Documents/labs
	echo "2) working directory ~/Documents/labs created"
fi

#principal
if [ "$1" == "-h" ]; then
	help
elif [ "$1" == "-l" ] && [ "$3" == "-n" ]; then				
	new_node="$4"
	mem_node="$6"
	nom_lab="$2"
	add_lab_node
elif [ "$1" == "-a" ]; then
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
else
	help
fi

