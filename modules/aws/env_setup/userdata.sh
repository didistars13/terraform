#!/bin/bash

# Install necessary packages and start HTTP server
sudo yum update -y
sudo yum install -y httpd
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

# Embedded base64-encoded HTML content
cat <<EOF | base64 -d > /var/www/html/index.html
PCFET0NUWVBFIGh0bWw+CjxodG1sPgo8aGVhZD4KICAgIDx0aXRsZT5FQzIgSW5zdGFuY2UgSW5mb3JtYXRpb248L3RpdGxlPgogICAgPHN0eWxlPgogICAgICAgIGJvZHkgewogICAgICAgICAgICBmb250LWZhbWlseTogQXJpYWwsIHNhbnMtc2VyaWY7CiAgICAgICAgICAgIGJhY2tncm91bmQ6IGxpbmVhci1ncmFkaWVudCgxMzVkZWcsIHZpb2xldCwgbGlnaHRibHVlKTsKICAgICAgICAgICAgY29sb3I6ICMzMzM7CiAgICAgICAgICAgIG1hcmdpbjogMDsKICAgICAgICAgICAgcGFkZGluZzogMDsKICAgICAgICB9CiAgICAgICAgaDEgewogICAgICAgICAgICB0ZXh0LWFsaWduOiBjZW50ZXI7CiAgICAgICAgICAgIGNvbG9yOiB3aGl0ZTsKICAgICAgICAgICAgcGFkZGluZzogMjBweDsKICAgICAgICAgICAgYmFja2dyb3VuZC1jb2xvcjogIzRCMDA4MjsgLyogSW5kaWdvICovCiAgICAgICAgfQogICAgICAgIHRhYmxlIHsKICAgICAgICAgICAgbWFyZ2luOiAyMHB4IGF1dG87CiAgICAgICAgICAgIGJvcmRlci1jb2xsYXBzZTogY29sbGFwc2U7CiAgICAgICAgICAgIHdpZHRoOiA4MCU7CiAgICAgICAgICAgIGJveC1zaGFkb3c6IDAgNHB4IDhweCByZ2JhKDAsIDAsIDAsIDAuMik7CiAgICAgICAgfQogICAgICAgIHRoLCB0ZCB7CiAgICAgICAgICAgIGJvcmRlcjogMXB4IHNvbGlkICNkZGQ7CiAgICAgICAgICAgIHBhZGRpbmc6IDEycHg7CiAgICAgICAgICAgIHRleHQtYWxpZ246IGxlZnQ7CiAgICAgICAgfQogICAgICAgIHRoIHsKICAgICAgICAgICAgYmFja2dyb3VuZC1jb2xvcjogIzZBNUFDRDsgLyogU2xhdGUgQmx1ZSAqLwogICAgICAgICAgICBjb2xvcjogd2hpdGU7CiAgICAgICAgfQogICAgICAgIHRyOm50aC1jaGlsZChldmVuKSB7CiAgICAgICAgICAgIGJhY2tncm91bmQtY29sb3I6ICNmMmYyZjI7CiAgICAgICAgfQogICAgICAgIHRyOmhvdmVyIHsKICAgICAgICAgICAgYmFja2dyb3VuZC1jb2xvcjogI2RkZDsKICAgICAgICB9CiAgICA8L3N0eWxlPgo8L2hlYWQ+Cjxib2R5PgogICAgPGgxPkVDMiBJbnN0YW5jZSBJbmZvcm1hdGlvbjwvaDE+CiAgICA8dGFibGU+CiAgICAgICAgPHRyPjx0aD5Qcm9wZXJ0eTwvdGg+PHRoPlZhbHVlPC90aD48L3RyPgogICAgICAgIDx0cj48dGQ+SW5zdGFuY2UgSUQ8L3RkPjx0ZD57e0lOU1RBTkNFX0lEfX08L3RkPjwvdHI+CiAgICAgICAgPHRyPjx0ZD5JbnN0YW5jZSBUeXBlPC90ZD48dGQ+e3tJTlNUQU5DRV9UWVBFfX08L3RkPjwvdHI+CiAgICAgICAgPHRyPjx0ZD5SZWdpb248L3RkPjx0ZD57e1JFR0lPTn19PC90ZD48L3RyPgogICAgICAgIDx0cj48dGQ+QXZhaWxhYmlsaXR5IFpvbmU8L3RkPjx0ZD57e0FWQUlMQUJJTElUWV9aT05FfX08L3RkPjwvdHI+CiAgICA8L3RhYmxlPgo8L2JvZHk+CjwvaHRtbD4K
EOF

# Replace placeholders with actual metadata
sed -i "s/{{INSTANCE_ID}}/${INSTANCE_ID}/g" /var/www/html/index.html
sed -i "s/{{INSTANCE_TYPE}}/${INSTANCE_TYPE}/g" /var/www/html/index.html
sed -i "s/{{REGION}}/${REGION}/g" /var/www/html/index.html
sed -i "s/{{AVAILABILITY_ZONE}}/${AVAILABILITY_ZONE}/g" /var/www/html/index.html
