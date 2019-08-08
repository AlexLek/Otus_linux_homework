#!/bin/bash

#Компактный скрипт на баш, решил поделить на функции для удобства



# выбрал для задания RAID10
# занулил суперблоки, создал рейд
configure_raid10() {
    mdadm --zero-superblock --force /dev/sd{b,c,d,e}
    mdadm --create --verbose /dev/md0 --level=10 --raid-devices=4 /dev/sd{b,c,d,e}
}


#просто проверка, что все успешно
check_raid() {
    cat /proc/mdstat
    echo "================"
    mdadm -D /dev/md0
}


#сохранил конфигурацию рейда в mdadm.conf, предварительно создал директорию 
save_raid() {
    mkdir -p /etc/mdadm/
    echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
    bash -c "mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf"
}


create_partitions_fs() {
    # буду использовать GPT разделы
    parted -s /dev/md0 mklabel gpt

    # не захотел вносить руками процент для каждого раздела, считаю в цикле, создаю разделы 
    for percent in $(seq 0 20 80); do parted /dev/md0 mkpart primary ext4 $percent% $(($percent+20))%; done

    # аналогично с файловыми системами
    for i in $(seq 1 5); do mkfs.ext4 /dev/md0p$i; done

    # создаю каталоги и монтирую
    mkdir -p /raid/part{1,2,3,4,5}

    for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done

}

main() {
  echo "==Strating to configure RAID10=="
  configure_raid10
  echo "==Debug information=="
  check_raid
  echo "==Saving raid configuration to /etc/mdadm/mdadm.conf=="
  save_raid
  echo "==Creating 5 GPT partitions and FS=="
  create_partitions_fs

}

# баш-эквивалент "питоновскому" if __name__ == "__main__"
# нужен для исполнения main функции, и для защиты от использования
# остальных функций как импортируемых частей модуля
[[ "$0" == "$BASH_SOURCE" ]] && main "$@"