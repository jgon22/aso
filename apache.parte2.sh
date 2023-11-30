#!/bin/bash
# Shell Script para aprender directivas de Apache donde se irán añadiendo paso a paso para que de tiempo a probarlas desde el navegador
# versión parte2: Creación estructura www, activación configuración, comprobaciones con chromium-browser en script adidiconal: apache.parte2.comprobaciones.sh
# Fernando Barcina - Nov-2021
# Instanciar la variable de abajo con la IP de la máquina donde se va a ejecutar
# Probado en UBUNTU 20.04
#Crea un sitio donde haya una subcarpeta/zona de acceso por autenticación utilizando el módulo auth_basic. Dicha carpeta se llamará "administrator".
#Comprueba el acceso por enlace simbólico al blog. Modifica el sitio para que la IP 192.168.1.1 no pueda navegar el blog.
#Permite que dicho sitio se pueda navegar tanto por http como por https.
IP_SERVIDOR=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
user=$(whoami)
if [ "$user" != "root" ]; then
   # Si no es root sale sin ejecutar nada
   echo "No eres root... :'("
   exit
fi
# INSTALACIÓN
if (whiptail --title "Hola sr. $user! :)" --yes-button "Adelante!" --no-button "No, ya está instalado" --yesno "¿Procedemos con la instalación de LAMP?" 8 78) then
    apt update && apt install lamp-server^ tree
else
    echo "Has seleccionado No, el if toma el valor de $? y continuo con el script"
fi
if (whiptail --title "Escribiendo en el fichero hosts: $IP_SERVIDOR www.delarioja.red" --yes-button "Aceptar" --no-button "Cancelar" --yesno "¿Modifico /etc/hosts?" 8 78) then
	echo $IP_SERVIDOR www.delarioja.red >> /etc/hosts
fi

#COMANDOS CREACIÓN ESTRUCTURA WEB
#Sitio navegable con www.delarioja.red
echo "Creando estructura de web www.delarioja.red"; sleep 1
mkdir -p /var/www/www.delarioja.red/administrator
mkdir /var/log/apache2/www.delarioja.red
mkdir -p /home/delarioja/blog
ln -s /home/delarioja/blog /var/www/www.delarioja.red/
wget https://delarioja.org/web_images/404.png
mv 404.png /var/www/www.delarioja.red/
# Cuando naveguemos www.delarioja.red/blog seguira el acceso directo que acabamos de crear
cat <<'EOF' > /home/delarioja/blog/index.html
<html>
		<head>
			<title>PRIMEROS PASOS CON BLOG de www.delarioja.red</title>
			<meta name="description" content="BLOG de www.delarioja.red">
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
                </head>
		<body>
		<h1>Página Acceso Blog</h1></br> <h2>Probando directiva Options FollowSymlinks que requiere un acceso directo para llegar a /home/delarioja/blog/index.html desde /var/www/www.delarioja.red/blog</h2></br> <h3>Atención con esto dado que los permisos de /home/delarioja/blog/index.html van a dar igual (prueba a hacer un 000) y los que priman serán los de /var/www/www.delarioja.red/blog</h3>
		</body>
</html>
EOF

# Cuando error 404 en www.delarioja.red
cat << 'EOF' > /var/www/www.delarioja.red/no-encontrada.htm
<html>
		<head>
			<title>PAGINA PARA ERRORES 404</title>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
			<meta name="description" content="Pagina no encontrada">
                </head>
		<body><h1>Página NO ENCONTRADA</h1></br>
		<h2>Probando directiva ErrorDocument estás navegando una URL inexistente y por defecto se te muestra esto /var/www/www.delarioja.red/no-encontrada.htm</h2>
		<p align="justify"><img src="/404.png" name="404" align="center" width="517" height="330" border="0" /></p>
		</body>
</html>
EOF
# Cuando naveguemos www.delarioja.red/administrator
cat << 'EOF' > /var/www/www.delarioja.red/administrator/index.html
	<html>
		<head>
			<title>Página de administración o BACKEND</title>
			<meta name="description" content="BACKEND de www.delarioja.red">
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
                </head>
		<body><h1>BACKEND de www.delarioja.red</h1></br> <h2>Probando autenticación basic pero con capa de seguridad SSL si se pone https delante de la URL</h2>
		</body>
        </html>
EOF
{
    echo -e "XXX\n0\nCambiando grupo propietario www-data... \nXXX"
    chown -R :www-data /home/delarioja/blog /var/www/www.delarioja.red/
    echo -e "XXX\n33\nCambiando grupo propietario www-data... HECHO.\nXXX"
    sleep 0.5

    echo -e "XXX\n33\nCambiando permisos de directorios... \nXXX"
    find /home/delarioja/blog -type d -exec chmod g=rwxs "{}" \;
    find /var/www/www.delarioja.red/ -type d -exec chmod g=rwxs "{}" \;
    echo -e "XXX\n66\nCambiando permisos de directorios... HECHO.\nXXX"
    sleep 1

    echo -e "XXX\n66\nCambiando permisos de ficheros... \nXXX"
    find /home/delarioja/blog -type f -exec chmod g=rw  "{}" \;
    find /var/www/www.delarioja.red/ -type f -exec chmod g=rw  "{}" \;
    echo -e "XXX\n100\nCambiando permisos de ficheros... HECHO.\nXXX"
    sleep 0.5
} |whiptail --title "Cambiando permisos" --gauge "Espere por favor" 6 60 0


#ZONA PRIVADA
read -p "Generando fichero de claves .htpasswd para acceso basic a carpetas inseguras protegidas por contraseña (pulsa Enter para Continuar)"
mkdir /var/www/passwd
echo "Generando /var/www/passwd/.htpasswd, introduce contraseña de neo"
htpasswd -c /var/www/passwd/.htpasswd neo
echo "Generando /var/www/passwd/.htpasswd, introduce contraseña de trinity"
htpasswd /var/www/passwd/.htpasswd trinity
echo "Generando /var/www/passwd/.htpasswd, introduce contraseña de delarioja"
htpasswd /var/www/passwd/.htpasswd delarioja
# por si queremos probar también grupos
cat > /var/www/passwd/.htgroup <<EOF
    Matrix: neo trinity
EOF
if test $(dpkg --get-selections |grep "^openssl"|wc -l) -eq 0
then
	sudo apt update
	sudo apt install openssl
fi
read -p "Generando clave y certificado autofirmado para el SSL de www-ssl.conf. ¡Atención! es importante que pongas *.delarioja.red cuando se te pida el FQDN del certificado (pulsa Enter para Continuar)"
openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /etc/ssl/private/www.delarioja.red.key -out /etc/ssl/certs/www.delarioja.red.crt
chown root:ssl-cert /etc/ssl/private/www.delarioja.red.key
chmod 640 /etc/ssl/private/www.delarioja.red.key

	# Generando fichero /etc/apache2/sites-available/www-ssl.conf
	 cat > /etc/apache2/sites-available/www-ssl.conf <<'EOF'
        #Qué pasaría si en la definición del VirtualHost pusiéramos también *:80?
        #Respuesta: que se abriría ese puerto para comunicación https (ver SSLEngine a On más abajo) y sería inesperado para el usuario
	<VirtualHost *:443>
		ServerName delarioja.red
		ServerAlias www.delarioja.red
		DocumentRoot /var/www/www.delarioja.red
		ErrorDocument 404 /no-encontrada.htm
		ErrorLog ${APACHE_LOG_DIR}/www.delarioja.red/error.log
		CustomLog ${APACHE_LOG_DIR}/www.delarioja.red/access.log combined
		<Directory "/var/www/www.delarioja.red">
			   AllowOverride All
			   Require all granted
		</Directory>
		<Directory "/var/www/www.delarioja.red/blog">
			   Options -Indexes +FollowSymLinks
			   AllowOverride None
			   Require all granted
		</Directory>
		#Documentación oficial de lo siguiente https://httpd.apache.org/docs/current/es/howto/auth.html
		<Directory "/var/www/www.delarioja.red/administrator">
			   #Si quisiéramos las directivas subsiguientes a nivel de .htaccess ubicado en la carpeta administrator
			   #AllowOverride AuthConfig

			   AuthType Basic
			   AuthName "Acceso restringido"

			   # La siguiente linea es opcional
			   # AuthBasicProvider file

			   AuthUserFile "/var/www/passwd/.htpasswd"

			   #Con esta entrarían solo el usuario neo y delarioja
			   Require user neo delarioja

			   #Con esta entrarían solo los del grupo Matrix creado anteriormente, quedaría habilitar el módulo authz_groupfile que no viene activado por defecto
			   #AuthGroupFile "/var/www/passwd/.htgroup"
			   #Require group Matrix
			   # y con esta cualquiera que salga en el fichero de usuarios
			   #Require valid-user
		</Directory>
		#Añadimos seguridad con SSL a esa autenticación Basic que no va encriptada, esto forzará a que se tenga que navegar por https://www.delarioja.red o https://www.delarioja.red:80
		SSLEngine On
		SSLCertificateFile /etc/ssl/certs/www.delarioja.red.crt
		SSLCertificateKeyFile /etc/ssl/private/www.delarioja.red.key
		# otras que no son necesarias pero se podrían descomentar
		#SSLCipherSuite RSA:+HIGH:+MEDIUM
		#SSLProtocol all
		# Si queremos deshabilitar UserDir para el exterior dado que prevemos un servicio sólo para nuestros empleados en intranet
		#<IfModule mod_userdir.c>
                #    UserDir disabled
		#</IfModule>
	</VirtualHost>
EOF

    read -p "Habilito módulo ssl (Pulsa Enter)"
    a2enmod ssl authz_groupfile

    read -p "Activando sitio y reiniciando (Pulse Enter)"
    a2ensite www-ssl
    echo "Ejecutando systemctl restart apache2 (atención abrimos 443)"; sleep 1
    systemctl restart apache2
    read -p "Compruebo configuración y muestro VirtualHost actualmente activos (Pulse Enter)"
    apache2ctl configtest
    apache2ctl -S
