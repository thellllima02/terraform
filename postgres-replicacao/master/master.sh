#!/bin/bash

cd /home/ubuntu/postgres/replicacao/master
echo
echo "Entrei na Pasta Master"


sudo docker compose up -d
echo
echo "ESPERADNO CRIAR os conteineres master"
sleep 20

echo "Aguardando PostgreSQL iniciar..."

until sudo docker exec postgres-master pg_isready -U postgres > /dev/null 2>&1
do
    sleep 2
done

echo "PostgreSQL iniciado."

sudo docker exec postgres-master psql -U postgres -c \
"CREATE ROLE replicador WITH REPLICATION LOGIN PASSWORD '123456';"

echo
echo "Usuario criado no postgres"

sudo docker exec postgres-master bash -c "echo 'host replication replicador $REPLICA_IP/32 md5' >> \$PGDATA/pg_hba.conf"

echo
echo "PGDATA configurado"

sudo docker exec postgres-master bash -c "echo 'host all all $REPLICA_IP/32 md5' >> \$PGDATA/pg_hba.conf"

echo
echo "IP da rede Replica $REPLICA_IP"
echo
echo "Pg_hba configurado"

sudo docker restart postgres-master

echo
echo "Restart do postgres-master"

echo
echo "MASTER CONFIGURADO!"