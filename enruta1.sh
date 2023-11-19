#!/bin/bash

# Solamente se puede ejecutar el archivo si es por root o usando sudo

# $(id -u) # Obtiene el id del usuario actual
# Si el usuario actual tiene como id 0 significa que es root
# Si el id del usuario actual NO es 0 entonces...
if [ "$(id -u)" != "0" ]; then
	# Muestra un mensaje en consola al usuario actual cuando no es root
	echo "Ejecuta este script como root (o usando sudo)."
	# Termina el script con un c�digo 1
	# Normalmente en bash cuando un programa retorna algo diferente a 0
	# significa que gener� un error
	exit 1
# Fin del if
fi

# cambio no persistente, explicado en el siguiente video, que activa el sistema como enrutador
#echo 1 > /proc/sys/net/ipv4/ip_forward
# el cambio persistente consiste en quitar una almohadilla en el fichero /etc/sysctl.conf

sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

# reglas del cortafuegos que se explicaran con mas detalle en la unidad 6

# para activar nateo con enmascaramiento hacia la interfaz de salida a Internet, si hubiera varias interfaces de salida especificamos con la opcion -o: p.ej. "-o enp0s3"
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j MASQUERADE

# para permitir reenvio de paquetes de la RED1
iptables -A FORWARD -s 192.168.1.0/24 -j ACCEPT

# estos 2 comandos anteriores no se guardan si hay reinicios; las guardamos con este comando

# iptables-save > /etc/iptables.rules
# las recuperamos con este otro 
# iptables-restore < /etc/iptables.rules
# nosotros usaremos un paquete que automaticamente creara el servicio para que active las reglas del cortafuegos al arrancar el servidor

apt install iptables-persistent

# para reconfigurar: dpkg-reconfigure iptables-persistent
# guardar: netfilter-persistent save
# restaurar: netfilter-persistent reload
