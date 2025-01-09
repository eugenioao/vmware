#!/usr/bin/pwsh -Command
<#
    .NOTA
    ===========================================================================
     Autor: Eugenio Oliveira
     Data : 17/04/2023
    ===========================================================================
    .DESCRIÇÃO
        Este script cria os servidores no vCenter usando os dados de um CSV e o

    .ARQUIVO CSV
        Todos os parametros devem estar dentro do arquivo CSV no formato abaixo
        sem o cabeçalho:

        NAME;IP;CPU;MEMORIA;DESCRICAO;TEMPLATE
        rancherhmg-01;192.168.200.1;4;16;Rancher 2.7;templaterancher-01

#>

Param 
( 
    [Parameter(Mandatory=$true)] [string] $vARQUIVO  
) 

function Falhou
{
    Move-Item -Path $vDIR/$vARQUIVO.* -Destination $vDIR/$vARQUIVO.falhou | Out-Null
}

Write-Host "`n"
Write-Host "[+] Iniciando Criação da VM"
Write-Host "------------------------------------------------"

Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -Confirm:$false | Out-Null
Set-PowerCLIConfiguration -DefaultVIServerMode single -InvalidCertificateAction ignore -DisplayDeprecationWarnings 0 -Confirm:$false | Out-Null
Set-StrictMode -Version Latest | Out-Null

Write-Host "    [-] Verificando os arquivos necessários"
$vARQs = @(".config/credencial-tpl.clixml", "tmp/saida-dns.txt", "subredes.cfg") 
$vContinuar = $true

foreach ($vARQ in $vARQs) { 
   if (!(Test-Path $vARQ)) 
   { 
       Write-Host "ERRO: Não foi possivel encontrar o arquivo $vARQ"; $vContinuar = $false ; break 
   } 
} 
if (-not $vContinuar) { break }

$vARQSAIDA="tmp/saida-dns.txt"
$vDATA=(Get-Date -UFormat "%d/%m/%Y")
$vDIR="/var/www/html/vmware/config"
$vIMPARQUIVO="$vDIR/$vARQUIVO.criando"
if (!(Test-Path $vIMPARQUIVO))
{
   Write-Host "    [-] O $vIMPARQUIVO não existe."
   break
}

# Endereco do vCenter
$vCenter="ENDERECO_DO_VCENTER"

$vFolder = "NOME_DO_FOLDER_VCENTER"

Write-Host "    [-] Conectando ao vCenter: $vCenter"
Connect-VIServer $vCenter -Credential (Import-clixml "/opt/scripts/.config/credencial-tpl.clixml") | Out-null
if (!$?) { Write-Host "ERRO: Não foi possivel se conectar ao vCenter"; break }

$vLINHA=(Import-CSV $vIMPARQUIVO -Header VMNAME,IP,CPU,MEMORIA,DESCRICAO,TEMPLATE -Delimiter ";") 
$vNome=$vLINHA.VMNAME
$vIP=$vLINHA.IP
$vCPU=$vLINHA.CPU
$vMemoria=$vLINHA.MEMORIA
$vDescricao=$vLINHA.DESCRICAO
$vNota="Nome da Maquina: $vNome`n"
$vNota+="IP: $vIP`n"
$vNota+="Unidade Solicitante: SESAP`n"
$vNota+="Servico contido no servidor: $vDescricao`n"
$vNota+="Data de criacao do servidor: $vDATA`n"
$vNomeTemplate=$vLINHA.TEMPLATE

if (!$vIP) { Write-Host "ERRO: O arquivo $vIMPARQUIVO não esta no formato correto."; Falhou ; break }

$vNomeExiste=Get-Template $vNomeTemplate -ErrorAction SilentlyContinue
if (!$vNomeExiste) 
{
   Write-Host "    [-] O template $vNomeTemplate não existe"
   break 
}

Write-Host "    [-] Criando a VM do arquivo $vARQUIVO"
Write-Host "        [-] $vNome - $vDescricao" 

# Seleciona um dos servidores fisicos
$vCluster = (Get-Cluster | Get-Random -Count 1)
$vVMHost = (Get-Cluster $vCluster | Get-VMHost | Get-Random)
if (!$?) { Write-Host "ERRO: Não foi possivel definir o host ESXi"; Falhou ; break }

$vNomeDS = (Get-Datastore -VMHost $vVMHost | Get-Random)
if (!$?) { Write-Host "ERRO: Não foi possivel definir o datastore"; Falhou ; break }

# Cria a VM com base no template
New-VM -Template $vNomeTemplate -Name $vNome -VMHost (Get-View (Get-Template -Name $vNomeTemplate | Get-View).Summary.Runtime.Host).Name -Location $vFolder | Out-Null
if (!$?) { Write-Host "ERRO: Não foi possivel criar a VM $vNome [$vCluster - $vVMHost - $vNomeDS - $vNomeTemplate - $vFolder]" ; Falhou ; break }
Start-Sleep -Seconds 5

Write-Host "            [-] Atualizando propriedades na VM"

# Verifica se a VM foi criada e pega as informacoes
$VM=(Get-VM $vNome | Out-Null)
if (!$?) { Write-Host "ERRO: Não foi possivel obter informações da VM $vNome"; Falhou ; break }

# Informa que a vm foi criada (interface web)
Move-Item -Path $vDIR/$vARQUIVO.criando -Destination $vDIR/$vARQUIVO.criada | Out-Null

Write-Host "                CPU, Memoria e Nota"
Set-VM -VM $vNome -MemoryGB $vMemoria -NumCpu $vCPU -Description $vNota -Confirm:$False | Out-Null

#Write-Host "                Reserva de Memoria"
#Get-VM $vNome | Get-VMResourceConfiguration | Set-VMResourceConfiguration -MemReservationGB $vMemoria -Confirm:$False | Out-Null

Write-Host "            [-] Pegando o MacAddress da VM"
$vMAC=(Get-VM $vNome | Get-NetworkAdapter | select -ExpandProperty MacAddress).Replace(':','')

#Write-Host "            [-] Movendo o $vNome para $vFolder"
#Move-VM -VM $vNome -InventoryLocation $vFolder | Out-Null

# Verificando a subrede da VM
$vIPptr+=$vIP.Split(".")[1]
$vIPptr+="."
$vIPptr+=$vIP.Split(".")[0]
$vIPF=$vIP.Split(".")[3]
$vIPF+="."
$vIPF+=$vIP.Split(".")[2]

Write-Host "            [-] Gerando entradas para o DNS SERVER"
Add-Content $vARQSAIDA "`ndnscmd . /RecordAdd SEU_DOMINIO $vNome A $vIP"
Add-Content $vARQSAIDA "`dnscmd . /recordadd $vIPptr.in-addr.arpa. $vIPF PTR $vNome.SEU_DOMINIO"

$vIPblc=$vIP.Split(".")[0]
$vIPblc+="."
$vIPblc+=$vIP.Split(".")[1]
$vIPblc+="."
$vIPblc+=$vIP.Split(".")[2]

$vIPF=[int]$vIP.Split(".")[3]

$vREDE=(Select-String -Path /opt/scripts/subredes.cfg -Pattern $vIPblc)
if (!$vREDE) { Write-Host "ERRO: Não foi possivel definir a subrede."; break }

foreach ($vBLOCO in $vREDE) {

   $vBL=$vBLOCO.Line.Split(";")[0]
   if (! $vBLF) {
      $vBLF=[String[]]$vBL.Split(".")[3]
   } else {
      $vBLF += [int]$vBL.Split(".")[3]
   }

}
$vBLF=($vBLF|sort -r)
$vBLS=""
$vBL=""
$vBLA=254
foreach ($vBL in $vBLF) {

   if (( $vIPF -gt $vBL ) -And ( $vIPF -lt $vBLA )) {
      $vBLS=$vBL
   }
   $vBLA=$vBL

}
$vIPblc+="."
$vIPblc+=$vBLA
$vREDE=(Select-String -Path /opt/scripts/subredes.cfg -Pattern $vIPblc)
if (!$vREDE) { Write-Host "ERRO: Não foi possivel definir a subrede."; break }

$vMK=$vREDE.Line.Split(";")[1]
$vGW=$vREDE.Line.Split(";")[2]
$vPG=$vREDE.Line.Split(";")[3]

New-Item -Path $vDIR/$vARQUIVO.criada -Value "$vNome;$vIP;$vCPU;$vMemoria;$vDescricao;$vMK;$vGW" -force | Out-Null
if (!$?) { Write-Host "ERRO: Não foi possivel atualizar o $vDIR/$vARQUIVO.criada para a VM..."; break }

# Altera o arquivo para o download na VM (e mostra na interface web)
New-Item -Path /var/www/html/config/$vMAC.config -ItemType SymbolicLink -Value $vDIR/$vARQUIVO.criada | Out-Null

Write-Host "            [-] Iniciando VM"
Get-VM $vNome | Start-VM | Out-Null
Start-Sleep -Seconds 5

Write-Host "                [-] Confirma qualquer questionamento do vCenter para a VM"
Get-VM $vNome | Get-VMQuestion | Set-VMQuestion -Option "button.uuid.movedTheVM" -Confirm:$false | Out-Null
if (!$?) { Write-Host "ERRO: Não foi possivel confirmar o questionamento para a VM..."; break }
Start-Sleep -Seconds 5

Write-Host "            [-] Aguardando reconfiguração da VM " -NoNewline
$vQTD = 0
$vContinuar = $true
$vMAC="$vMAC.config"

while ($true)
{
  Write-Host "." -NoNewline
  if (Select-String -Path /var/log/httpd/access_log -Pattern $vMAC | Select-String -Pattern ' 200 ') {
     Write-Host "" 
     Write-Host "                [-] Alterando PortGroup para $vPG" 
     Get-VM $vNome | Get-NetworkAdapter | Where {$_.Name -eq 'Network adapter 1'} | Set-NetworkAdapter -Portgroup $vPG -Confirm:$false | Out-Null
     break
  }
  if ($vQTD -eq 120) { Write-Host "" ; Write-Host "ERRO: Não foi possivel confirmar que a VM ficou pronta."; $vContinuar = $false ; break }
  $vQTD++
  Start-Sleep -Seconds 5
}
if (-not $vContinuar) { break }
$vQTD=0

Write-Host "                [-] Aguardando VM reiniciar na nova subrede" -NoNewline
while ($true)
{
  Write-Host "." -NoNewline
  if ( (New-Object System.Net.Sockets.TcpClient).ConnectAsync("$vIP", "22").Wait(1000) ) {
     Write-Host ""
     Write-Host "                [-] VM reiniciada com sucesso"
     Remove-Item -Path /var/www/html/config/$vMAC | Out-Null
     Move-Item -Path $vDIR/$vARQUIVO.criada -Destination $vDIR/$vARQUIVO.pronto | Out-Null
     break
  }
  if ($vQTD -eq 120) { Write-Host "" ; Write-Host "ERRO: Não foi possivel confirmar que a VM ficou pronta."; $vContinuar = $false ; break }
  $vQTD++
  Start-Sleep -Seconds 5
}
if (-not $vContinuar) { break }

#Write-Host "            [-] Movendo VM para outro ESXi/Datastore"
#Move-VM $vNome -RunAsync -Destination $vVMHost -Datastore $vNomeDS | Out-Null

Write-Host "    [-] Fim da criação dos servidores"
Write-Host "------------------------------------------------"

Write-Host "    [-] Desconectando do vCenter."
Disconnect-VIServer $vCenter -Confirm:$false | Out-Null
Write-Host "[-] Fim"

