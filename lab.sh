 #!/bin/bash

#Creation des répertoires 
function dir {
	echo ""
	echo "------ > General Configuration"
	#Init variables
	echo "Name of the lab:"
	read name
	echo "Number of PC to create?"
	read pc_num
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

	#create lab.conf and lab.dep
	if [ ! -a ~/Documents/labs/"$name"/lab.conf ]; then
		touch ~/Documents/labs/"$name"/lab.conf
		#appel à la fonction lab_conf
		lab_conf
	fi
	if [  -a ~/Documents/labs/"$name"/lab.dep ]; then
		touch ~/Documents/labs/"$name"/lab.dep
	fi

	#create PCs
	for a in $(seq 1 $pc_num)
	do
		if [ ! -d ~/Documents/labs/"$name"/P"$a" ]; then 
			mkdir ~/Documents/labs/"$name"/P"$a"
			touch ~/Documents/labs/"$name"/P"$a".startup
		else
			echo "Directories already created"
		fi
	done
	
	echo "------ > Configure Networks "
	#configure PCs network interfaces
	for t in $(seq 1 $pc_num)
	do
		node=P"$t"
		interface="eth0"
		echo ""
		echo "	Configure $node[$interface]"
		network	
		cat ~/Documents/labs/"$name"/"$node".startup
	done

	#create Routers
	for b in $(seq 1 $r)
	do
		if [ ! -d ~/Documents/labs/"$name"/R"$a" ]; then
			mkdir ~/Documents/labs/"$name"/R"$b"
			touch ~/Documents/labs/"$name"/R"$b".startup
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
			cat ~/Documents/labs/"$name"/"$node".startup
		done
	done
	
	echo "------ > Start the lab ? (y or n)"
	read ok
	if [ $ok ==  "y" ];then
		lstart -d ~/Documents/labs/"$name"
		echo ""
		echo "Halt $labst lab by pressing enter"
		read 
		lhalt -d ~/Documents/labs/"$name"
	fi

}

#Parametrage ip
function network {
	echo "IP address: "
	read ip
	echo "Netmask : x.x.x.x"
	read netmask
	echo ""
	echo "ifconfig $interface $ip netmask $netmask" >> ~/Documents/labs/"$name"/"$node".startup
	echo "ifconfig $interface up" >> ~/Documents/labs/"$name"/"$node".startup
	echo " " >>  ~/Documents/labs/"$name"/"$node".startup
	echo "	---	$node.startup ---"
	echo ""
}

#Configuration lab.conf
function lab_conf {
	echo ""
	echo "------ > Configure lab.conf file "
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
		echo "		lab.conf "
		cat ~/Documents/labs/"$name"/lab.conf 
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
		touch ~/Documents/labs/"$nom_lab"/"new_node".startup
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
			echo "unknown error "
		fi
	fi
}

#supprimer un lab
function delete {
	if [ -d ~/Documents/labs/"$del" ];then
		rm -r ~/Documents/labs/"$del"
		echo "-> $del lab deleted"
	else
		echo "No such lab to delete"
	fi
}

#afficher les labs
function show {
	echo "  Labs saved: "
	cd ~/Documents/labs
	ls 
	echo "$up"
	if [ "$up" == "-d" ];then
		tree
	fi
}

function help {
	echo "		-------------------------------"
	echo "		--- Network Labs Management ---"
	echo "		-------------------------------"
	echo ""
	echo "-c : create new lab"
	echo "-d : delete lab "
	echo "-a : show list of Labs (-d details)"
	echo "-s : start saved lab"
	echo "-d : delete lab configuration"
	echo "-l [lab_name] -n [new_node] (-m [memory]) : add new node "
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

# - R-U-N- -
function run {
#init lab directory
if [ ! -d ~/Documents/labs/ ];then
	echo ""
	echo "1) NETKIT tools should be installed and well-configured"
	mkdir ~/Documents/labs
	echo "2) working directory ~/Documents/labs created"
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
	up="$2"	
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
}

run
echo " "
