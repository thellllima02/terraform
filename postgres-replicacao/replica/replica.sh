#!/bin/bash

cd /home/ubuntu/postgres/replicacao/replica
echo
echo "Entrei na Pasta Replica"

mkdir -p pgdata

echo
echo "Pasta pgdata criada com sucesso"

echo
echo "Ip da maquina Master $MASTER_IP"
sleep 360

until sudo docker run --rm postgres:17 pg_isready -h "$MASTER_IP"; do
    echo "Aguardando Master..."
    sleep 5
done

until sudo docker run --rm \
    -e PGPASSWORD=123456 \
    -v $(pwd)/pgdata:/backup \
    postgres:17 \
    pg_basebackup \
    -h "$MASTER_IP" \
    -U replicador \
    -D /backup \
    -P \
    -R \
    -X stream
do
    echo "Falha no backup. Tentando novamente..."
    rm -rf pgdata/*
    sleep 5
done

sudo docker compose up -d

echo
echo "Criando os conteineres replica"

echo
echo "REPLICA CONFIGURADA!"