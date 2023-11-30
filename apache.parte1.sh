#!/bin/bash
# Shell Script para aprender directivas de Apache donde se irán añadiendo paso a paso para que de tiempo a probarlas desde el navegador
# versión 1 parte1: Creación estructura, activación configuración, comprobaciones con chromium-browser
# Fernando Barcina - Nov-2020
# INSTALACIÓN
user=$(whoami)
if [ "$user" != "root" ]; then
   # Si no es root sale sin ejecutar nada
   echo "No eres root... :'(" 
   exit
fi
echo "Hola sr. Root! :) Procedamos con la instalación de LAMP y tree en el servidor..."
apt install lamp-server^ tree
IP_SERVIDOR=$(hostname --all-ip-addresses|tr -d '[[space]]')
#read -ep "Por favor introduce la IP de la máquina donde servirá Apache la intranet [$IP_SERVIDOR]:" -i "$IP_SERVIDOR"IP_SERVIDOR
read -ep "Por favor introduce la IP de la máquina donde servirá Apache la intranet, una de estas --> $IP_SERVIDOR:" IP_SERVIDOR
echo "COMANDOS CREACIÓN ESTRUCTURA WEB"
echo "Sitio intranet navegable con intranet.delarioja.red"
mkdir -p /var/www/intranet.delarioja.red/privada /var/www/intranet.delarioja.red/fernando
mkdir /var/log/apache2/intranet.delarioja.red
mkdir /home/delarioja/wiki
touch /var/www/intranet.delarioja.red/privada/troyano.exe /var/www/intranet.delarioja.red/privada/prog.bat /var/www/intranet.delarioja.red/privada/espia.sh
echo "Creando... Página privada navegable con intranet.delarioja.red/privada"; sleep 1
# sobre Heredoc o documentos insertados en scripts: https://stackoverflow.com/questions/2953081/how-can-i-write-a-heredoc-to-a-file-in-bash-script
tee /var/www/intranet.delarioja.red/privada/index.html << 'EOF'
	<html>
		<head>
			<title>Página BANEADA en /var/www/intranet.delarioja.red/privada/index.html</title>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
			<meta name="description" content="Baneada de privada de intranet">
			</head>
		<body>
			<h1>Página Privada con IP baneada</h1></br>
			<h2>Probando directiva Require para prohibir a IP 192.168.1.1 lo que indica que tú no tienes 192.168.1.1 porque sino verías FORBIDDEN</h2>
			<h3>Prueba desde el Servidor2 a acceder, por ejemplo mediante: elinks intranet.delarioja.red:8080/privada y verás el baneo configurado</h3>
		</body>
	</html>
EOF
echo "Creando... Página wiki navegable con intranet.delarioja.red/wiki"; sleep 1
tee /home/delarioja/wiki/wiki.html <<- 'EOF'
<html>
		<head>
			<title>PRIMEROS PASOS con WIKI /home/delarioja/wiki/wiki.html</title>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
			<meta name="description" content="Wiki Portal de intranet">
			</head>
		<body>
			<h1>Página Alias Wiki</h1></br>
			<h2>Probando directiva Alias para acceder a wiki en /home/delarioja/wiki metiendo url intranet.delarioja.red/wiki</h2>
		</body>
</html>
EOF
read -p "Cambio los permisos para que Apache pueda leer y escribir sin problemas ahora y en el futuro (Pulse Enter para Continuar)"
chown -R :www-data /home/delarioja/wiki /var/www/intranet.delarioja.red/
find /home/delarioja/wiki -type d -exec chmod g=rwxs "{}" \;
find /home/delarioja/wiki -type f -exec chmod g=rw  "{}" \;
find /var/www/intranet.delarioja.red/ -type d -exec chmod g=rwxs "{}" \;
find /var/www/intranet.delarioja.red/ -type f -exec chmod g=rw  "{}" \;

read -p "Creo el sitio intranet.conf (Pulse Enter para Continuar)"
# Generamos fichero /etc/apache2/sites-available/intranet.conf
tee /etc/apache2/sites-available/intranet.conf << EOF
	Listen 8080 http
	<VirtualHost $IP_SERVIDOR:8080>
		ServerName intranet.delarioja.red
		DocumentRoot /var/www/intranet.delarioja.red
		DirectoryIndex inicio.html inicio.htm pagina.html pagina.htm pag.html pag.htm
		ErrorDocument 404 "<html><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'></head><body><h1>Error 404 - P&aacute;gina n'encontr&aacute;</h1></body></html>"
		ErrorLog /var/log/apache2/intranet.delarioja.red/error.log
		CustomLog /var/log/apache2/intranet.delarioja.red/access.log combined
		Alias /wiki/ "/home/delarioja/wiki/"
		Redirect permanent "/fernando" "https://delarioja.org/moodle"
		<Directory "/home/delarioja/wiki">
			   Options -Indexes
			   AllowOverride All
			   Require all granted
		</Directory>
		<Directory "/var/www/intranet.delarioja.red/privada">
                                Options +Indexes
                                AllowOverride All
                                <RequireAll>
                                Require all granted
                                # Baneamos esta IP para que todos menos ella tengan acceso
                                Require not ip 192.168.1.1
                                </RequireAll>
		</Directory>
	</VirtualHost>
EOF
read -p "Activando sitio y reiniciando dado que se abre el 8080 (Pulse Enter)"
a2ensite intranet
systemctl restart apache2
read -p "Compruebo sintaxis y muestro VirtualHost actualmente activos (Pulse Enter)"
apache2ctl -t
apache2ctl -S
echo "Ya puedes probar ejecutar el fichero apache.parte1.comprobaciones.sh desde el cliente"
