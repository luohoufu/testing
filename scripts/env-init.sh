#!/bin/bash

# for ssh
if [[ ! -z "$SSH_PRIVATE_KEY" ]]; then
  mkdir -p ~/.ssh
  cat "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa

  if [[ ! -z "$SSH_CONFIG" ]]; then
    cat "$SSH_CONFIG" >> ~/.ssh/config
  fi
  chmod 600 ~/.ssh/{id_rsa,config}
  ls -lrt ~/.ssh/
  echo "SSH config setting done."
fi

# for proxy
if [[ ! -z "$LOCAL_PORT" ]]; then
  cat <<-EOF > "$GITHUB_WORKSPACE/.oss.json"
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
  echo "Connection config setting done."
fi

# for oss
if [[ ! -z "$OSS_EP" ]]; then
  cat <<-EOF > "$GITHUB_WORKSPACE/.oss.yml"
	endpoint: $OSS_EP
	accesskeyid: $OSS_AK
	accesskeysecret: $OSS_SK
	bucket: $OSS_BK
	EOF
  echo "OSS config setting done."
fi