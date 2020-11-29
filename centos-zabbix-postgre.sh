
yum install docker -y
service docker start
systemctl enable docker
 docker network create --subnet 172.20.0.0/16 --ip-range 172.20.240.0/20 zabbix-net
 docker run --name postgres-server -t \
      -e POSTGRES_USER="zabbix" \
      -e POSTGRES_PASSWORD="zabbix_pwd" \
      -e POSTGRES_DB="zabbix" \
      --network=zabbix-net \
      --restart unless-stopped \
      -d postgres:latest
docker run --name zabbix-snmptraps -t \
      -v /zbx_instance/snmptraps:/var/lib/zabbix/snmptraps:rw \
      -v /var/lib/zabbix/mibs:/usr/share/snmp/mibs:ro \
      --network=zabbix-net \
      -p 162:1162/udp \
      --restart unless-stopped \
      -d zabbix/zabbix-snmptraps:alpine-5.2-latest
docker run --name zabbix-server-pgsql -t \
      -e DB_SERVER_HOST="postgres-server" \
      -e POSTGRES_USER="zabbix" \
      -e POSTGRES_PASSWORD="zabbix_pwd" \
      -e POSTGRES_DB="zabbix" \
      -e ZBX_ENABLE_SNMP_TRAPS="true" \
      -e ZBX_CACHESIZE=2048M \
          -e ZBX_TRENDCACHESIZE=256M \
          -e ZBX_HISTORYCACHESIZE=1024M \
          -e ZBX_VALUECACHESIZE=512M \
          -e ZBX_HISTORYINDEXCACHESIZE=1024M \
      --network=zabbix-net \
      -p 10051:10051 \
      --volumes-from zabbix-snmptraps \
      --restart unless-stopped \
      -d zabbix/zabbix-server-pgsql:alpine-5.2-latest

docker run --name zabbix-web-nginx-pgsql -t \
      -e ZBX_SERVER_HOST="zabbix-server-pgsql" \
      -e DB_SERVER_HOST="postgres-server" \
      -e POSTGRES_USER="zabbix" \
      -e POSTGRES_PASSWORD="zabbix_pwd" \
      -e POSTGRES_DB="zabbix" \
      -e ZBX_CACHESIZE=2048M \
          -e ZBX_TRENDCACHESIZE=256M \
          -e ZBX_HISTORYCACHESIZE=1024M \
          -e ZBX_VALUECACHESIZE=512M \
          -e ZBX_HISTORYINDEXCACHESIZE=1024M \
      --network=zabbix-net \
      -p 80:8080 \
      --restart unless-stopped \
      -d zabbix/zabbix-web-nginx-pgsql:alpine-5.2-latest
