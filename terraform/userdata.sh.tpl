#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
  yum -y update
  python /tmp/setup-ephemeral-storage.py | tee /tmp/storagelayout.json
  chown -R ec2-user:ec2-user /media
  rm -f /tmp/setup-ephemeral-storage.py
  mkdir -p /home/ec2-user/spark/conf
  cat <<'EOF' >> /home/ec2-user/spark/conf/spark-env.sh
#!/usr/bin/env bash

SPARK_EPHEMERAL_DIRS=$(cat /tmp/storagelayout.json | jq -r '[.ephemeral | .[] | "\(.)/spark"] | join(",")')
SPARK_ROOT_DIR=$(cat /tmp/storagelayout.json | jq -r '.root')/spark
if [ -z "$SPARK_EPHEMERAL_DIRS" ]
then
  export SPARK_LOCAL_DIRS="$SPARK_ROOT_DIR"
else
  export SPARK_LOCAL_DIRS="$SPARK_EPHEMERAL_DIRS"
fi

# Standalone cluster options
export SPARK_EXECUTOR_INSTANCES=$(cat /home/ec2-user/.flintrock-manifest.json | jq '.services | map(select(.[0] == "Spark")) | .[] | .[1].spark_executor_instances')
export SPARK_EXECUTOR_CORES="$(($(nproc) / $SPARK_EXECUTOR_INSTANCES))"
export SPARK_WORKER_CORES="$(nproc)"

export SPARK_MASTER_HOST="${master_host}"

# TODO: Make this dependent on HDFS install.
export HADOOP_CONF_DIR="$HOME/hadoop/conf"

# TODO: Make this non-EC2-specific.
# Bind Spark's web UIs to this machine's public EC2 hostname
export SPARK_PUBLIC_DNS="$(curl --silent http://169.254.169.254/latest/meta-data/public-hostname)"

# TODO: Set a high ulimit for large shuffles
# Need to find a way to do this, since "sudo ulimit..." doesn't fly.
# Probably need to edit some Linux config file.
# ulimit -n 1000000

EOF
%{ for host in slave_hosts ~}
  echo "${host}" >> /home/ec2-user/spark/conf/slaves
%{ endfor ~}

%{ if master_node ~}
systemctl start spark.service
systemctl enable spark.service
%{ endif ~}





