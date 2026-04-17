#!/bin/bash

TRUSTSTORE_PASSWORD=confluent

mkdir -p certs/root
cd certs/root


cat > "ca.cnf" <<- EOM
[ policy_match ]
countryName = match
stateOrProvinceName = match
organizationName = match
organizationalUnitName = optional
commonName = supplied
emailAddress = optional

[ req ]
prompt = no
distinguished_name = dn
default_md = sha256
default_bits = 4096
x509_extensions = v3_ca

[ dn ]
countryName = US
organizationName = Confluent
localityName = MountainView
commonName = confluent-ca

[ v3_ca ]
subjectKeyIdentifier=hash
basicConstraints = critical,CA:true
authorityKeyIdentifier=keyid:always,issuer:always
keyUsage = critical,keyCertSign,cRLSign
EOM


# Create the CA Key and Certificate for signing Client Certs

openssl req -new -nodes -x509 -days 365 \
   -newkey rsa:2048 \
   -config ca.cnf \
   -keyout ca.key -out ca.crt

# cat ca.crt ca.key > ca.pem
