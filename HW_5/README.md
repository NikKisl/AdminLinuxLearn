# сервисы и юниты 

Стенд для домашнего занятия "systemd systemctl"

Из epel установить spawn-fcgi и переписать init-скрипт на unit-файл. 

Имя сервиса должно также называться.


Устанавливаем spawn-fcgi и необходимые для него пакеты:

[root@nginx ~#] yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -yetc/rc.d/init.d/spawn-fcg - cам Init скрипт, который будем переписыватьНо перед этим необходимо раскомментировать строки с переменными в /etc/sysconfig/spawn-fcgi

Он должен получится следующего вида:

[root@nginx ~#]  cat /etc/sysconfig/spawn-fcgi # You must set some working options before the "spawn-fcgi" service will work.# If SOCKET points to a file, then this file is cleaned up by the init script.## See spawn-fcgi(1) for all possible options.## Example :SOCKET=/var/run/php-fcgi.sockOPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"
А сам юнит файл будет примерно следующего вида:[root@nginx ~#]cat /etc/systemd/system/spawn-fcgi.service[Unit]Description=Spawn-fcgi startup service by OtusAfter=network.target[Service]Type=simplePIDFile=/var/run/spawn-fcgi.pidEnvironmentFile=/etc/sysconfig/spawn-fcgiExecStart=/usr/bin/spawn-fcgi -n $OPTIONSKillMode=process[Install]WantedBy=multi-user.target
Убеждаемся что все успешно работает:[root@nginx ~#]systemctl start spawn-fcgi[root@nginx ~#]systemctl status spawn-fcgi
Дополнить юнит-файл apache httpd возможностью запустить несколько инстансов сервера с разными конфигами
Для запуска нескольких экземпляров сервиса будем использовать шаблон вконфигурации файла окружения:[Unit]Description=The Apache HTTP ServerAfter=network.target remote-fs.target nss-lookup.targetDocumentation=man:httpd(8)Documentation=man:apachectl(8)[Service]Type=notifyEnvironmentFile=/etc/sysconfig/httpd-%Iдобавим параметр %I сюдаExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUNDExecReload=/usr/sbin/httpd $OPTIONS -k gracefulExecStop=/bin/kill -WINCH ${MAINPID}KillSignal=SIGCONTPrivateTmp=true[Install]WantedBy=multi-user.target
В самом файле окружения (которых будет два) задается опция для запускавеб-сервера с необходимым конфигурационным файлом:# /etc/sysconfig/httpd-firstOPTIONS=-f conf/first.conf# /etc/sysconfig/httpd-secondOPTIONS=-f conf/second.confСоответственно в директории с конфигами httpd должны лежать дваконфига, в нашем случае это будут first.conf и second.conf
Для удачного запуска, в конфигурационных файлах должны быть указаныуникальные для каждого экземпляра опции Listen и PidFile. Конфиги можноскопировать и поправить только второй, в нем должны быть след опции:PidFile /var/run/httpd-second.pidListen 8080Этого достаточно для успешного запуска.
Запустим:[root@nginx ~#] systemctl start httpd@first[root@nginx ~#] systemctl start httpd@secondПроверить можно несколькими способами, например посмотреть какиепорты слушаются:[root@nginx ~#] ss -tnulp | grep httpd
