# Criar VM com base no template do Jboss

- Servidor dos scripts
```
tools-01
```

- URL de acesso (autenticação via AD)
```
https://tools-01/vmware/criar/index.php
```

- Diretorio dos scripts e logs
```
/opt/scripts
```

- Diretorio da "aplicação" web (php)
```
/var/www/html/vmware/criar
```

- Diretorio dos arquivos com os dados da VM que será criada
```
/var/www/html/vmware/config
/var/www/html/config
```
<div id="obs" style="background-color:powderblue;">
<p style="color: black;
  text-indent: 30px;
  display: block;
  margin-top: 1em;
  margin-bottom: 1em;
  margin-left: 2;
  margin-right: 5;
  background-color:powderblue;
  ">OBS: Para criar via shell, crie um arquivo no /var/www/html/vmware/config com o nome da VM e com a extensão ".criar"
</p>
</div>

Exemplo:
  arquivo: /var/www/html/vmware/config/jbosshmg-01.criar
  conteudo: jboss-01;192.168.195.196.200;2;4

  Final da linha (coluna 3 e 4): 2 => é vCPU e 4 é memória

  OBS: O arquivo precisa de permissão 644.

