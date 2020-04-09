# kk-ast_infra
kk-ast Infra repository

## Git основные команды
```
git init #инициализровать контроль версий
git checkout -b branch_name #создать ветку и переключиться на неё
git log #журнал изменений

git status #состояние контролируемых файлов
git add file_name #добавить файл [-A - все файлы]
git commit -m "comment" #закомитить с комментарием
git push #запушить изменения

#слияние с мастером
git checkout master
git pull origin master
git merge branch_name
git push origin master
```

## Организация доступа
### Управление ключами ssh
- Генерируем ключи пользователя
```bash
ssh-keygen -t rsa -f ~/.ssh/username -C username -P ""
```
- Размещаем публичный ключ в консоли GCE (GCE - Метаданные), либо на машинах (GCE - Экземпляры ВМ - Имя машины - Изменить - SSH-ключи)
### Варианты ssh прокси
- настраиваем конфиг (~/.ssh/config), в этом случае возможно подключение по команде ssh internalhost
```bash
Host internalnet internalhost
ProxyCommand ssh -q external_bastion_ip -W %h:%p
```
- командой
```bash
ssh -J external_ip_bastion host_ip
```

## VPN
bastion_IP = 34.77.173.94
someinternalhost_IP = 10.132.0.3

## testapp
testapp_IP = 34.76.193.54
testapp_port = 9292

## start instance with running app
```
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=app_install.sh
```
## create fw rule from console
```
gcloud compute firewall-rules create puma-app --allow tcp:9292 --target-tags=puma-server --source-ranges=0.0.0.0/0 --description="allow access to puma server"
```

## packer
- Позволяет автоматизировать сборки машин, например, делаем базовый образ с необходимыми конфигурациями, на нём уже разворачиваем полность готовые под каждое приложение
- Все критичные данные должны быть в отдельном файле, который игнорируется git, пример запуска
```
packer build -var-file=variables.json immutable.json
```
- В рамках задания подготовлен базовый образ VM с требуемыми параметрами и предустановленными ruby и mongo, поверх него сделан образ с предустановленным приложением, которое запускается в виде сервиса

## Terraform 1
- В рамках задания был установлен Terraform, настроен запуск сервера с установленным приложением и добавление правила межсетевого экрана открывающего доступ к приложению.
```
terraform init # инициализация и скачивание модулей
terraform plan [-out=path] # показ планируемых изменений [и запись их в файл]
terraform apply [-auto-approve]# применение изменений [автоматическое подтверждение изменений]
terraform show # отобразить измнения
terraform get # загрузка модулей, независимо локально или удалённо
terraform destroy # удаление изменений
```
## Terraform *
- При управлении ключами через Terraform следует учесть, что ключи не описанные в сценарии удаляются, для добавления нескольких ключей - пишем их подряд в значении value

## Terraform 2
- При создании контролируемых ресурсов проверять наличие дефолтных правил, в случае их наличия импортировать, пример:
```
terraform import google_compute_firewall.firewall_ssh default-allow-ssh # импортируем уже существующее правило, которое контролирует доступ по ssh
```
- Для управления разными ресурсами конфигурации лучше разделять их на модули. Для подгрузки модулей используется:
```
terraform get
```
- В рамках ДЗ было сделано
- [x] отдельный модуль для VPC
- [x] настроен разный доступ для промышленной и тестовой сред
- [x] проверена работа реестра модулей, использован storage-bucket от Гугл

## Ansible 1
- В рамках выполнения задачи был установлен Ansible, подготовлен файл конфигурации, инвентаризации статический, в том числе и yaml
- Дополнительно был подготовлен динамический файл (https://www.ansible.com/blog/dynamic-inventory-past-present-future), для этого было проделано следующее:
- установлен google-auth, столкнулся с проблемой: у меня ansible работает на python2, поэтому надо использовать pip2
- сгенерированы ключи для сервисной учётной записи
- в настройках ansible.cfg указал, что для инвентаря используется модуль gcp_compute и ссылка на новый файл инвентаря
- создан файл конфигурации динамического инвентаря, который обязательно должен кончаться на gcp.yml (https://docs.ansible.com/ansible/latest/scenario_guides/guide_gce.html)
