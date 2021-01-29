ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

sed "s/ENCRYPTION_KEY/${ENCRYPTION_KEY}/" encryption-config.template.yml  > encryption-config.yml
