#!/bin/bash -e
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

${pre_install}

yum update -y

%{ if enable_cloudwatch_agent ~}
yum install amazon-cloudwatch-agent -y
amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:${ssm_key_cloudwatch_agent_config}
%{ endif ~}

# Install docker
yum install docker -y
service docker start
usermod -a -G docker ec2-user

chmod 666 /var/run/docker.sock

yum install -y curl jq git --allowerasing

USER_NAME=ec2-user
${install_config_runner}

${post_install}

./svc.sh start
