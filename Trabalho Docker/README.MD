# Atividade AWS - Docker

## Descrição do projeto
O objetivo desse projeto é rodar uma aplicação Wordpress em uma instância da EC2-AWS. Usaremos o sistema de arquivos EFS, um banco de dados MYSQL criado pelo RDS, um Load Balancer (Balanceador de cargas) e 

## Sumário

## Arquitetura

<div align="center">
<img src="img/arquitetura-projeto.png" width="300">
</div>

## Requisitos
Ter uma conta AWS;
Ambiente Linux acessível para a conexão via ssh (nesse trabalho utilizei o WSL com Ubuntu);

## Check-list de tarefas
- VPC
- Grupo de Segurança
- EFS
- RDS
- EC2 (utilização de Bastion Host)
- Load Balancer

## Etapas
1. VPC
Dentro do site da AWS, siga o caminho: VPC > Suas VPC's > Criar VPC;
Selecione VPC e muito mais;
Coloque o nome de suas VPC (no exemplo usarei: PROJETO);
Por padrão, será criado uma VPC com 4 sub-redes, 2 públicas e 2 privadas;

<div align="center">
<img src="img/vpc.png" width="300">
</div>

2. Grupo de Segurança
Aqui iremos criar e configurar 2 grupos de segurança, que serão utilizados durante o projeto;
Siga o caminho: EC2 > Grupos de segurança > Criar grupo de segurança;

### Grupo de segurança público

<div align="center">
<img src="img/detalhes-grupo-publico.png" width="300">
</div>

Adicione regra de entrada (NFS, TCP, 2049, Qualquer local-IPv4);
Adicione regra de entrada (SSG, TCP, 22, Qualquer local-IPv4);
Adicione regra de entrada (HTTP, TCP, 80, Qualquer local-IPv4);
Adicione regra de entrada (MYSQL/Aurora, TCP, 3306, Qualquer local-IPv4);

<div align="center">
<img src="img/sg-publico-entrada.png" width="300">
</div>

Adicione regra de saída (Todo o tráfego, Tudo, Tudo, Qualquer local-IPv4);

<div align="center">
<img src="/img/sg-publico-saida.png" width="350">
</div>

### Grupo de segurança privado

<div align="center">
<img src="img/detalhes-grupo-privado.png" width="350">
</div>

Adicione regra de entrada (SSG, TCP, 22, Qualquer local-IPv4);
Adicione regra de entrada (HTTP, TCP, 80, Personalizado, projeto-publico-sg);

<div align="center">
<img src="img/sg-privado-entrada.png" width="350">
</div>

Adicione regra de saída (Todo o tráfego, Tudo, Tudo, Qualquer local-IPv4);

<div align="center">
<img src="img/sg-privado-saida.png" width="350">
</div>

3. EFS
Siga o caminho, Amazon EFS > Sistemas de arquivos > Criar sistema de arquivos, Personalizar;
Crie um nome;
Selecione sua VPC;
Em Destinos de montagem, crie dois dentinos, com as duas sub-redes e seus grupos de segurança público;

<div align="center">
<img src="img/rede-efs.png" width="350">
</div>

4. RDS
Siga o caminho: RDS > Criar bando de dados;
Criação Padrão;
MySQL;
Nível gratuito;
Nome: db-projeto;
Nome de usuário principal: admin;
Crie uma senha;
db.t3.micro;
Selecione sua VPC;
Configuralçao adicional, crie um banco de dados, só colocar o um nome para o banco e deixa o resto padrão;

<div align="center">
<img src="img/config-adicional-rds.png" width="350">
</div>

5. Nat Gateway
Esse serviço será utilizado para que possa passar internet para a instância privada. Para isso, criaremos um gat em uma sub rede pública e com conexão pública, apóis isso vinculamos com as sub rede's privada utilizando a tabela de rotas;

<div align="center">
<img src="img/nat-gateway-padrao.png" width="350">
</div>

6. EC2

### Bastion Host
Siga o caminho: EC2 > Instâncias > Launch an instance;
Adicione uma tag, Chave: Name; Valor: Bastion Host;
Em "Tipos de recurso", selecione: Instâncias e Volumes;

<div align="center">
<img src="img/nomes-tags-bastion.png" width="350">
</div>

Selecione Ubuntu;
Tipos de instância: t2.micro;
Selecione criar novo par de chaves (do tipo .pem), adicione um nome e faça o download da chave (será utilizado para acesso ssh.);
Em "Configurações de rede": 
    selecione sua VPC;
    selecione uma subnet pública;
    Habilite um IP público;
    Selecione o grupo de segurança público criado anteriomente;

<div align="center">
<img src="img/config-rede-bastion.png" width="350">
</div>

Ap

### EC2 privada
Siga o caminho: EC2 > Instâncias > Launch an instance;
Adicione uma tag, Chave: Name; Valor: m-privado;
Em "Tipos de recurso" selecione: Instâncias e Volumes;

<div align="center">
<img src="img/nomes-tags-ec2-privada.png" width="350">
</div>

Selecione Ubuntu;
Tipos de instância: t2.micro;
Selecione o par de chaves utilizado no Bastion Host (Também é possível criar uma nova, mas para facilitar, utilizaremos o mesmo);
Em "Configurações de rede": 
    selecione sua VPC;
    selecione uma subnet privada;
    Desabilite o IP público;
    Selecione o grupo de segurança privado criado anteriomente;

<div align="center">
<img src="img/config-rede-ec2-privada.png" width="350">
</div>

Em "Detalhes avançados";
Vá até "Dados do usuário" e cole o script abaixo, verifique cada comando, pois precisará preencher informações de RDS e EFS criados anteriormente;

Para executar o script de configuração do usuário, utilize o seguinte comando:

```bash
./script/user_data.sh
```
Ao criar a instância privada, irá aparecer essas opções: 

<div align="center">
<img src="img/ec2-privada-conexoes.png" width="350">
</div>

Clique em "Conectar um banco de dados do RDS";
Selecione "Instância";
Selecione a RDS criada anteriormente;

<div align="center">
<img src="img/conexao-rds-ec2.png" width="350">
</div>

### Conexão ssh e comandos
Nessa parte será utilizado o client WSL com Ubuntu instalado, para utilização da Bastion Host e da EC2 privada via ssh (para isso será necessário o par de chaves criado, deixarei um passo a passo logo abaixo para utilização);

Para conectar ao Bastion Host, siga o caminho: EC2 > Instâncias > (Nome da instância) > Conectar;
Selecione "Cliente SSH" e copie o código que aparece abaixo de "Exemplo:";

<div align="center">
<img src="img/conectar-bastion.png" width="350">
</div>

Dentro do WSL, vá até ao diretório onde criou sua chave, ou crie caso ainda não tenho criado, depois disso;
Dentro da pasta onde o par de chaves está localizado, utilize os comandos: 

```bash
chmod 400 "nome-da-chave.pem"
```

```bash
ssh -i "nome-da-chave.pem" usuario@hostname-ou-ip-publico
```

Responda "yes" caso necessário;
Após conectado ao Bastion Host, vá até ao diretório onde criou sua chave ou crie caso ainda não tenha;
Dentro da pasta onde o par de chaves está localizado, utilize os comandos:

```bash
chmod 400 "nome-da-chave.pem"
```

```bash
ssh -i "nome-da-chave.pem" usuario@endereco-ip-privado
```

Responda "yes" caso necessário;
Agora conectado em sua EC2 privada;

Permite que o usuário atual execute um comando com privilégios administrativos (root)
```bash
sudo su
```

Teste se o script funcionou e instalou corretamente. Você pode utlizar comandos como:

Verifica se o docker está instalado e mostra sua versao
```bash
sudo docker --version
```

Verifica se o docker-compose está instalado e mostra sua versão
```bash
docker compose version
```

Verifica todos os containers existentes
```bash
sudo docker ps -a
```

7. Load Balancer
Para criar, siga o caminho: EC2 > Load balancers > Comparar e selecionar o tipo de balanceador de cagar;
Após isso, clique em "Classic Load Balancer - geração anterior" > Criar;
Coloque um nome;
Selecione sua VPC;
Em "Zonas de disponibilidade", verifique se ambas estão em subnet's públicas;

<div align="center">
<img src="img/zonas-lb-publica.png" width="350">
</div>

Coloque o grupo de segurança público;

<div align="center">
<img src="img/grupo-seg-lb.png" width="350">
</div>

Em "Verificação de integridade", altere o valor do "Caminho de ping" para:
```cpp
/wp-admin/install.php
```

Após criar o Load balancer, adicione o EC2 privada para que possa ser utilizado o DNS do Load balancer como rota de acesso à aplicação wordpress que está rodando na EC2.
Para isso, siga o caminho: EC2 > Load balancers > Nome-do-lb;
Clique em "Instâncias de destino" e depois em "Gerenciar instâncias";
Selecione duas vezes a instância privada (onde está rodando o wordpress);
Após isso, já é possível abrir o wordpress, utilizando o DNS do Load balancer;

A tela desejada é essa:

<div align="center">
<img src="img/wordpress-login.png" width="350">
</div>

## Instruções