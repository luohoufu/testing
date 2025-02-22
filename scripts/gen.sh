#!/bin/bash

# for proxy
cat <<EOF > "$GITHUB_WORKSPACE/.oss.json"
{
    "local_port": $LOCAL_PORT,
    "local_address": "127.0.0.1",
    "servers": [
        {
            "server": "$CONNECT_SERVER",
            "server_port": $CONNECT_PORT,
            "password": "$CONNECT_KEY",
            "timeout": $CONNECT_TIMEOUT,
            "mode": "$CONNECT_MODE",
            "method": "$CONNECT_METHOD"
        }
    ]
}
EOF

# for oss
cat <<EOF > "$GITHUB_WORKSPACE/.oss.yml"
endpoint: $OSS_EP
accesskeyid: $OSS_AK
accesskeysecret: $OSS_SK
bucket: $OSS_BK
proxy: http://127.0.0.1:$LOCAL_PORT
EOF