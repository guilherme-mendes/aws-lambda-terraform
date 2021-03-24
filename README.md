# Desafio Tecnologia TON

* Aplicação de gestão de funcionários.

## Descrição

* Módulo [Terraform](https://www.terraform.io/) para criação das funções Lambdas na linguagem Python ([AWS Lambda](https://aws.amazon.com/pt/lambda/)). 
* API REST com os métodos HTTP (POST, GET, DELETE) ([Amazon API Gateway](https://aws.amazon.com/pt/api-gateway/)).
* Banco de dados não relacional ([DynamoDB](https://aws.amazon.com/pt/dynamodb/)).

## Diagrama de Fluxo

![diagram](diagram.png)

## Requisitos

* [Terraform v0.14.8](https://www.terraform.io/downloads.html)

## Utilização do projeto

* Registro do funcionário

```sh
$ curl -X POST "https://x0l626xc2l.execute-api.us-east-1.amazonaws.com/prod/employee" -H 'Content-Type: application/json' -d'
{
  "id": "1", 
  "name": "Joao", 
  "role": "Gerente", 
  "age": 30
}'
```
* Busca dos funcionários

```sh
$ curl -X GET "https://x0l626xc2l.execute-api.us-east-1.amazonaws.com/prod/employee"
```

## Execução do projeto localmente

* Clone o repositório
```sh
$ git clone https://github.com/guilherme-mendes/tech-ton-challenge.git
$ cd tech-ton-challenge/terraform  
```
* Execute o terraform
```sh
$ terraform init
$ terraform plan
$ terraform apply
```