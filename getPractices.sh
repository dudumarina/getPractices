#!/bin/bash 
 
################################################################################### 
# Script: getPractices.sh
# Version: 1.00 
# 
# Descripcion: Script para descomprimir y generar reporte de copias burdas de actividades
# 
# (Descripcion de los codigos de salida del script) 
# Salida: 0 = Con exito 
#         !=0 Finalizacion incorrecta (error de parametros o anulado por usuario) 
# 
# Control de versiones: 
#   v.1.00 (Noviembre 2023): Creacion del script 
# 
#################################################################################### 
 

# 
### -------------------- Gestion de senyales -------------------------- #### 
# 
 
trap 'f_signal 1; exit' 1 
trap 'f_signal 2; exit' 2 
trap 'f_signal 3; exit' 3 
trap 'f_signal 9; exit' 9 # 9 no es atrapable 
trap 'f_signal 10; exit' 10 
trap 'f_signal 11; exit' 11 
trap 'f_signal 14; exit' 14 
trap 'f_signal 15; exit' 15 
trap 'f_signal 19; exit' 19 
trap 'f_signal 23; exit' 23 
trap 'f_signal 30; exit' 30 
trap 'f_signal 31; exit' 31 
 
# 
### -------------------- Variables -------------------------- #### 
# 
 
# Globales 
 
PARAMETROS=$@ 
MIN_PARAM=1
MAX_PARAM=1
CERO=0 
YES="Y" 
NO="N" 
 
# Directorios 
 
INIDIR=`pwd` 
TMPDIR=${INIDIR}/tmp
OUTPUTDIR=${INIDIR}/output
 
# Ficheros 

CKSUM_FILE=${OUTPUTDIR}/cksum_report.txt
 
# Errores criticos contemplados 
 
ERR_PARAM=1 # Parametros pasados al script erroneos 
 
# 
### -------------------- Funciones -------------------------- #### 
# 
 
f_fecha_hora() 
{ 
 # Escribe la fecha y la hora en un mismo formato para todo el script 
 # Llamar a esta funcion cada vez que se quiera escribir la hora 
 # Hacer llamadas frecuentes para controlar los tiempos de cada fase del proceso 
 
 FECHA=`date +'%d-%m-%Y'` 
 HORA=`date +'%H:%M:%S'` 
 echo "[${FECHA} ${HORA}]" 

# Ejemplo de uso:
# echo "`f_fecha_hora` - [`basename $0`] : Que me estas contando" | tee -a ${LOGFILE}
 
} 
 
f_signal () 
{ 
 
# Funcion que gestiona las senyales atrapadas mediante trap 
 
 SALIDA=300 
 SIGNAL=$1 
 echo | tee -a ${LOGFILE} 
 echo | tee -a ${LOGFILE} 
 echo " f_fecha_hora **** INTERRUPCION -> RECIBIDA SIGNAL ${SIGNAL} !!!" | tee -a ${LOGFILE} 
 echo | tee -a ${LOGFILE} 
 echo " DETENIDO POR EL USUARIO !!!" | tee -a ${LOGFILE} 
 echo " DETENIDO POR EL USUARIO !!!" | tee -a ${LOGFILE} 
 echo " DETENIDO POR EL USUARIO !!!" | tee -a ${LOGFILE} 
 echo | tee -a ${LOGFILE} 
 echo " f_fecha_hora **** INTERRUPCION -> RECIBIDA SIGNAL ${SIGNAL} !!!" | tee -a ${LOGFILE} 
 echo | tee -a ${LOGFILE} 
 echo "`f_fecha_hora` - Ejecucion interrumpida" | tee -a ${LOGFILE} 
 mv $LOGFILE echo $LOGFILE | sed 's#\.log#.KO.log#g' 
 
} 
 
f_checkExec ()  
{ 
 
# Si el primer parametro que recibe es distinto de 0 sale con ese codigo 
 
 C_EXIT=${1} 
 C_MESSAGE=${2} 
 
 if [ "X${C_EXIT}" != "X0" ] 
 then 
   echo "   ${C_MESSAGE} : ERROR ${C_EXIT}" 
   exit ${C_EXIT} 
 fi 
 
} 
 
f_help () 
{ 
 
# Funcion de ayuda 
 
 echo 
 echo " + Script: `basename $0`" 
 echo 
 echo " + Descripcion: Script para descomprimir y generar reporte de copias burdas de actividades en directorio $OUTPUTDIR" 
 echo "" 
 echo " + Pre-requisitos:" 
 echo "" 
 echo "   1. El fichero zip pasado como argumento es el que contiene las actividades del aula virtual" 
 echo 
 echo " + Ejecucion:" 
 echo 
 echo " `basename $0` Nombre_de_Fichero.zip" 
 echo 
 
} 
 
f_getParams () 
{ 
 
 # Funcion encargada del trato de parametros. 

 if [ $# -lt $MIN_PARAM ] || [ $# -gt $MAX_PARAM ] 
 then 
   f_help 
   f_checkExec $ERR_PARAM "- ERROR $ERR_PARAM: Parametros incorrectos" 
 fi 
 
 # Comprobamos que el fichero zip existe
 
 if ! [ -r "$1" ] 
 then 
   f_help 
   f_checkExec $ERR_PARAM "- ERROR $ERR_PARAM: No se puede acceder al fichero $1 " 
 fi 
 
} 
 
f_createFilesDirs () 
{ 
# Funcion que crea los ficheros y directorios necesarios para la ejecucion del script 


  if [ -r $TMPDIR ]
  then
    \rm -rf $TMPDIR
  fi

  if [ -r $OUTPUTDIR ]
  then
    \rm -rf $OUTPUTDIR
  fi
 
  mkdir -p $TMPDIR 
  mkdir -p $OUTPUTDIR
  touch $CKSUM_FILE

} 
 
f_maintenance () 
{ 
 
# Eliminamos el directorio tmp
 
 \rm -rf $TMPDIR

} 

f_extractAndGenerate ()
{

 unzip "$1" -d $TMPDIR 1>/dev/null 2>&1

 cd $TMPDIR

 find . -type f ! -name "list_file.tmp"  > $TMPDIR/list_file.tmp

 while read LINE
 do
 
   cksum "$LINE" >> $CKSUM_FILE 
   mv "$LINE" $OUTPUTDIR
     
 done <$TMPDIR/list_file.tmp 

 # Ordenamos el fichero cksum y mostramos las apariciones duplicadas

 cat $CKSUM_FILE | sort > 1
 mv 1 $CKSUM_FILE

 cat $CKSUM_FILE | awk '{print $1}' | uniq -d > $TMPDIR/duplicated.txt

 echo "" >> $CKSUM_FILE
 echo "- Listado de cksum con mas de una aparicion:" >> $CKSUM_FILE
 echo "" >> $CKSUM_FILE
 cat $TMPDIR/duplicated.txt >> $CKSUM_FILE

 cd $OLDPWD

}
 
# 
### -------------------- Main - Principal ------------------------- #### 
# 

# Comprobamos los parametros que recibe el script

f_getParams "$@"

# Creamos los ficheros y directorios necesarios para la ejecucion

f_createFilesDirs

# Extraemos los ficheros del zip, los movemos a destino y generamos el reporte de cksum

f_extractAndGenerate "$1"

# Eliminamos los ficheros y directorios que ya no son necesarios

f_maintenance

