1) проверить форвардинг c inetRouter2 на centralServer: 
- открыть на хосте в браузере localhost:4567 (порт 8080 inetRouter2 проброшен в гипервизор 4567)
2) проверить knocking port:
- в домашней директории vagrant на centralRouter лежит скрипт open_ssh.sh, чтобы "постучать" на inetRoter, и если сделать
./open_ssh.sh open или ./open_ssh.sh close - а потом проверить порт - nmap 192.168.255.1 22 - то можно увидеть как порт открывается/
закрывается. Также можно ssh vagrant@192.168.255.1 c паролем vagrant
