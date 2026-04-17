#!/bin/bash
KEYSTORE_PASSWORD=confluent
TRUSTSTORE_PASSWORD=confluent

CLIENT_NAME=$1

CERTS_DIR=certs/${CLIENT_NAME}

mkdir -p ${CERTS_DIR}
cd ${CERTS_DIR}

KEYSTORE_FILE=${CLIENT_NAME}.keystore.pkcs12
TRUSTSTORE_FILE=${CLIENT_NAME}.truststore.jks

rm -f ${KEYSTORE_FILE} ${TRUSTSTORE_FILE} ${CLIENT_NAME}.csr ${CLIENT_NAME}.crt ${CLIENT_NAME}.key ${CLIENT_NAME}.cnf ${CLIENT_NAME}.properties

cat > "${CLIENT_NAME}.cnf" <<- EOM
[req]
prompt = no
distinguished_name = dn
default_md = sha256
default_bits = 4096

[ dn ]
C = US            # Country
ST = California   # State
L = San Francisco # Location
O = My Company    # Organisation
OU = My Unit      # Organisational Unit
emailAddress = yangdong07@gmail.com   # Email address
CN = ${CLIENT_NAME}  # Common Name
EOM

cat << EOF > "${CLIENT_NAME}.properties" 
security.protocol = SSL
ssl.truststore.location=$(pwd)/${TRUSTSTORE_FILE}
ssl.truststore.password=${TRUSTSTORE_PASSWORD}
ssl.keystore.location=$(pwd)/${KEYSTORE_FILE}
ssl.keystore.password=${KEYSTORE_PASSWORD}
ssl.key.password=${KEYSTORE_PASSWORD}
EOF


# Create the private key and CSR

openssl req -new -nodes \
    -newkey rsa:2048 \
    -keyout client.key \
    -out ${CLIENT_NAME}.csr \
    -config ${CLIENT_NAME}.cnf

# Sign the public key with the CA cert

openssl x509 -req \
    -CA ../root/ca.crt \
    -CAkey ../root/ca.key \
    -CAcreateserial \
    -in ${CLIENT_NAME}.csr \
    -out ${CLIENT_NAME}.crt \
    -days 365


# convert the public cert and private key to PKCS12 format

openssl pkcs12 -export \
    -out ${KEYSTORE_FILE} \
    -name ${CLIENT_NAME} \
    -in ${CLIENT_NAME}.crt \
    -inkey ${CLIENT_NAME}.key \
    -password pass:${KEYSTORE_PASSWORD}


# create the truststore and import the CA cert
keytool -keystore ${TRUSTSTORE_FILE} \
    -storetype PKCS12 \
    -storepass ${KEYSTORE_PASSWORD}  \
    -alias CARoot \
    -import \
    -file ../root/ca.crt \
    -noprompt 


