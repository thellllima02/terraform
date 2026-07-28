# terraform
Inicio do aprendizado com o terraform

# Terraform - Guia de Instalação e Utilização

## 📖 Sobre

Este documento descreve todos os pré-requisitos necessários para utilizar o Terraform na criação e gerenciamento de infraestrutura como código (Infrastructure as Code - IaC), utilizando a AWS como provedor de nuvem.

---

# Pré-requisitos

Antes de utilizar o Terraform, é necessário possuir:

- Conta na AWS;
- Uma EC2 com o Sistema operacional Linux (Ubuntu 22.04 ou superior recomendado);
- Permissões para criação de recursos na AWS;


A EC2 vai precisar de:
- Git instalado;
- AWS CLI instalada;
- Terraform instalado.

---

# Atualizando o sistema

Antes de instalar qualquer ferramenta, atualize o sistema operacional.

```bash
sudo apt update
sudo apt upgrade -y
```

---

# Instalando utilitários

Algumas ferramentas são utilizadas durante a configuração da infraestrutura.

```bash
sudo apt install -y \
curl \
wget \
unzip \
git \
vim
```

---

# Instalando o AWS CLI

O Terraform utiliza as credenciais da AWS para criar recursos.

Baixe o instalador:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```

Extraia os arquivos:

```bash
unzip awscliv2.zip
```

Instale:

```bash
sudo ./aws/install
```

Verifique a instalação:

```bash
aws --version
```

---


# Instalando o Terraform

Atualize os repositórios:

```bash
sudo apt-get update
sudo apt-get install -y gnupg software-properties-common
```

Adicione a chave GPG da HashiCorp:

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```

Verifique a chave:

```bash
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
```

Adicione o repositório:

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com \
$(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
```

Atualize novamente:

```bash
sudo apt update
```

Instale o Terraform:

```bash
sudo apt-get install terraform
```

Verifique se a instalação foi concluída:

```bash
terraform -version
```

---

# Configurando permissões na AWS

Para que o Terraform possa criar recursos na AWS, é necessário conceder permissões.

## Criando uma IAM Role

No Console da AWS:

1. Abra o serviço **IAM**.
2. Acesse **Roles**.
3. Clique em **Create Role**.
4. Escolha:

- Trusted Entity Type:
  - AWS Service

- Use Case:
  - EC2

Clique em **Next**.

---

## Adicionando permissões

Para um ambiente de estudos, utilize:

- AmazonEC2FullAccess
- AmazonS3FullAccess (opcional, caso utilize backend remoto)
- AmazonSSMManagedInstanceCore (opcional)

> Em ambientes de produção, recomenda-se seguir o princípio do menor privilégio, criando políticas personalizadas.

Clique em **Next**.

---

## Nome da Role

A exemplo, foi utilizado:

```bash
TerraformEC2Role
```

Clique em **Create Role**.

---

## Associando a Role à instância EC2

No serviço EC2:

```
EC2
→ Instances
→ Selecione a instância
→ Actions
→ Security
→ Modify IAM Role
```

Selecione a Role criada e clique em **Update IAM Role**.

---

# Estrutura recomendada do projeto

```text
└── postgres-replicacao
    ├── master
    │   ├── docker-compose.yml
    │   ├── master.sh
    │   └── postgresql.conf
    ├── replica
    │   ├── docker-compose.yml
    │   └── replica.sh
    └── terraform
        ├── main.tf
        ├── outputs.tf
        ├── provider.tf
        ├── terraform.tfstate
        ├── terraform.tfstate.backup
        ├── terraform.tfvars
        ├── user-data.sh
        ├── variables.tf
        └── versions.tf
```

---

# Inicializando o Terraform

Após criar os arquivos do projeto, execute dentro da pasta terraform:

```bash
terraform init
```

Este comando:

- baixa o provider da AWS;
- cria a pasta `.terraform`;
- prepara o ambiente.

---

# Formatando os arquivos

```bash
terraform fmt
```

Este comando padroniza a formatação dos arquivos `.tf`.

---

# Validando a configuração

```bash
terraform validate
```

Verifica erros de sintaxe antes da execução.

---

# Visualizando o plano de execução

```bash
terraform plan
```

Mostra todos os recursos que serão criados, modificados ou removidos.

---

# Aplicando a infraestrutura

```bash
terraform apply
```

Para executar sem solicitar confirmação:

```bash
terraform apply -auto-approve
```

---

# Visualizando os recursos

```bash
terraform show
```

---

# Listando o estado

```bash
terraform state list
```

---

# Destruindo a infraestrutura

Para remover todos os recursos criados:

```bash
terraform destroy
```

Ou:

```bash
terraform destroy -auto-approve
```

---

# Principais arquivos do Terraform

| Arquivo | Função |
|----------|--------|
| `provider.tf` | Configuração do provedor (AWS) |
| `versions.tf` | Define versões do Terraform e Providers |
| `variables.tf` | Declaração das variáveis |
| `terraform.tfvars` | Valores das variáveis |
| `main.tf` | Recursos da infraestrutura |
| `outputs.tf` | Saídas do projeto |
| `user-data.sh` | Script executado durante a criação da EC2 |

---

# Fluxo de utilização

```text
Criar arquivos
        │
        ▼
terraform init
        │
        ▼
terraform fmt
        │
        ▼
terraform validate
        │
        ▼
terraform plan
        │
        ▼
terraform apply
        │
        ▼
Infraestrutura criada
```

---

# Boas práticas

- Nunca armazene credenciais da AWS nos arquivos `.tf`.
- Utilize variáveis para informações sensíveis.
- Versione o projeto utilizando Git.
- Utilize um backend remoto (Amazon S3) para armazenar o arquivo de estado (`terraform.tfstate`) em projetos colaborativos.
- Utilize o comando `terraform validate` antes de aplicar alterações.
- Revise sempre a saída do `terraform plan` antes da execução.

---

# Referências

- HashiCorp. *Terraform Documentation*. Disponível em: <https://developer.hashicorp.com/terraform/docs>.
- Amazon Web Services. *AWS CLI User Guide*. Disponível em: <https://docs.aws.amazon.com/cli/>.
- Amazon Web Services. *IAM User Guide*. Disponível em: <https://docs.aws.amazon.com/IAM/>.

---

## Observação

Este guia foi elaborado com base na instalação e configuração do Terraform em ambiente Ubuntu utilizando a AWS como provedor de infraestrutura, incluindo os passos de instalação, configuração de permissões IAM e fluxo básico de execução do Terraform. :contentReference[oaicite:0]{index=0} :contentReference[oaicite:1]{index=1}
````
