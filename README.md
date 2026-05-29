### Первичное развертывание

1. Создайте файл в terraform.tfvars и setup_backend/terraform.tfvars заполните переменными окружения.

```
# terraform.tfvars
yc_token       = "<YC_TOKEN>"
cloud_id       = "<CLOUD_ID>"
folder_id      = "<FOLDER_ID>"
ssh_public_key = "<ssh-rsa AAAAB...>"
bucket_name    = "<BUCKET_NAME>"
registry_id    = "<REGISTRY_ID>"
```
```
#setup_backend/terraform.tfvars
cloud_id        = "<CLOUD_ID>"
folder_id       = "<FOLDER_ID>"
bucket_name     = "<BUCKET_NAME>"
token           = "<YC_TOKEN>"
service_account = "<SERVICE_ACCOUNT_NAME>"
```

2. Запустите команду `./manage.py`  ивыберите пункт 1 для первичной установки backend для хранения состояний основного проекта и установки основного проекта.
3. Сохраните json ключ для использования его в github actions. 
```
terraform output -raw yc_sa_json_credentials_raw > key.json
```
4. переходим к развертыванию самого приложения. [text](https://github.com/Swaggasome/tms-graduation-project.git)