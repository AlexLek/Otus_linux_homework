#!/bin/bash

# очищаем временный файл
> /tmp/psax_temp.file;


declare -a filtered_proc # Массив со списком пидов у которых эффектиный uid совпадает с uid текущего пользователя

#currnet user id
cur_uid=$(id -u)

proc_list=$(ls /proc/ | grep -E '^[0-9]+' | sort -n)

for i in $proc_list 
do
	uids=$(grep "Uid:" /proc/$i/status 2> /dev/null) 
	uidsarr=($uids)
	if [[ ${uidsarr[$i]} -eq $cur_uid ]]; then
		filtered_proc+=( $i )
	fi
done



# Первая строка, как в оригинальном ps
echo "PID TTY  STAT   TIME COMMAND" >> /tmp/psax_temp.file;



# Unix записыает время в "тиках" или циклах таймера, значение ниже - количество тиков в секунде
clk_tck=$(getconf CLK_TCK)

for i in ${filtered_proc[@]} # перебираем все отфильтрованные пиды
do
	if [ -f /proc/$i/stat ]; then
		stats=$(cat /proc/$i/stat); # получаем массив параметров
		statarr=($stats);

		if [ -f /proc/$i/cmdline ] && [ -s /proc/$i/cmdline ]; then
			cmd_of_pid=$(cat /proc/$i/cmdline | tr '\0' '\n'); # получаем комнду/имя процесса
		else
			cmd_of_pid=${statarr[1]};
		fi
		state_of_proc=$(cat /proc/$i/status | grep State: | awk {'print $2'}); # состояние процесса
		tty_of_proc=${statarr[7]}; #tty который нужно еще перевести

		tty_of_proc_binary=$(echo "obase=2;$tty_of_proc" | bc) # tty в двоичном виде

		utime=${statarr[13]}; #время работы процесса из двух частей
		stime=${statarr[14]};

 		time_of_proc=0
 		time_of_proc=$(echo $utime / $clk_tck + $stime / $clk_tck | bc ); # перевод времени в секунды
 		
 		tty_min_bin=$(echo $tty_of_proc_binary | grep -o '[0-1]\{8\}$') # определяем maj/min номер устройства (терминала)
 		tty_maj_bin=$(echo $tty_of_proc_binary | sed "s/[0-1]\{8\}$//g")


 		tty_min_dec=$((2#$tty_min_bin)) # переводим номера в десятичную систему
 		tty_maj_dec=$((2#$tty_maj_bin))

 		# ищем имя устройства с такими номерами в /sys/dev

 		for file in $(find /sys/dev/ -name $tty_maj_dec:$tty_min_dec) 
 		do 
 			source ${file}/uevent; 
 			result_tty=$DEVNAME
 		done;

 		 if [[ -z $result_tty ]]; then
 			result_tty='?' # если не нашли - вопросик
 		fi

 		# выводим все во временный файл
 		echo $i " " $result_tty " " $state_of_proc " "  $time_of_proc " " $cmd_of_pid >> /tmp/psax_temp.file;
 	fi
done
# выводим все в отформатированном виде
cat /tmp/psax_temp.file | column -t
rm -f /tmp/psax_temp.file