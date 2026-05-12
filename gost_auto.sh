#!/bin/bash

# 1. Install screen and necessary tools
apt update && apt install -y screen wget

# 2. Download and unzip GOST
if [ ! -f "gost" ]; then
    echo "Downloading GOST..."
    wget https://github.com/ginuerzh/gost/releases/download/v2.11.5/gost-linux-amd64-2.11.5.gz
    gzip gost-linux-amd64-2.11.5.gz -d
    mv gost-linux-amd64-2.11.5 gost
    chmod +x gost
fi

# 3. Increase system high concurrency connection limit
ulimit -n 65535

# 4. Start gost
screen -dmS gost bash -c '
# Monitor (8443)
nohup ./gost -L=relay+mwss://:8443 >> /var/log/gost_server.log 2>&1 &

# Wait for 2 seconds
sleep 2

# 1
nohup ./gost -L=tcp://:1314/156.245.239.142:1314 -F=relay+mwss://127.0.0.1:8443 >> /var/log/gost_client.log 2>&1 &

# 2
nohup ./gost -L=tcp://:8888/156.245.239.142:8888 -F=relay+mwss://127.0.0.1:8443 >> /var/log/gost_client.log 2>&1 &

# Keep the window running for easy viewing
exec bash
'

echo "==============================================="
echo "Deployment completed! All tunnels have been started in the gost window。"
echo "- Listening port: 8443 (MWSS)"
echo "- Forwarding port: btc.f2pool.com:1314 and ltc.f2pool.com:8888"
echo "==============================================="
