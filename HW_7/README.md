## Домашнее задание
1) Создать свой RPM пакет ( возþмем пакет NGINX и соберем его с openssl c поддержкой ГОСТ шифрования)
2) Создать свой репозиторий и разместить там ранее собранный RPM


1) Устанавливаются нужные пакеты для работы:
```
yum install -y \
redhat-lsb-core \
wget \
rpmdevtools \
rpm-build \
createrepo \
yum-utils \
gcc

```
2) Загрузим SRPM пакет NGINX длā дальнейшей работы над ним:
```
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.16.0-1.el7.ngx.src.rpm
rpm -i nginx-1.16.0-1.el7.ngx.src.rpm
```
Когда устанавливаются src rpm, то происходит разорхивация в домашнюю директорию полтзователя из под которого идет работа.
Ожидаемый пользователь - builder

3) Также нужно скачать и разархивировать последнии исходники для openssl - он
потребуется при сборке
```
git clone https://github.com/deemru/openssl.git
```
```
[builder@node2 ~]$ ll
итого 4
drwxr-xr-x. 23 builder builder 4096 май 17 21:29 openssl
drwxr-xr-x.  4 builder builder   34 май 17 21:31 rpmbuild

```
4) Заранее устанавливаются зависимости:

```
[builder@node2 ~]$ sudo yum-builddep rpmbuild/SPECS/nginx.spec

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
[root@packages ~]# yum localinstall -y \
rpmbuild/RPMS/x86_64/nginx-1.16.0-1.el7.ngx.x86_64.rpm
[root@packages ~]# systemctl start nginx
[root@packages ~]# systemctl status nginx
 nginx.service - nginx - high performance web server
 Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
 Active: active (running) since Thu 2018-11-29 07:34:19 UTC; 14min ago
 ```
 Откроем порт 
 ```
 iptables -A IN_public_allow -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
 ```
 
 #### Создать свой репозиторий и разместить там ранее собранный RPM
 
 Инициализируем репозиторий командой:
 ```
[root@packages ~]# createrepo /usr/share/nginx/html/repo/
Spawning worker 0 with 2 pkgs Видим что в репозитории два пакета
Workers Finished
Saving Primary metadata
Saving file lists metadata
Saving other metadata
Generating sqlite DBs Обратите внимание что используется sqlite
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
[root@packages ~]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
[root@packages ~]# nginx -s reload
```
Создать свой репозиторий и разместить там ранее собранный RPM
* Теперь ради интереса можно посмотреть в браузере или curl:
```
[root@packages ~]# lynx http://localhost/repo/
[root@packages ~]# curl -a http://localhost/repo/
<html>
<head><title>Index of /repo/</title></head>
<body bgcolor="white">
<h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
<a href="repodata/">repodata/</a> 29-Nov-2018 10:23 -
<a href="nginx-1.14.1-1.el7_4.ngx.x86_64.rpm">nginx-1.14.1-1.el7_4.ngx.x86_64.rpm</a>
29-Nov-2018 09:47 1999600
<a href="percona-release-0.1-6.noarch.rpm">percona-release-0.1-6.noarch.rpm</a>
13-Jun-2018 06:34 14520
</pre><hr></body>
</html>
```
Создать свой репозиторий и разместить там ранее собранный RPM
* Все готово для того, чтобы протестировать репозиторий.
* Добавим его в /etc/yum.repos.d:
```
[root@packages ~]# cat >> /etc/yum.repos.d/otus.repo << EOF
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
[root@packages ~]# yum repolist enabled | grep otus
otus otus-linux 2
[root@packages ~]# yum list | grep otus
nginx 1.14.1 otus
percona-release.noarch 0.1-6 otus
```
* Так как NGINX у нас уже стоит установим репозиторий percona-release:
```
[root@packages ~]# yum install percona-release -y
```
* Все прошло успешно. В случае если вам потребуется обновить репозиторий (а это
делается при каждом добавлении файлов), снова то выполните команду createrepo
/usr/share/nginx/html/repo/
 
