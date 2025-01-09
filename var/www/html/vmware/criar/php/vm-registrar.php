<?php

     //Captura os dados do formulario

     $VMNome = $_POST['VMNome'];
     if (empty($VMNome)) {
        exit;
     }

     $vDIR="/var/www/html/vmware/config";

     $vARQUIVO = glob($vDIR . "/" . $VMNome . ".*");
     if (!empty($vARQUIVO)) {
        echo "ERRO: Já existe um arquivo para esta VM " . $VMNome;
        exit;
     }

     $VMIP = $_POST['VMIP'];
     $VMVCPU = $_POST['VMVCPU'];
     $VMRAM = $_POST['VMRAM'];
     $VMNOTA = $_POST['VMNOTA'];
     $VMTMPL = $_POST['VMTMPL'];

     if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
         $TSEIP = $_SERVER['HTTP_CLIENT_IP'];
     } elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
         $TSEIP = $_SERVER['HTTP_X_FORWARDED_FOR'];
     } else {
         $TSEIP = $_SERVER['REMOTE_ADDR'];
     }

     //Concatena os valores no formato ipara salvar no csv
     $vTEXTO = $VMNome . ";" . $VMIP . ";" . $VMVCPU . ";" . $VMRAM . ";" . $VMNOTA . ";" . VMTMPL;

     //Abre o arquivo para gravar se nao existir ele cria
     $vARQUIVOCSV = fopen($vDIR . '/' . $VMNome . '.criar', 'wa+');
     if (false == $vARQUIVOCSV) {
        echo "ERRO: Falha ao criar o arquivo para a VM " . $VMNome;
        exit;
     }
     fwrite($vARQUIVOCSV, $vTEXTO); // Grava os dados no arquivo
     fclose($vARQUIVOCSV); // Fecha o arquivo que foi aberto
     echo "VM " . $VMNome . " esta na fila para ser criada.";
?>
