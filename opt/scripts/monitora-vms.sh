#!/bin/bash
#
# Script...: monitora-vms.sh
# Descricao: Monitora diretorio para a criacao de VM
# Autor....: Eugenio Oliveira

__start() {

   if [ -f /var/run/monitora-vms.pid ]; then
      echo "Já existe um processo em execução (/var/run/monitora-vms.pid)."
      exit 255
   fi

   vPID=$(ps ax|grep monitora-vms.sh|grep -v grep|awk '{print $1}')
   echo $vPID > /var/run/monitora-vms.pid

   while :; do

      vDATA=$(date +"%Y-%m-%d_%H-%M")

      vDIR="/var/www/html/vmware/config/"
      vARQS=$(find $vDIR -type f -iname *.criar)

      cd /opt/scripts
      for vARQ in $vARQS ; do 
        vVM=$(basename $vARQ)
        vVM=$(echo ${vVM%'.'*})
        mv $vDIR/$vVM.criar $vDIR/$vVM.criando
        /opt/scripts/criar-vms.ps1 $vVM > /opt/scripts/logs/$vVM-$vDATA &
      done
      find $vDIR -cmin +60 -iname '*.pronto' -exec mv {} /opt/scripts/finalizados/ \;

      sleep 20s

   done

}

__stop() {

   vPID=""
   if [ -f /var/run/monitora-vms.pid ]; then
      vPID=$(cat /var/run/monitora-vms.pid)
   fi
   if [ -z "$vPID" ]; then
      echo "O processo do monitora-vms.sh não foi encontrado."
   else
      kill -9 $vPID > /dev/null 2>&1
   fi
   rm -f /var/run/monitora-vms.pid

}

case "$1" in
   stop)
     __stop
   ;;
   start)
     __start
   ;;
   *)
     echo "Faltou o parametro de [start|stop]"
     exit 255
   ;;
esac
