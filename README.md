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
