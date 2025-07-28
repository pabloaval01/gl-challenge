#!/bin/bash

# Install httpd & mod_ssl
yum update -y
yum install -y httpd mod_ssl

systemctl enable httpd

# Comment to avoid conflicts and duplications in the CFG
sed -i 's/^Listen 443/#Listen 443/' /etc/httpd/conf/httpd.conf

mkdir -p /etc/httpd/ssl

# Generate self-signed certificate
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /etc/httpd/ssl/selfsigned.key \
  -out /etc/httpd/ssl/selfsigned.crt \
  -subj "/C=US/ST=State/L=City/O=Org/OU=Unit/CN=$(hostname -f)"

echo 'LogFormat "%h %l %u %t \"%%r\" %>s %b \"%%{Referer}i\" \"%%{User-Agent}i\" %%p" combined_with_port' >> /etc/httpd/conf/httpd.conf



# Create VHost 443
cat > /etc/httpd/conf.d/vhost_https.conf <<EOF
<VirtualHost *:443>
    DocumentRoot "/var/www/html"
    ServerName $(hostname -f)

    SSLEngine on
    SSLCertificateFile /etc/httpd/ssl/selfsigned.crt
    SSLCertificateKeyFile /etc/httpd/ssl/selfsigned.key

    <Directory "/var/www/html">
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Create VHost 80
cat > /etc/httpd/conf.d/vhost_http.conf <<EOF
<VirtualHost *:80>
    DocumentRoot "/var/www/html"
    ServerName $(hostname -f)
    
    <Directory "/var/www/html">
        Require all granted
    </Directory>
</VirtualHost>
EOF


echo "Apache HTTP and HTTPS OK - $(hostname -f)" > /var/www/html/index.html

systemctl restart httpd
