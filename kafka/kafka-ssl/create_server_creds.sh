#!/bin/bash
KEYSTORE_PASSWORD=confluent

KAFKA_BROKER=$1
if [ -z "$KAFKA_BROKER" ]
then
  echo "Common Name (CN) is missing. Usage: ./create_cnf.sh <Common_Name>"
  exit 1
fi

# Create a directory for the certs

CERTS_DIR=certs/${KAFKA_BROKER}
mkdir -p ${CERTS_DIR}
cd ${CERTS_DIR}

cat > "${KAFKA_BROKER}.cnf" <<- EOM
[req]
prompt = no
distinguished_name = dn
default_md = sha256
default_bits = 4096
req_extensions = v3_req

[ dn ]
countryName = US
organizationName = CONFLUENT
localityName = MountainView
commonName=${KAFKA_BROKER}

[ v3_ca ]
subjectKeyIdentifier=hash
basicConstraints = critical,CA:true
authorityKeyIdentifier=keyid:always,issuer:always
keyUsage = critical,keyCertSign,cRLSign

[ v3_req ]
subjectKeyIdentifier = hash
basicConstraints = CA:FALSE
nsComment = "OpenSSL Generated Certificate"
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names

[ alt_names ]
DNS.1=${KAFKA_BROKER}
DNS.2=${KAFKA_BROKER}-external
DNS.3=localhost
EOM


# Create the private key and CSR

openssl req -new -nodes \
    -newkey rsa:2048 \
    -keyout ${KAFKA_BROKER}.key \
    -out ${KAFKA_BROKER}.csr \
    -config ${KAFKA_BROKER}.cnf

# Sign the public key with the CA cert

openssl x509 -req \
    -CA ../root/ca.crt \
    -CAkey ../root/ca.key \
    -CAcreateserial \
    -in ${KAFKA_BROKER}.csr \
    -out ${KAFKA_BROKER}.crt \
    -days 365 \
    -extensions v3_req \
    -extfile ${KAFKA_BROKER}.cnf


# convert the public cert and private key to PKCS12 format

openssl pkcs12 -export \
    -out ${KAFKA_BROKER}.keystore.pkcs12 \
    -name ${KAFKA_BROKER} \
    -in ${KAFKA_BROKER}.crt \
    -inkey ${KAFKA_BROKER}.key \
    -chain \
    -CAfile ../root/ca.crt \
    -caname CARoot \
    -password pass:${KEYSTORE_PASSWORD}


# openssl pkcs12 -export \
#     -out ${KAFKA_BROKER}.p12 \
#     -name ${KAFKA_BROKER} \
#     -in ${KAFKA_BROKER}.crt \
#     -inkey ${KAFKA_BROKER}.key \
#     -chain \
#     -CAfile ../root/ca.crt \
#     -caname CARoot \
#     -password pass:${KEYSTORE_PASSWORD}


# # use keytool to import the PKCS12 file into a JKS file

# keytool -importkeystore \
#     -srckeystore ${KAFKA_BROKER}.p12 \
#     -srcstorepass ${KEYSTORE_PASSWORD} \
#     -srcstoretype PKCS12 \
#     -destkeystore ${KAFKA_BROKER}.keystore.pkcs12 \
#     -deststorepass ${KEYSTORE_PASSWORD} \
#     -deststoretype PKCS12 \
#     -noprompt

# create the truststore and import the CA cert

keytool -keystore ${KAFKA_BROKER}.truststore.pkcs12 \
    -storetype PKCS12 \
    -storepass ${KEYSTORE_PASSWORD}  \
    -alias CARoot \
    -import \
    -file ../root/ca.crt \
    -noprompt \



## save credentials

echo ${KEYSTORE_PASSWORD} > ${KAFKA_BROKER}_sslkey_creds
echo ${KEYSTORE_PASSWORD} > ${KAFKA_BROKER}_keystore_creds
echo ${KEYSTORE_PASSWORD} > ${KAFKA_BROKER}_truststore_creds