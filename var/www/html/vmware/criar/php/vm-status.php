<?php

     $vARQUIVO = glob("/var/www/html/vmware/config/" . $_GET['nome'] . ".*");
     if (empty($vARQUIVO)) {
        $vARQUIVO = glob("/opt/appsrv/scripts/finalizados/" . $_GET['nome'] . ".pronto");
        if (empty($vARQUIVO)) {
           echo "*** Verificação falhou";
        } else {
           echo "VM pronta para uso";
        }
        exit;
     }

     $vSTATUS = ucfirst( substr($vARQUIVO[0], strpos($vARQUIVO[0], ".") + 1) );

     echo $vSTATUS;
?>
