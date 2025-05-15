#==============================================================================================#
# LIDER SIS	          : TIC Grace Lopez
# LIDER PDS			  : SUD Sandy Garcia
# DESARROLLADOR	      : SUD Victor Vera
# COMENTARIO          : Proceso que actualiza las facturas a las ordenes generadas por Payback
# FECHA DE CREACION   : 09/01/2023
#==============================================================================================#
#Datos para prod
#---------------------
. /ora1/gsioper/.profile
#-----------------------------------------
#Configuracion
#-----------------------------------------
RUTA_PRG=/ora1/gsioper/procesos/payback
cd $RUTA_PRG
#Servidor AXIS PROD
# -------------------
usu_axis=porta
pass_axis=`/ora1/gsioper/key/pass $usu_axis`

# desarrollo
#usu_axis=portarfe
#pass_axis=portarfe

#--------------------------------
#Declaracion de variables
#--------------------------------
blqSql=$RUTA_PRG/sql/prcUpdate.sql
logSql=$RUTA_PRG/log/logproceso.log

fechahoy=`date +'%Y%m'`
fechaprc=`date +%d"/"%m"/"%Y`
file_log=$RUTA_PRG/log/LogActualizaFacturaPayback_$fechahoy".log"

echo "==================== [ `date '+%d-%m-%Y %H:%M:%S'` ] Inicio de actualizacion de facturas para Payback ====================" >> $file_log

#validar doble ejecucion
ruta_libreria="/home/gsioper/librerias_sh"
. $ruta_libreria/Valida_Ejecucion.sh

cat > $blqSql << eof_sql
SET SERVEROUTPUT ON
SET HEADING OFF
declare
  cursor c_datos_pay(cvfecha varchar2) is
      select distinct c.sub_no_orden no_orden, c.origen_trx, c.id_solicitud idtrx
        from porta.mk_datos_transacciones_payback c
       where c.sub_no_orden is not null
         and c.sub_no_factura is null
         and trunc(c.fecha_registro) = to_date(cvfecha, 'dd/mm/yyyy')
       order by c.id_solicitud;
	   
  lv_mensaje       varchar2(4000) := null;
  lv_fecha_prc     varchar2(10):= '$fechaprc';
  lc_datos         c_datos_pay%rowtype;
  lb_found         boolean := false;
begin
    -- fecha de proceso sysdate -1 
	lv_fecha_prc := to_char(sysdate-1, 'dd/mm/yyyy');
    -- validar si existen datos para procesar
	open c_datos_pay(lv_fecha_prc);
	fetch c_datos_pay into lc_datos;
	lb_found := c_datos_pay%found;
	close c_datos_pay;
	
	if lb_found then
		porta.MKK_CANJE_PTO_MSV.MKP_ACTUALIZA_FACTURA_PAYBACK(PV_FECHA   => lv_fecha_prc,
																 PV_MENSAJE => lv_mensaje);
	  
		if lv_mensaje is not null then
			dbms_output.put_line(lv_mensaje);
		end if;
	else
	    dbms_output.put_line('- No se encontraron datos para la fecha :' || lv_fecha_prc);
		dbms_output.put_line('- No se actualizaron registros.');
	end if;
exception
  when others then
    lv_mensaje := sqlerrm || lv_mensaje;
    dbms_output.put_line('ERROR: ' || lv_mensaje);
end;
/
exit;
eof_sql

echo "- Procesando registros correspondientes a la fecha: $fechaprc " >> $file_log
echo "- Ejecutando el proceso [MKK_CANJE_PTO_MSV.MKP_ACTUALIZA_FACTURA_PAYBACK]...." >> $file_log
echo $pass_axis | sqlplus -s $usu_axis @$blqSql > $logSql
error=`cat $logSql | egrep "ERROR|ORA-" | wc -l`
echo "-------------------------------------------------------------" >> $file_log
if [ $error -gt 0 ]; then
	echo "- Error al ejecutar proceso: " >> $file_log
	cat $logSql >> $file_log
	rm -f $logSql $blqSql
	echo "- Fin de proceso automatico " >> $file_log
	exit 1
fi

cat $logSql >> $file_log
echo "- Fin de proceso automatico " >> $file_log

rm -f $logSql $blqSql
exit 0
