#!/bin/sh
file="./run.properties"

if [ -f "$file" ]
then
  echo "$file found."
  
  while IFS='=' read -r key value
  do
    eval ${key}=${value}
  done < "$file"
else
  echo "$file not found."
fi

cat run.properties | ssh -i "${PEM_FILE_NAME}" "${SSH_USER}@${MASTER_HOST_NAME}" "cat > /tmp/run.properties"
cat shellScript.sh | ssh -i "${PEM_FILE_NAME}" "${SSH_USER}@${MASTER_HOST_NAME}" "cat > /tmp/shellScript.sh ; chmod 777 /tmp/shellScript.sh ; /tmp/shellScript.sh"