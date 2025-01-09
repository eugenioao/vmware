<?php
$vHTML = <<<TEXTOHTML
<!DOCTYPE>
<html>
<head>
<head>
  <title>PORTAL - Ferramentas Gerencias</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="css/global.css">

  <script type="text/javascript" src="js/jquery.min.js"></script>
  <script type="text/javascript">
   var auto_refresh = setInterval(
      function ()
      {

TEXTOHTML;
$TEXTOHTMLEXECUCAO="";
$TEXTOHTMLJAVASCRIPT="";

    $vCONT=1;
    foreach (glob("/var/www/html/vmware/config/*") as $vARQUIVO) {
      if($vARQUIVO == '.' || $vARQUIVO == '..') continue;
        $vLINHA = file($vARQUIVO);
        $aLINHA = explode(';', $vLINHA[0]);

        $vSTATUS = ucfirst( substr($vARQUIVO, strpos($vARQUIVO, ".") + 1) );

        $TEXTOHTMLEXECUCAO=$TEXTOHTMLEXECUCAO . "<tr id='favItem_0" . $vCONT . "' class='dragit'>";
        $TEXTOHTMLEXECUCAO=$TEXTOHTMLEXECUCAO . "<td style='border-bottom:1px double #CCC;'>0" . $vCONT . "</td>";
        $TEXTOHTMLEXECUCAO=$TEXTOHTMLEXECUCAO . "<td style='border-bottom:1px double #CCC;'>" . strtoupper($aLINHA[0]) . "</td>";
        $TEXTOHTMLEXECUCAO=$TEXTOHTMLEXECUCAO . "<td style='border-bottom:1px double #CCC;'><div id='ordem_0" . $vCONT . "'></div></td>";
        $TEXTOHTMLEXECUCAO=$TEXTOHTMLEXECUCAO . "</tr>";

	$TEXTOHTMLJAVASCRIPT=$TEXTOHTMLJAVASCRIPT . "\$('#ordem_0" . $vCONT . "').load('php/vm-status.php?nome=" . $aLINHA[0] . "').fadeIn(\"slow\");\n";

      $vCONT++;
   }

echo $vHTML;
echo $TEXTOHTMLJAVASCRIPT;

$vHTML = <<<TEXTOHTML
      }, 3000); // atualiza a cada 3segundos
  </script>
  <script type="text/javascript">
  jQuery(document).ready(function(){
    jQuery('#ajax_form').submit(function(){
      var dados = jQuery( this ).serialize();

      jQuery.ajax({
        type: "POST",
        url: "php/vm-registrar.php",
        data: dados,
        success: function( data )
        {
          alert( data );
          location.reload(true);
        }
      });

      return false;
    });
  });
  </script>
</head>
<body>
<div id="paginainicial"></div>
<form method="post" action="" id="ajax_form">
  <label><input type="hidden" name="id" value="" /></label>
  <p><h1 align="center"><font face="Verdana, Arial, Helvetica, sans-serif">Solicita&ccedil;&atilde;o para Criar VM</font></h1></p>
  <table width="588" border="0" align="center" >
    <tr>
      <td><font size="1" face="Verdana, Arial, Helvetica, sans-serif">Nome:</font></td>
      <td><font size="2">
        <input name="VMNome" type="text" id="VMNome" size="16" maxlength="30" placeholder="Digite nome da vm" required="required" class="formbutton"></font>
    </td>
    </tr>
    <tr>
      <td><font size="1" face="Verdana, Arial, Helvetica, sans-serif">IP:</font></td>
      <td><font size="2">
        <input name="VMIP" type="text" id="VMIP" size="20" maxlength="30" placeholder="Digite o IP da vm" required="required" class="formbutton"></font>
    </td>
    </tr>
    <tr>
      <td><font size="1" face="Verdana, Arial, Helvetica, sans-serif">vCPU:</font></td>
      <td><font size="2">
        <select name="VMVCPU" id="VMVCPU">
          <option selected="selected" value="1">1</option>
          <option value="2">2</option>
          <option value="3">3</option>
          <option value="4">4</option>
          <option value="8">8</option>
        </select></font>
    </td>
    </tr>
    <tr>
      <td><font size="1" face="Verdana, Arial, Helvetica, sans-serif">Memoria:</font></td>
      <td><font size="2">
        <select name="VMRAM" id="VMRAM">
          <option selected="selected" value="4">4G</option>
          <option value="6">6G</option>
          <option value="8">8G</option>
          <option value="10">10G</option>
          <option value="12">12G</option>
          <option value="16">16G</option>
        </select></font>
    </td>
    </tr>
    <tr>
      <td><font size="1" face="Verdana, Arial, Helvetica, sans-serif">Descri&ccedil;&atilde;o:</font></td>
      <td><font size="2">
        <input name="VMNOTA" type="text" id="VMNOTA" size="30" maxlength="60" placeholder="Digite uma descri&ccedil;&atilde;o para a vm" required="required" class="formbutton"></font>
    </td>
    </tr>
    <tr>
      <td><font size="1" face="Verdana, Arial, Helvetica, sans-serif">Template:</font></td>
      <td><font size="2">
        <select name="VMTMPL" id="VMTMPL">
          <option selected="selected">template-01</option>
          <option>template-01</option>
        </select></font>
    </td>
    </tr>
    <tr>
      <td height="45"><p><strong><font face="Verdana, Arial, Helvetica, sans-serif"><font size="1"></font></font></strong></p></td>
    </tr>
    <tr>
      <td height="22"></td>
      <td>
        <input name="Submit" type="submit" class="formobjects" value="Enviar dados">
        <input name="Reset" type="reset" value="Redefinir">
      </td>
    </tr>
  </table>
</form>
<p>&nbsp;</p>
<p><h2 align="center"><font face="Verdana, Arial, Helvetica, sans-serif">Em execu&ccedil;&atilde;o/Executado</font></h2></p>
<table align="center" class="table table-bordered" id="SongList" style="width:420px; font-size:10pt; color:#CCC;">
    <tr>
        <th style="width:10%;">#</th>
        <th style="width:50%;">Nome</th>
        <th style="width:100%;">Status</th>
    </tr>
    <tbody class="posicao_linha" id="posicao">
TEXTOHTML;

echo $vHTML;
echo $TEXTOHTMLEXECUCAO;

$vHTML = <<<TEXTOHTML
    </tbody>
    </tr>
</table>

</body>
</html>
TEXTOHTML;
echo $vHTML;
?>
