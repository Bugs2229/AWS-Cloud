#!/bin/bash
# Install and start web server
dnf update -y
dnf install -y httpd
systemctl start httpd
systemctl enable httpd

# Variable for the URL
BASE_URL="http://169.254.169.254/latest"
# Get token for metadata requests
TOKEN=$(curl -X PUT "$BASE_URL/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 3600" -s)
# Collect instance info and save to variables
LOCAL_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "$BASE_URL/meta-data/local-ipv4")
AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "$BASE_URL/meta-data/placement/availability-zone")
HOST_NAME=$(hostname -f)

# Download index.html from GitHub
curl -o /var/www/html/index.html "https://raw.githubusercontent.com/aaron-dm-mcdonald/Class7-notes/main/091425/static/index.html"

# Download CSS file from GitHub
curl -o /var/www/html/style.css "https://raw.githubusercontent.com/aaron-dm-mcdonald/Class7-notes/main/091425/static/style.css"

# Download images from GitHub
curl -o /var/www/html/1.jpg "https://raw.githubusercontent.com/aaron-dm-mcdonald/Class7-notes/main/091425/img/1.jpg"
curl -o /var/www/html/2.jpg "https://raw.githubusercontent.com/aaron-dm-mcdonald/Class7-notes/main/091425/img/2.jpg"
curl -o /var/www/html/3.jpg "https://raw.githubusercontent.com/aaron-dm-mcdonald/Class7-notes/main/091425/img/3.jpg"


# Inject the instance metadata into the downloaded HTML file
sed -i "s/{{HOSTNAME}}/${HOST_NAME}/g" /var/www/html/index.html
sed -i "s/{{LOCAL_IP}}/${LOCAL_IP}/g" /var/www/html/index.html
sed -i "s/{{AZ}}/${AZ}/g" /var/www/html/index.html

# Inject the image filenames into the HTML file
sed -i "s/{{IMAGE_1}}/1.jpg/g" /var/www/html/index.html
sed -i "s/{{IMAGE_2}}/2.jpg/g" /var/www/html/index.html
sed -i "s/{{IMAGE_3}}/3.jpg/g" /var/www/html/index.html

# Restart httpd to ensure all changes take effect
systemctl restart httpd