#!/bin/bash

# Install necessary packages and start HTTP server
sudo yum update -y
sudo yum install -y httpd jq
sudo mkdir -p /var/www/html
sudo chown -R ec2-user:ec2-user /var/www/html
sudo chmod -R 775 /var/www/html
sudo systemctl enable httpd
sudo systemctl start httpd

# Fetch instance metadata
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_TYPE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-type)
REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region)
AVAILABILITY_ZONE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
SSH_KEY_NAME=$(aws ec2 describe-instances --region $REGION --instance-ids $INSTANCE_ID --query "Reservations[].Instances[].KeyName" --output text)
TAG=$(aws ec2 describe-tags --region $REGION --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Name" --query "Tags[0].Value" --output text || echo "Not Available")
INSTANCE_NAME=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/hostname)

# Fetch security group information
SECURITY_GROUP_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION \
  --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" --output text || echo "Not Available")
# Fetch ingress and egress rules
INGRESS_RULES=$(aws ec2 describe-security-groups \
    --group-ids $SECURITY_GROUP_ID \
    --region $REGION \
    --query "SecurityGroups[0].IpPermissions" \
    --output json | jq -r '
    map(
        "\(.FromPort)/IpRanges: \(.IpRanges | map(.CidrIp) | join(", "))"
    ) | join("; ")
')
EGRESS_RULES=$(aws ec2 describe-security-groups \
    --group-ids $SECURITY_GROUP_ID \
    --region $REGION \
    --query "SecurityGroups[0].IpPermissionsEgress" \
    --output json | jq -r '
    map(
        "\(.IpProtocol)/IpRanges: \(.IpRanges | map(.CidrIp) | join(", "))"
    ) | join("; ")
')

# Embedded base64-encoded HTML content
cat <<EOF | base64 -d > /var/www/html/index.html
PCFET0NUWVBFIGh0bWw+CjxodG1sPgo8aGVhZD4KICAgIDx0aXRsZT5FQzIgSW5zdGFuY2UgSW5mb3JtYXRpb248L3RpdGxlPgogICAgPHN0eWxlPgogICAgICAgIGJvZHkgewogICAgICAgICAgICBmb250LWZhbWlseTogQXJpYWwsIHNhbnMtc2VyaWY7CiAgICAgICAgICAgIGJhY2tncm91bmQ6IGxpbmVhci1ncmFkaWVudCgxMzVkZWcsIHZpb2xldCwgbGlnaHRibHVlKTsKICAgICAgICAgICAgY29sb3I6ICMzMzM7CiAgICAgICAgICAgIG1hcmdpbjogMDsKICAgICAgICAgICAgcGFkZGluZzogMDsKICAgICAgICB9CiAgICAgICAgaDEgewogICAgICAgICAgICB0ZXh0LWFsaWduOiBjZW50ZXI7CiAgICAgICAgICAgIGNvbG9yOiB3aGl0ZTsKICAgICAgICAgICAgcGFkZGluZzogMjBweDsKICAgICAgICAgICAgYmFja2dyb3VuZC1jb2xvcjogIzRCMDA4MjsKICAgICAgICB9CiAgICAgICAgdGFibGUgewogICAgICAgICAgICBtYXJnaW46IDIwcHggYXV0bzsKICAgICAgICAgICAgYm9yZGVyLWNvbGxhcHNlOiBjb2xsYXBzZTsKICAgICAgICAgICAgd2lkdGg6IDgwJTsKICAgICAgICAgICAgYm94LXNoYWRvdzogMCA0cHggOHB4IHJnYmEoMCwgMCwgMCwgMC4yKTsKICAgICAgICB9CiAgICAgICAgdGgsIHRkIHsKICAgICAgICAgICAgYm9yZGVyOiAxcHggc29saWQgI2RkZDsKICAgICAgICAgICAgcGFkZGluZzogMTJweDsKICAgICAgICAgICAgdGV4dC1hbGlnbjogbGVmdDsKICAgICAgICB9CiAgICAgICAgdGggewogICAgICAgICAgICBiYWNrZ3JvdW5kLWNvbG9yOiAjNkE1QUNEOwogICAgICAgICAgICBjb2xvcjogd2hpdGU7CiAgICAgICAgfQogICAgICAgIHRyOm50aC1jaGlsZChldmVuKSB7CiAgICAgICAgICAgIGJhY2tncm91bmQtY29sb3I6ICNmMmYyZjI7CiAgICAgICAgfQogICAgICAgIHRyOmhvdmVyIHsKICAgICAgICAgICAgYmFja2dyb3VuZC1jb2xvcjogI2RkZDsKICAgICAgICB9CiAgICA8L3N0eWxlPgo8L2hlYWQ+Cjxib2R5PgogICAgPGgxPkVDMiBJbnN0YW5jZSBJbmZvcm1hdGlvbjwvaDE+CiAgICA8dGFibGU+CiAgICAgICAgPHRyPjx0aD5Qcm9wZXJ0eTwvdGg+PHRoPlZhbHVlPC90aD48L3RyPgogICAgICAgIDx0cj48dGQ+SW5zdGFuY2UgTmFtZTwvdGQ+PHRkPnt7SU5TVEFOQ0VfTkFNRX19PC90ZD48L3RyPgogICAgICAgIDx0cj48dGQ+SW5zdGFuY2UgSUQ8L3RkPjx0ZD57e0lOU1RBTkNFX0lEfX08L3RkPjwvdHI+CiAgICAgICAgPHRyPjx0ZD5UYWc8L3RkPjx0ZD57e1RBR319PC90ZD48L3RyPgogICAgICAgIDx0cj48dGQ+SW5zdGFuY2UgVHlwZTwvdGQ+PHRkPnt7SU5TVEFOQ0VfVFlQRX19PC90ZD48L3RyPgogICAgICAgIDx0cj48dGQ+UmVnaW9uPC90ZD48dGQ+e3tSRUdJT059fTwvdGQ+PC90cj4KICAgICAgICA8dHI+PHRkPkF2YWlsYWJpbGl0eSBab25lPC90ZD48dGQ+e3tBVkFJTEFCSUxJVFlfWk9ORX19PC90ZD48L3RyPgogICAgICAgIDx0cj48dGQ+U1NIIEtleSBOYW1lPC90ZD48dGQ+e3tTU0hfS0VZX05BTUV9fTwvdGQ+PC90cj4KICAgICAgICA8dHI+PHRkPkluZ3Jlc3MgUnVsZXM8L3RkPjx0ZD57e0lOR1JFU1NfUlVMRVN9fTwvdGQ+PC90cj4KICAgICAgICA8dHI+PHRkPkVncmVzcyBSdWxlczwvdGQ+PHRkPnt7RUdSRVNTX1JVTEVTfX08L3RkPjwvdHI+CiAgICA8L3RhYmxlPgo8L2JvZHk+CjwvaHRtbD4K
EOF

# Replace placeholders with actual metadata
sed -i "s/{{INSTANCE_ID}}/${INSTANCE_ID}/g" /var/www/html/index.html
sed -i "s/{{INSTANCE_TYPE}}/${INSTANCE_TYPE}/g" /var/www/html/index.html
sed -i "s/{{REGION}}/${REGION}/g" /var/www/html/index.html
sed -i "s/{{AVAILABILITY_ZONE}}/${AVAILABILITY_ZONE}/g" /var/www/html/index.html
sed -i "s/{{INSTANCE_NAME}}/${INSTANCE_NAME}/g" /var/www/html/index.html
sed -i "s/{{TAG}}/${TAG}/g" /var/www/html/index.html
sed -i "s/{{SSH_KEY_NAME}}/${SSH_KEY_NAME}/g" /var/www/html/index.html
sed -i "s|{{INGRESS_RULES}}|${INGRESS_RULES}|g" /var/www/html/index.html
sed -i "s|{{EGRESS_RULES}}|${EGRESS_RULES}|g" /var/www/html/index.html
