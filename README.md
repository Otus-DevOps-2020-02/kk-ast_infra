# kk-ast_infra
kk-ast Infra repository

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
Позволяет автоматизировать сборки машин, например, делаем базовый образ с необходимыми конфигурациями, на нём уже разворачиваем полность готовые под каждое приложение
Все критичные данные должны быть в отдельном файле, который игнорируется git, пример запуска
```
packer build -var-file=variables.json immutable.json
```
В рамках задания подготовлен базовый образ VM с требуемыми параметрами и предустановленными ruby и mongo, поверх него сделан образ с предустановленным приложением, которое запускается в виде сервиса

## Terraform
В рамках задания был установлен Terraform, настроен запуск сервера с установленным приложением и добавление правила межсетевого экрана открывающего доступ к приложению.
```
terraform init # инициализация и скачивание модулей
terraform plan # показ планируемых изменений
terraform apply # применение изменений
terraform destroy # удаление изменений

## Terraform *
При управлении ключами через Terraform следует учесть, что ключи не описанные в сценарии удаляются, для добавления нескольких ключей - пишем их подряд в значении value
