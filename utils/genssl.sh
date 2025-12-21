#!/bin/bash

installed=$(openssl version | cut -d' ' -f2)

if ! printf '%s\n%s\n' "3.4.0" "$installed" | sort -CV; then
  echo "OpenSSL version outdated, requires version 3.4.0 or higher (found $installed)"
  exit 1
fi

clear
echo
echo "Select certificate type:"
echo "1) RSA"
echo "2) EC (Elliptic Curve)"
echo
read -p "Enter choice [1 or 2]: " cert_type
echo

key_file="key.pem"
cert_file="cert.pem"
csr_file="cert.csr"

generate_cert() {
    echo
    IFS= read -p "Enter Common Name (CN) for the certificate: " cn_input
    echo
    openssl req -new -key "$key_file" -out "$csr_file" -subj "/CN=$cn_input"
    openssl x509 -req -in "$csr_file" -signkey "$key_file" -not_before 19700101000000Z -not_after 20901231000000Z -out >
    rm -f "$csr_file"
    echo
    echo "$1 certificate generated: $cert_file / $key_file"
}

if [[ "$cert_type" == "1" ]]; then
    clear
    echo
    echo "Select RSA key size:"
    echo "1) 2048 bits"
    echo "2) 3072 bits"
    echo "3) 4096 bits"
    echo
    read -p "Enter choice [1-3]: " rsa_choice
    echo
    case "$rsa_choice" in
        1) rsa_bits=2048 ;;
        2) rsa_bits=3072 ;;
        3) rsa_bits=4096 ;;
        *) echo "Invalid choice, defaulting to 2048 bits"; rsa_bits=2048 ;;
    esac
    openssl genpkey -algorithm RSA -quiet -out "$key_file" -pkeyopt rsa_keygen_bits:$rsa_bits
    generate_cert "RSA"

elif [[ "$cert_type" == "2" ]]; then
    clear
    echo
    echo "Select EC curve:"
    echo "1) prime256v1"
    echo "2) secp384r1"
    echo "3) secp521r1"
    echo
    read -p "Enter choice [1-3]: " ec_choice
    echo
    case "$ec_choice" in
        1) ec_curve="prime256v1" ;;
        2) ec_curve="secp384r1" ;;
        3) ec_curve="secp521r1" ;;
        *) echo "Invalid choice, defaulting to prime256v1"; ec_curve="prime256v1" ;;
    esac
    openssl ecparam -name "$ec_curve" -genkey -noout -out "$key_file"
    generate_cert "EC"

else
    echo "Invalid choice. Exiting."
    exit 1
fi
