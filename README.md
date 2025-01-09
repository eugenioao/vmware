# Provisionamento de VMs Linux no vCenter

Procedimentos para criação de ambiente de automatização para provisionamento de VMs Linux no vCenter

## 1. Criar usuário no vCenter
O script do powercli precisa de um usuário com acesso ao vCenter e permissões restritas somente para criar VM e alterar as configurações dos recursos (não colocar permissão de exclusão).

## 2. Criar servidor Linux para os scripts/portal web
Crie um servidor com RHEL/CentOS ou Oracle Linux e com instalação mínima. Neste servidor, será instalado o apache com php, o powercli, os scripts, portal web e o DHCP Server para fornecer o IP temporário para cada nova VM.

### 2.1 Instalar o apache com php
O apache e php serão responsáveis pelo portal de solicitação de criação de VM e também fornecer suas configurações da VM que serão usadas no primeiro boot.

### 2.2 Instalar o powercli
O powercli será o responsável por criar e configurar a VM no vCenter de acordo com o informado pelo portal e gravado no arquivo de dados.

### 2.3 Instalar os scripts e o portal web
O pacote com todos os scripts que irão executar os procedimentos estão no GitHub e precisa ser baixado para o servidor.

### 2.4 Instalar o DHCP
Para o DHCP funcionar corretamente, será necessário informar o bloco de IP, mascara, gateway e dns após a instalação.

### 2.5 Iniciar os serviços

### 2.6 Salvar as credenciais do vCenter
Gere o arquivo de credenciais para a autenticação no vCenter via pwercli.

### 2.7 Configurar as subredes
Para atribuir as configurações de rede na VM, é necessário colocar todas as informações no arquivo /opt/scripts/subrede.cfg. Este arquivo contem as informações necessárias para a configuração da VM e seleção do PortGroup no vCenter.

## 3 Criar um servidor Linux que será o template-master
Faça um template Linux com a instalação mínima definindo apenas o padrão de tamanho do disco e as partições.
Dentro deste template, será colocado um script que irá fazer toda a parte de configuração necessária para a VM criada. Neste script, pode ser adicionado todos os procedimentos que devem ser executados nos novos servidores.

### 3.1 Alterar o profile e criar o script de instalação/configuração

## 4 Gerar o template definitivo
Faça o clone do template-master para o nome que desejar, dê o start na VM, altere o hostname para o nome criado, desligue o template criado e faça a conversão para template (Convert to Template).

OBS: O nome do template deve ser inserido no arquivo index.html do portal web para permitir a seleção na criação da VM.

## 5. Testar a criação de uma VM

Acesse o portal web pelo navegador usando a URL abaixo e preencha as informações solicitadas ou execute o script abaixo em algum local.
URL: http://IP_DO_SERVIDOR_GERENCIA/vmware/criar
