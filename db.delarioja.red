;
; BIND data file for delarioja.red zone
; Fichero de zona de delarioja.red para BIND
; por Fernando Barcina
;
$TTL    1d
$ORIGIN delarioja.red.
@       IN      SOA     dns1.delarioja.red. fernando.delarioja.red. (
                 2020102801         ; Serial AÃ±oMesDÃ­aNÃºmerocorrelativo
                         2h         ; Refresh
                         1h         ; Retry
                         2w         ; Expire
                         1d )       ; Negative Cache TTL
;
@               IN      NS      dns1.delarioja.red.
@               IN      A       192.168.1.100
dns1            IN      A       192.168.1.100
dns2            IN      A       192.168.1.1
servidor1       IN      CNAME   dns1
servidor2       IN      A       192.168.2.100
www             IN      CNAME   dns1
intranet        IN      CNAME   dns1
ftp             IN      CNAME   dns1
ntp             IN      CNAME   dns1
cliente10-red1  IN      A       192.168.1.10
$GENERATE 20-50 cliente$-red1         IN      A       192.168.1.$
$GENERATE 20-50 cliente$-red2         IN      A       192.168.2.$
correo          IN      A       192.168.1.100
correo2         IN      A       192.168.1.1
; si tenemos nuestros propios servidores de correo
@               IN      MX 5    correo
@               IN      MX 10   correo2
delarioja.red.  IN      TXT     "v=spf1 a:correo.delarioja.red -all"
; SPF es como un tipo de TXT esta segunda linea puede aÃ±adirse o no:
;delarioja.red. IN      SPF     "v=spf1 a:correo.delarioja.red -all"

; si queremos activar G Suite para nuestro nombre de dominio, https://support.google.com/a/answer/174125?hl=es
; habria que sustituir los MX anteriores por:
; @ 3600	MX	1	ASPMX.L.GOOGLE.COM.
;   3600	MX	5	ALT1.ASPMX.L.GOOGLE.COM.
;   3600	MX	5	ALT2.ASPMX.L.GOOGLE.COM.
;   3600        MX	10	ALT3.ASPMX.L.GOOGLE.COM.
;   3600	MX	10	ALT4.ASPMX.L.GOOGLE.COM.
;@         IN      TXT     "v=spf1 mx include:_spf.google.com ~all"
; lo que permitiria que reenvien correos de nuestro dominio los hosts especificados por registros MX en nuestro dominio
; incluidos los de G Suite: ASPMX.L.GOOGLE.COM., etc. 
