# Работа с дисковой подсистемой

## Модернизация vagrantfile для добавления дополнительных дисков

В файде *vagrantfile* вводим переменную ***home*** в начале файла для указания пути к директории где будут храниться созданные диски

```bash
 home = ENV['HOME']
```

в секции *:disks* добавляем следующие строки:

```bash
   :sata5 => {
          :dfile => home + '/VirtualBox/disks/sata5.vdi',
          :size => 250, # Megabytes
          :port => 5
    },
    :sata6 => {
          :dfile => home + '/VirtualBox/disks/sata6.vdi',
          :size => 250, # Megabytes
          :port => 6
    },
    :sata7 => {
          :dfile => home + '/VirtualBox/disks/sata7.vdi',
          :size => 250, # Megabytes
          :port => 7
    }
```

Запускаем команду ***vagrant up*** для создания виртуальной машины

## Создание RAID массивов

Создадим два RAID массива ***/dev/md0 = RAID 1*** и ***/dev/md1 = RAID6***  для этого заходим в консоль созданной VM введя в консоле команду ***vagrant ssh***
подключивсшись к консоли виртуальной машины проверим что диски созданы и подключены для этого набираем  команду ***sudo lshw -short | grep disk***
получаем следующий результат:

```bash
[vagrant@otuslinux ~]$ sudo lshw -short | grep disk
/0/100/1.1/0.0.0    /dev/sda   disk        42GB VBOX HARDDISK
/0/100/d/0          /dev/sdb   disk        262MB VBOX HARDDISK
/0/100/d/1          /dev/sdc   disk        262MB VBOX HARDDISK
/0/100/d/2          /dev/sdd   disk        262MB VBOX HARDDISK
/0/100/d/3          /dev/sde   disk        262MB VBOX HARDDISK
/0/100/d/4          /dev/sdf   disk        262MB VBOX HARDDISK
/0/100/d/5          /dev/sdg   disk        262MB VBOX HARDDISK
/0/100/d/0.0.0      /dev/sdh   disk        262MB VBOX HARDDISK
```

так же можно проверить выполнив команду ***sudo fdisk -l*** получим следующий результат:

```bash
[vagrant@otuslinux ~]$ sudo fdisk -l

Disk /dev/sdc: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdb: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sda: 42.9 GB, 42949672960 bytes, 83886080 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x0009ef88

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048    83886079    41942016   83  Linux

Disk /dev/sde: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdd: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdg: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdf: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sdh: 262 MB, 262144000 bytes, 512000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

На всякий случай зануляем суперблоки (хотя для новых дисков можно этого не делать) введя следуающую команду:

***sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g,h}***

Результат команды:

```bash
[vagrant@otuslinux ~]$ sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g,h}
mdadm: Unrecognised md component device - /dev/sdb
mdadm: Unrecognised md component device - /dev/sdc
mdadm: Unrecognised md component device - /dev/sdd
mdadm: Unrecognised md component device - /dev/sde
mdadm: Unrecognised md component device - /dev/sdf
mdadm: Unrecognised md component device - /dev/sdg
mdadm: Unrecognised md component device - /dev/sdh
```

создаем массив RAID 1:

```bash
[vagrant@otuslinux ~]$ sudo mdadm --create --verbose /dev/md0 -l 1 -n 2 /dev/sd{b,c}
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
mdadm: size set to 254976K
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
```

затем создаем массив RAID 6:

```bash
[vagrant@otuslinux ~]$ sudo mdadm --create --verbose /dev/md1 -l 6 -n 5 /dev/sd{d,e,f,g,h}
mdadm: layout defaults to left-symmetric
mdadm: layout defaults to left-symmetric
mdadm: chunk size defaults to 512K
mdadm: size set to 253952K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
```

Проверяем что наши RAID-ы нормально собрались. Для этого запускаем команду ***cat /proc/mdstat***. Результат:

```bash
 [vagrant@otuslinux ~]$ cat /proc/mdstat
Personalities : [raid1] [raid6] [raid5] [raid4]
md1 : active raid6 sdh[4] sdg[3] sdf[2] sde[1] sdd[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/5] [UUUUU]

md0 : active raid1 sdc[1] sdb[0]
      254976 blocks super 1.2 [2/2] [UU]
```

также работоспособность RAID-ов можно проверить командой ***mdadm -D /dev/mdN*** результаты вывода команды:

```bash
[vagrant@otuslinux ~]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Sun Nov 10 10:12:51 2019
        Raid Level : raid1
        Array Size : 254976 (249.00 MiB 261.10 MB)
     Used Dev Size : 254976 (249.00 MiB 261.10 MB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

       Update Time : Sun Nov 10 10:12:58 2019
             State : clean
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : f57177ee:f25b4feb:61bcdab1:8dc69618
            Events : 17

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
[vagrant@otuslinux ~]$ sudo mdadm -D /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Sun Nov 10 10:13:47 2019
        Raid Level : raid6
        Array Size : 761856 (744.00 MiB 780.14 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Sun Nov 10 10:14:36 2019
             State : clean
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:1  (local to host otuslinux)
              UUID : 397adee8:66045e00:d7eb1126:d641cd80
            Events : 17

    Number   Major   Minor   RaidDevice State
       0       8       48        0      active sync   /dev/sdd
       1       8       64        1      active sync   /dev/sde
       2       8       80        2      active sync   /dev/sdf
       3       8       96        3      active sync   /dev/sdg
       4       8      112        4      active sync   /dev/sdh
```

## Создание конфигурационного файла mdadm.conf

Для начала убеждаемся что информация верна введя команду ***mdadm --detail --scan --verbose***
получаем следующий результат:

```bash
[vagrant@otuslinux ~]$ sudo mdadm --detail --scan --verbose
ARRAY /dev/md0 level=raid1 num-devices=2 metadata=1.2 name=otuslinux:0 UUID=f57177ee:f25b4feb:61bcdab1:8dc69618
   devices=/dev/sdb,/dev/sdc
ARRAY /dev/md1 level=raid6 num-devices=5 metadata=1.2 name=otuslinux:1 UUID=397adee8:66045e00:d7eb1126:d641cd80
   devices=/dev/sdd,/dev/sde,/dev/sdf,/dev/sdg,/dev/sdh
```

теперь создаем файл **mdadm.conf**

```bash
[vagrant@otuslinux etc]$ sudo echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
[vagrant@otuslinux etc]$ sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
```

## Ломаем/чиним RAID

Искусственно "зафейливаем" одно из блочных устройств в RAID 6

```bash
[vagrant@otuslinux mdadm]$ sudo mdadm /dev/md1 --fail /dev/sdf
mdadm: set /dev/sdf faulty in /dev/md1
```

Проверяем что один из логических дисков RAID 6 в состоянии ***Failed***

```bash
[vagrant@otuslinux mdadm]$ cat /proc/mdstat
Personalities : [raid1] [raid6] [raid5] [raid4]
md1 : active raid6 sdh[4] sdg[3] sdf[2](F) sde[1] sdd[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/4] [UU_UU]
```

другой способ проверить

```bash
[vagrant@otuslinux mdadm]$ sudo mdadm -D /dev/md1
/dev/md1:
           Version : 1.2
     Creation Time : Sun Nov 10 10:13:47 2019
        Raid Level : raid6
        Array Size : 761856 (744.00 MiB 780.14 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Sun Nov 10 14:04:54 2019
             State : clean, degraded
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 1
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:1  (local to host otuslinux)
              UUID : 397adee8:66045e00:d7eb1126:d641cd80
            Events : 19

    Number   Major   Minor   RaidDevice State
       0       8       48        0      active sync   /dev/sdd
       1       8       64        1      active sync   /dev/sde
       -       0        0        2      removed
       3       8       96        3      active sync   /dev/sdg
       4       8      112        4      active sync   /dev/sdh

       2       8       80        -      faulty   /dev/sdf
```

Удаляем "сломанный" диск из массива

```bash
[vagrant@otuslinux mdadm]$ sudo mdadm /dev/md1 --remove /dev/sdf
mdadm: hot removed /dev/sdf from /dev/md1
```

Добавляем в массив новый диск

```bash
[vagrant@otuslinux mdadm]$ sudo mdadm /dev/md1 --add /dev/sdf
mdadm: added /dev/sdf
```

проверяем что RAID пересобрался

```bash
[vagrant@otuslinux mdadm]$ cat /proc/mdstat
Personalities : [raid1] [raid6] [raid5] [raid4]
md1 : active raid6 sdf[5] sdh[4] sdg[3] sde[1] sdd[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/5] [UUUUU]
```

## Создаем GPT раздел, пять партиций и монтируем их на диск

### Создаем GPT раздел на RAID 6

Для создания раздела на собраном RAID даем команду ***parted -s /dev/md1 mklabel gpt***

### Создаем партиции

Для создания партиций на созданном разделе необходимо выполнить команду
***parted /dev/md1 mkpart primary ext4 X% Y%***

здесь:

- **primary** - тип создаваемой  партиции
- **ext4** - файловая система создаваемой партиции
- **X%** - начало партиции в процентахот общей емкости раздела
- **Y%** - конец партиции в процентах от общей емкости раздела

Результат выподнения:

```bash
[vagrant@otuslinux mdadm]$ sudo parted /dev/md1 mkpart primary ext4 0% 20%
Information: You may need to update /etc/fstab.

[vagrant@otuslinux mdadm]$ sudo parted /dev/md1 mkpart primary ext4 20% 40%
Information: You may need to update /etc/fstab.

[vagrant@otuslinux mdadm]$ sudo parted /dev/md1 mkpart primary ext4 40% 60%
Information: You may need to update /etc/fstab.

[vagrant@otuslinux mdadm]$ sudo parted /dev/md1 mkpart primary ext4 60% 80%
Information: You may need to update /etc/fstab.

[vagrant@otuslinux mdadm]$ sudo parted /dev/md1 mkpart primary ext4 80% 100%
Information: You may need to update /etc/fstab.
```

### Создание файловой системы на партициях

Для создания файловой  системы на вновь созданных партициях можно воспользоваться командой
***for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done***

результат выполнения команды

```bash
[vagrant@otuslinux mdadm]$ for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md1p$i; done
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
37696 inodes, 150528 blocks
7526 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
1984 inodes per group
Superblock backups stored on blocks:
        8193, 24577, 40961, 57345, 73729

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
38152 inodes, 152064 blocks
7603 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
2008 inodes per group
Superblock backups stored on blocks:
        8193, 24577, 40961, 57345, 73729

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
38456 inodes, 153600 blocks
7680 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
2024 inodes per group
Superblock backups stored on blocks:
        8193, 24577, 40961, 57345, 73729

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
38152 inodes, 152064 blocks
7603 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
2008 inodes per group
Superblock backups stored on blocks:
        8193, 24577, 40961, 57345, 73729

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
37696 inodes, 150528 blocks
7526 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
1984 inodes per group
Superblock backups stored on blocks:
        8193, 24577, 40961, 57345, 73729

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done
```

### Монтирование созданных партиций на диск

Для монтирования по партиций по каталогам выполняем следующие команды:

- создаем каталоги с именем партиций ***mkdir -p /raid/part{1,2,3,4,5}***
- запускаем команду для монтирования партиций в созданные каталоги
***for i in $(seq 1 5); do sudo mount /dev/md1p$i /raid/part$i; done***

Результат:

```bash
[vagrant@otuslinux mdadm]$ sudo mkdir -p /raid/part{1,2,3,4,5}
[vagrant@otuslinux mdadm]$ for i in $(seq 1 5); do sudo mount /dev/md1p$i /raid/part$i; done
[vagrant@otuslinux mdadm]$
```

