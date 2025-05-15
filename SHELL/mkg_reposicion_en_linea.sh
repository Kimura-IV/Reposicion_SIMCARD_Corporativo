#==============================================================================================#
# LIDER SIS	          : TIC Luis Flores
# LIDER PDS			      : SUD Gabriel Villanueva
# DESARROLLADOR	      : SUD Joe Velez
# COMENTARIO          : Este script ejecuta el procedimiento P_REPONE_COLA_EN_LINEA desde el paquete PORTA.CLK_REPOSICION_SIM_EN_LINEA en PL/SQL.
# FECHA DE CREACION   : 22/08/2023
#==============================================================================================#
#Datos para prod
#---------------------
. /ora1/gsioper/.profile
#-----------------------------------------
#Configuracion
#-----------------------------------------
RUTA_PRG=/ora1/gsioper/procesos/reposimlinea
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
file_log=$RUTA_PRG/log/LogRepoSimLinea_$fechahoy".log"

# Inicio del registro de log
echo "==================== [ `date '+%d-%m-%Y %H:%M:%S'` ] Inicio de Reposicion en Linea ====================" >> $file_log

# Llamada al procedimiento PL/SQL
ruta_libreria="/home/gsioper/librerias_sh"
. $ruta_libreria/Valida_Ejecucion.sh

cat > $blqSql << eof_sql
SET SERVEROUTPUT ON
BEGIN
  PORTA.CLK_REPOSICION_SIM_EN_LINEA.P_REPONE_COLA_EN_LINEA;
END;
/
EXIT;
eof_sql

# Registro de resultados en el log
echo "- Procesando registros correspondientes a la fecha: $fechaprc " >> $file_log
echo "- Ejecutando el proceso [PORTA.CLK_REPOSICION_SIM_EN_LINEA.P_REPONE_COLA_EN_LINEA]...." >> $file_log
echo $pass_axis | sqlplus -s $usu_axis @$blqSql > $logSql

# Verificación de errores
error=`cat $logSql | egrep "ERROR|ORA-" | wc -l`
echo "-------------------------------------------------------------" >> $file_log
if [ $error -gt 0 ]; then
    echo "- Error al ejecutar proceso: " >> $file_log
    cat $logSql >> $file_log
    rm -f $logSql
    echo "- Fin de proceso automatico con error" >> $file_log
    exit 1
fi

# Éxito en la ejecución
cat $logSql >> $file_log
echo "- Proceso completado con éxito" >> $file_log
echo "- Fin de proceso automatico" >> $file_log

# Limpieza de archivos temporales
rm -f $logSql $blqSql
exit 0