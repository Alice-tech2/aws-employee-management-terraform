#!/bin/bash
set -e

yum update -y
yum install -y python3 python3-pip
pip3 install flask pymysql boto3

# Fetch DB credentials from Secrets Manager
SECRET=$(aws secretsmanager get-secret-value \
  --secret-id "${db_secret_arn}" \
  --region us-east-2 \
  --query SecretString \
  --output text)

DB_USER=$(echo $SECRET | python3 -c "import sys,json; print(json.load(sys.stdin)['username'])")
DB_PASS=$(echo $SECRET | python3 -c "import sys,json; print(json.load(sys.stdin)['password'])")

# Write app.py from base64 (avoids any shell/HCL interpolation issues)
mkdir -p /opt/employeeapp
echo "${app_b64}" | base64 -d > /opt/employeeapp/app.py

# Write systemd service
cat > /etc/systemd/system/employeeapp.service << SVC
[Unit]
Description=Employee Management Flask App
After=network.target

[Service]
Environment=DB_HOST=${db_host}
Environment=DB_NAME=${db_name}
Environment=DB_USER=$DB_USER
Environment=DB_PASS=$DB_PASS
Environment=ENVIRONMENT=${environment}
ExecStart=/usr/bin/python3 /opt/employeeapp/app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SVC

systemctl daemon-reload
systemctl enable employeeapp
systemctl start employeeapp
