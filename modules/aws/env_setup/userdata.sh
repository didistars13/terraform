#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo mkdir -p /var/www/html
sudo chown -R ec2-user:ec2-user /var/www/html
sudo chmod -R 775 /var/www/html
sudo systemctl enable httpd
sudo systemctl start httpd

# Create index.html dynamically using instance metadata
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_TYPE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-type)
REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region)
AVAILABILITY_ZONE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>EC2 Instance Information</title>
</head>
<body>
    <h1>EC2 Instance Information</h1>
    <table border="1">
        <tr><th>Property</th><th>Value</th></tr>
        <tr><td>Instance ID</td><td>${INSTANCE_ID}</td></tr>
        <tr><td>Instance Type</td><td>${INSTANCE_TYPE}</td></tr>
        <tr><td>Region</td><td>${REGION}</td></tr>
        <tr><td>Availability Zone</td><td>${AVAILABILITY_ZONE}</td></tr>
    </table>
</body>
</html>
EOF
