# rpm_repository

Cоздать свой RPM (можно взять свое приложение, либо собрать к примеру апач с определенными опциями)

становим все, что нам понадобится в этой домашней работе:

sudo yum install -y rpmdevtools \
                    gcc \ 
                    make \
                    wget \
                    gd-devel \
                    automake \ 
                    yum-utils \
                    perl-devel \
                    zlib-devel \
                    createrepo \
                    pcre-devel \
                    GeoIP-devel \
                    openssl-devel \
                    libxslt-devel \
                    openldap-devel \
                    perl-ExtUtils-Embed 
Создаем пользователя и логинимся в него:

sudo adduser builder
sudo passwd builder
sudo gpasswd -a builder wheel
sudo su - builder
Создаем структуру каталогов и скачиваем SRPM пакет nginx:

rpmdev-setuptree
rpm -Uvh http://nginx.org/packages/rhel/7/SRPMS/nginx-1.10.1-1.el7.ngx.src.rpm
Далее забираем с Github модуль nginx, который хотим добавить и готовим его нужным образом, кладем в SOURCES:

wget -O master.zip https://github.com/kvspb/nginx-auth-ldap/archive/master.zip
unzip master.zip
mv nginx-auth-ldap-master/ nginx-auth-ldap-0.1
tar cfz nginx-auth-ldap-0.1.tar.gz nginx-auth-ldap-0.1
mv nginx-auth-ldap-0.1.tar.gz  ~/rpmbuild/SOURCES/
rm -rf master.zip nginx-auth-ldap-0.1/
Правим SPEC файл:

vi /home/builder/rpmbuild/SPECS/nginx.spec

# Добавим в Source
  Source14: nginx-auth-ldap-0.1.tar.gz
  
# Добавим в %prep
  %{__tar} zxvf %{SOURCE14}
  %setup -T -D -a 14
  
# Добавим в %build
./configure %{COMMON_CONFIGURE_ARGS} \
    --with-cc-opt="%{WITH_CC_OPT}" \
    --add-module=%{_builddir}/%{name}-%{main_version}/nginx-auth-ldap-0.1
Соберем новый пакет и установим его:

rpmbuild -ba /home/builder/rpmbuild/SPECS/nginx.spec
sudo rpm -i /home/builder/rpmbuild/RPMS/x86_64/nginx-1.10.1-1.el7.ngx.x86_64.rpm
Получим удачную установку nginx:

----------------------------------------------------------------------

Thanks for using nginx!

Please find the official documentation for nginx here:
* http://nginx.org/en/docs/

Commercial subscriptions for nginx are available on:
* http://nginx.com/products/

----------------------------------------------------------------------
Проверим, что модуль установлен через nginx -V:

--add-module=/home/builder/rpmbuild/BUILD/nginx-1.10.1/nginx-auth-ldap-0.1

Готово!


Создать свой репо и разместить там свой RPM
Раз уж nginx у нас уже установлен, сделаем из него репозиторий для yum

Почистим стандартные шаблоны nginx и положим вместо них наши RPM пакеты, собранные в первой части ДЗ:
sudo mkdir /usr/share/nginx/html/repo
sudo rm -rf /usr/share/nginx/html/*
sudo cp /home/builder/rpmbuild/RPMS/x86_64/*.rpm /usr/share/nginx/html/repo
Создадим репозиторий и подготовим:

wget
http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noa
rch.rpm -O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm

Инициализируем репозиторий командой:

createrepo /usr/share/nginx/html/repo/
 
Проверяем синтаксис и перезапускаем NGINX:

nginx -t
nginx -s reload

Теперь ради интереса можно посмотреть в браузере или curl-ануть:

 curl -a http://localhost/repo/
 
 Все готово длā того, чтобý протестироватþ репозиторий.
Добавим его в /etc/yum.repos.d:
cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF

Убедимся что репозиторий подключился и посмотрим что в нем есть:


yum repolist enabled | grep otus
yum list | grep otus

Так как NGINX у нас уже стоит установим репозиторий percona-release:

yum install percona-release -y


Все прошло успешно. В случае если вам потребуетсā обновитþ репозиторий (а это
делается при каждом добавлении файлов), снова то выполните команду 

createrepo /usr/share/nginx/html/repo/
---------------------------------------------

Был добавлен Vagrantfile, в котором записан скрипт. Скрипт исполняется при загрузке машины с помощью команды

vagrant up ---provision

Скрипт автоматически выполняет все то, что было описано выше.
