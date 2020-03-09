
## Домашнее задание
1) Создать свой RPM пакет ( возþмем пакет NGINX и соберем его с openssl c поддержкой ГОСТ шифрования)
2) Создать свой репозиторий и разместить там ранее собранный RPM


1) Устанавливаются нужные пакеты для работы:
```
[root@localhost ~]# yum install -y rpmdevtools gcc  make wget gd-devel automake  yum-utils perl-devel zlib-devel create
repo pcre-devel GeoIP-devel openssl-devel libxslt-devel openldap-devel perl-ExtUtils-Embed git tree nano

```
2) Загрузим SRPM пакет NGINX длā дальнейшей работы над ним:
```
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.16.0-1.el7.ngx.src.rpm
rpm -i nginx-1.16.0-1.el7.ngx.src.rpm
```
Когда устанавливаются src rpm, то происходит разорхивация в домашнюю директорию пользователя из под которого идет работа.

3) Также нужно скачать и разархивировать последнии исходники для openssl - он
потребуется при сборке
```
git clone https://github.com/deemru/openssl.git
```
```
[root@localhost ~]# ll
total 1048
-rw-------.  1 root root    5763 May 12  2018 anaconda-ks.cfg
-rw-r--r--.  1 root root 1051956 Apr 23  2019 nginx-1.16.0-1.el7.ngx.src.rpm
drwxr-xr-x. 24 root root    4096 Mar  9 12:55 openssl
-rw-------.  1 root root    5432 May 12  2018 original-ks.cfg
drwxr-xr-x.  8 root root      89 Mar  9 12:51 rpmbuild
```
4) Заранее устанавливаются зависимости:

```
[root@localhost ~]# yum-builddep rpmbuild/SPECS/nginx.spec

```
```
Зависимости определены

=============================================================================================================================================================
 Package                                    Архитектура                   Версия                                        Репозиторий                    Размер
=============================================================================================================================================================
Установка:
 openssl-devel                              x86_64                        1:1.0.2k-16.el7_6.1                           updates                        1.5 M
 pcre-devel                                 x86_64                        8.32-17.el7                                   base                           480 k
 zlib-devel                                 x86_64                        1.2.7-18.el7                                  base                            50 k
Установка зависимостей:
 keyutils-libs-devel                        x86_64                        1.5.8-3.el7                                   base                            37 k
 krb5-devel                                 x86_64                        1.15.1-37.el7_6                               updates                        271 k
 libcom_err-devel                           x86_64                        1.42.9-13.el7                                 base                            31 k
 libkadm5                                   x86_64                        1.15.1-37.el7_6                               updates                        178 k
 libselinux-devel                           x86_64                        2.5-14.1.el7                                  base                           187 k
 libsepol-devel                             x86_64                        2.5-10.el7                                    base                            77 k
 libverto-devel                             x86_64                        0.2.5-4.el7                                   base                            12 k
Обновление зависимостей:
 krb5-libs                                  x86_64                        1.15.1-37.el7_6                               updates                        803 k
 openssl                                    x86_64                        1:1.0.2k-16.el7_6.1                           updates                        493 k
 openssl-libs                               x86_64                        1:1.0.2k-16.el7_6.1                           updates                        1.2 M


```

5) Исправляем spec файл (приложен к этой инструкции)

6) Доступные опции для сборки можно посмотреть здесь https://nginx.org/ru/docs/configure.html
```
 rpmbuild -bb rpmbuild/SPECS/nginx.spec
 ```
 Теперь можно установить наш пакет и убедится, что nginx работает
 ```
[root@localhost ~]# yum localinstall -y \
rpmbuild/RPMS/x86_64/nginx-1.16.0-1.el7.ngx.x86_64.rpm
[root@localhost ~]# systemctl start nginx
[root@localhost ~]#  systemctl status nginx
? nginx.service - nginx - high performance web server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2020-03-09 12:58:41 UTC; 5s ago
     Docs: http://nginx.org/en/docs/
  Process: 13151 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf (code=exited, status=0/SUCCESS)
 Main PID: 13152 (nginx)
   CGroup: /system.slice/nginx.service
           ├─13152 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
           └─13153 nginx: worker process

Mar 09 12:58:41 localhost.localdomain systemd[1]: Starting nginx - high performance web server...
Mar 09 12:58:41 localhost.localdomain systemd[1]: PID file /var/run/nginx.pid not readable (yet?) after start.
Mar 09 12:58:41 localhost.localdomain systemd[1]: Started nginx - high performance web server.
 ```
 Откроем порт 
 ```
 iptables -A IN_public_allow -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
 ```

 #### Создать свой репозиторий и разместить там ранее собранный RPM
 
 Инициализируем репозиторий командой:
 ```
[root@localhost ~]# createrepo /usr/share/nginx/html/repo/     6.0-1.el7.ngx.x
Spawning worker 0 with 2 pkgs
Workers Finished
Saving Primary metadata
Saving file lists metadata
Saving other metadata
Generating sqlite DBs
Sqlite DBs complete
```
Создать свой репозиторий и разместить там ранее собранный RPM
* Для прозрачности настроим в NGINX доступ к листингу каталога:
* В location / в файле /etc/nginx/conf.d/default.conf добавим директиву autoindex on. В
результате location будет выглядеть так:
```
location / {
root /usr/share/nginx/html;
index index.html index.htm;
autoindex on; Добавили эту директиву
}
```
* Проверяем синтаксис и перезапускаем NGINX:
```
[root@localhost ~]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
[root@localhost ~]# nginx -s reload
```
Создать свой репозиторий и разместить там ранее собранный RPM
* Теперь ради интереса можно посмотреть в браузере или curl:
```

[root@localhost ~]# curl -a http://localhost/repo/
<html>
<head><title>Index of /repo/</title></head>
<body>
<h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
<a href="repodata/">repodata/</a>                                          09-Mar-2020 13:05                   -
<a href="nginx-1.16.0-1.el7.ngx.x86_64.rpm">nginx-1.16.0-1.el7.ngx.x86_64.rpm</a>                  09-Mar-2020 13:04
         2139668
<a href="nginx-debuginfo-1.16.0-1.el7.ngx.x86_64.rpm">nginx-debuginfo-1.16.0-1.el7.ngx.x86_64.rpm</a>        09-Mar-2020
 13:04             2576084
</pre><hr></body>
</html>
```
Создать свой репозиторий и разместить там ранее собранный RPM
* Все готово для того, чтобы протестировать репозиторий.
* Добавим его в /etc/yum.repos.d:
```
[root@localhost ~]# cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
```
Создать свой репозиторий и разместить там ранее собранный RPM
* Убедимся что репозиторий подключился и посмотрим что в нем есть:
```
[root@localhost ~]# yum repolist enabled | grep otus
otus                                otus-linux                                 2
[root@localhost ~]# yum list | grep otus
nginx-debuginfo.x86_64                      1:1.16.0-1.el7.ngx         otus
```

