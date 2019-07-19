#!/bin/bash
set -e

DEFAULT_SSL_PATH=$(pwd)/ssl

read -p "Enter your generate path: " SSL_PATH

if [[ -z $SSL_PATH ]]; then
    SSL_PATH=$DEFAULT_SSL_PATH
fi

echo "Certificate will generate in path: $SSL_PATH"

# auto make dir path
mkdir -p $SSL_PATH

# create self-signed server certificate:

read -p "Enter your domain [example.com]: " DOMAIN

if [[ -z $DOMAIN ]]; then
    DOMAIN="example.com"
fi

# ca subject config
CA_SUBJECT="/C=CN/ST=BJ/L=BJ/O=YUGA/OU=YUGA/CN=YUGA"
CERT_SUBJECT="/C=CN/ST=BJ/L=BJ/O=YUGA/OU=YUGA/CN=$DOMAIN"

# CA Organization Create
echo "Create CA Organization..."
CA_KEY_FILE=$SSL_PATH/ca.key
CA_CSR_FILE=$SSL_PATH/ca.csr
CA_CERT_FILE=$SSL_PATH/ca.cert
CA_PEM_FILE=$SSL_PATH/ca.pem

openssl genrsa -out $CA_KEY_FILE 1024
openssl req -new -key $CA_KEY_FILE -subj $CA_SUBJECT -out $CA_CSR_FILE
openssl x509 -req -in $CA_CSR_FILE -signkey $CA_KEY_FILE -out $CA_CERT_FILE
openssl x509 -in $CA_CERT_FILE -out $CA_PEM_FILE -outform PEM
# --------- CA end

# Create Server side certificate
echo "Create Server Certificate..."
SERVER_KEY_FILE=$SSL_PATH/$DOMAIN.server.key
SERVER_CSR_FILE=$SSL_PATH/$DOMAIN.server.csr
SERVER_CERT_FILE=$SSL_PATH/$DOMAIN.server.cert
SERVER_PEM_FILE=$SSL_PATH/$DOMAIN.server.pem

openssl genrsa -out $SERVER_KEY_FILE 1024
openssl req -new -subj $CERT_SUBJECT -key $SERVER_KEY_FILE -out $SERVER_CSR_FILE
openssl x509 -req -days 3650 -CA $CA_CERT_FILE -CAkey $CA_KEY_FILE -CAcreateserial -in $SERVER_CSR_FILE -out $SERVER_CERT_FILE
openssl x509 -in $SERVER_CERT_FILE -out $SERVER_PEM_FILE -outform PEM
# --------- Server end

# Create Client side certificate
echo "Create Server Certificate..."
CLIENT_KEY_FILE=$SSL_PATH/$DOMAIN.client.key
CLIENT_CSR_FILE=$SSL_PATH/$DOMAIN.client.csr
CLIENT_CERT_FILE=$SSL_PATH/$DOMAIN.client.cert
CLIENT_PEM_FILE=$SSL_PATH/$DOMAIN.client.pem

openssl genrsa -out $CLIENT_KEY_FILE 1024
openssl req -new -subj $CERT_SUBJECT -key $CLIENT_KEY_FILE -out $CLIENT_CSR_FILE
openssl x509 -req -CA $CA_CERT_FILE -CAkey $CA_KEY_FILE -CAcreateserial -in $CLIENT_CSR_FILE -out $CLIENT_CERT_FILE
openssl x509 -in $CLIENT_CERT_FILE -out $CLIENT_PEM_FILE -outform PEM
# --------- Client end

echo "For nginx config:"
echo "Copy $SERVER_CERT_FILE to /etc/nginx/ssl/$DOMAIN.server.cert"
echo "Copy $SERVER_KEY_FILE to /etc/nginx/ssl/$DOMAIN.server.key"
echo "Add configuration in nginx:"
echo "server {"
echo "    ..."
echo "    listen 443 ssl;"
echo "    ssl_certificate     /etc/nginx/ssl/$DOMAIN.server.cert;"
echo "    ssl_certificate_key /etc/nginx/ssl/$DOMAIN.server.key;"
echo "}"
