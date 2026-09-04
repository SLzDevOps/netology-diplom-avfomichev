# Дипломный практикум в Yandex.Cloud - `Фомичев Анатолий`

### Ссылка на дипломное задание - https://github.com/netology-code/devops-diplom-yandexcloud
### Ссылка на репозиторий - https://github.com/SLzDevOps/netology-diplom-avfomichev/tree/main

---

## 📋 О проекте

Данный проект представляет собой дипломную работу по специальности **DevOps-инженер**. В рамках проекта была построена инфраструктура в облаке **Yandex.Cloud** с использованием **Terraform**, развернут **Kubernetes**-кластер, настроена система мониторинга **Prometheus + Grafana**, а также реализован **CI/CD**-пайплайн с использованием **GitHub Actions**.

---

## 🏗️ Архитектура

### Компоненты инфраструктуры:

| Компонент | Описание |
|-----------|----------|
| **Облачная инфраструктура** | Yandex.Cloud (VPC, 2 подсети, 3 ВМ) |
| **IaC** | Terraform + S3 Backend |
| **Kubernetes** | Self-hosted кластер через Kubespray |
| **Мониторинг** | Prometheus + Grafana (kube-prometheus-stack) |
| **CI/CD** | GitHub Actions |
| **Container Registry** | Docker Hub |

### Ресурсы в Yandex.Cloud:

| Имя ВМ | Статус | Публичный IP | Внутренний IP | RAM | vCPU | Диск | Прерываемая |
|--------|--------|--------------|---------------|-----|------|------|-------------|
| avfomichev-kube-master-1 | Running | 51.250.71.128 | 10.0.1.22 | 8 ГБ | 4 | 20 ГБ | Да (20%) |
| avfomichev-kube-worker-1 | Running | 51.250.100.54 | 10.0.2.32 | 4 ГБ | 4 | 20 ГБ | Да (20%) |
| avfomichev-kube-worker-2 | Running | 84.201.160.30 | 10.0.2.10 | 4 ГБ | 4 | 20 ГБ | Да (20%) |

![alt text](https://github.com/SLzDevOps/netology-diplom-avfomichev/blob/main/screenshots/Screenshot_1111.png).

---

## 📁 Структура репозитория
![alt text](https://github.com/SLzDevOps/netology-diplom-avfomichev/blob/main/screenshots/Screenshot_1122.png).

---

## 🚀 Развертывание инфраструктуры

### Создание сервисного аккаунта и S3-бакета
```

cd terraform/service-account-S3
terraform init
terraform apply

Результат:
Сервисный аккаунт: avfomichev-tf-sa
Роль: editor
S3-бакет: avfomichev-tfstate
```

![alt text](https://github.com/SLzDevOps/netology-diplom-avfomichev/blob/main/screenshots/Screenshot_1123.png).

### Развертывание основной инфраструктуры
```
cd terraform/backend
terraform init
terraform apply

Созданы:
VPC: avfomichev-vpc
Подсети: avfomichev-subnet-a (ru-central1-a), avfomichev-subnet-b (ru-central1-b)
3 виртуальные машины (1 мастер + 2 воркера)
2 балансировщика нагрузки
```

![alt text](https://github.com/SLzDevOps/netology-diplom-avfomichev/blob/main/screenshots/Screenshot_1112.png).
![alt text](https://github.com/SLzDevOps/netology-diplom-avfomichev/blob/main/screenshots/Screenshot_1117.png).



## ☸️ Kubernetes кластер
  
### Развертывание выполнено с помощью Kubespray (Ansible).

```
Команда установки:
ansible-playbook -i inventory/mycluster/hosts.yaml \
  -u user \
  --become \
  --become-user=root \
  --private-key=~/.ssh/id_rsa \
  cluster.yml --flush-cache

Результат:
```
![alt text](https://github.com/SLzDevOps/netology-diplom-avfomichev/blob/main/screenshots/Screenshot_1124.png).


## 📊 Мониторинг (Prometheus + Grafana)
  
### Мониторинг развернут с помощью kube-prometheus-stack (Helm-чарт):
  
```
Команда установки:
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  -f k8s-configs/grafana-values.yaml \
  --set grafana.adminPassword=netology
  
Доступ к Grafana:
URL	http://158.160.193.41/
Логин: admin
Пароль: netology
```
  
![alt text](https://github.com/SLzDevOps/netology-diplom-avfomichev/blob/main/screenshots/Screenshot_1114.png).
![alt text](https://github.com/SLzDevOps/netology-diplom-avfomichev/blob/main/screenshots/Screenshot_1113.png).


## 🧪 Тестовое приложение
```
Репозиторий: SLzDevOps/test-application
Docker Hub: slazer/nginx-app

Манифест деплоя:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: avfomichev-test-app
  namespace: test-application
  labels:
    app: avfomichev-web-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: avfomichev-web-app
  template:
    metadata:
      labels:
        app: avfomichev-web-app
    spec:
      containers:
      - name: avfomichev-test-app
        image: slazer/nginx-app:latest
        resources:
          requests:
            cpu: "100m"
            memory: "100Mi"
          limits:
            cpu: "500m"
            memory: "200Mi"
        ports:
        - containerPort: 80

Доступ к приложению:
URL	http://158.160.167.132/
```
![alt text](https://github.com/SLzDevOps/netology-diplom-avfomichev/blob/main/screenshots/Screenshot_1115.png).

  
  
## ⚙️ CI/CD Pipeline

### CI/CD настроен на GitHub Actions для автоматической сборки и деплоя.
```
CI/CD пайплайн реализован с использованием GitHub Actions и состоит из двух основных процессов:
- Автоматическая сборка Docker-образов при изменениях в коде
- Автоматический деплой обновлений в Kubernetes кластер

Файл конфигурации: .github/workflows/ci-cd.yml

name: CI/CD Pipeline

on:
  push:
    branches:
      - main
    paths:
      - 'index.html'
      - 'Dockerfile'
  push:
    tags:
      - 'v*'
  workflow_dispatch:

env:
  REGISTRY: docker.io
  IMAGE_NAME: ${{ secrets.DOCKER_USERNAME }}/nginx-app

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: Log in to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_TOKEN }}

    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: |
          ${{ env.IMAGE_NAME }}:latest
          ${{ env.IMAGE_NAME }}:${{ github.sha }}
          ${{ env.IMAGE_NAME }}:${{ github.ref_name }}

    - name: Install kubectl
      uses: azure/setup-kubectl@v4
      with:
        version: 'latest'

    - name: Set up kubeconfig
      run: |
        mkdir -p $HOME/.kube
        echo "${{ secrets.KUBECONFIG }}" > $HOME/.kube/config

    - name: Update Kubernetes deployment
      run: |
        kubectl set image deployment/avfomichev-test-app \
          avfomichev-test-app=${{ env.IMAGE_NAME }}:${{ github.sha }} \
          -n test-application
        kubectl rollout status deployment/avfomichev-test-app -n test-application
```
  
https://github.com/SLzDevOps/test-application

![alt text](https://github.com/SLzDevOps/netology-diplom-avfomichev/blob/main/screenshots/Screenshot_1116.png).   
  
![alt text](https://github.com/SLzDevOps/netology-diplom-avfomichev/blob/main/screenshots/Screenshot_1126.png). 
  
  
## 🏁 Заключение
```
В рамках дипломной работы была успешно реализована полноценная DevOps-инфраструктура в облаке Yandex.Cloud:

Инфраструктура	Создана VPC с подсетями в двух зонах доступности, развернуты 3 виртуальные машины (1 мастер + 2 воркера) с помощью Terraform
Kubernetes	Self-hosted кластер установлен через Kubespray, все ноды в статусе Ready
Мониторинг	Развернут Prometheus + Grafana, дашборды отображают состояние кластера
Приложение	Тестовое NGINX-приложение упаковано в Docker и развернуто в кластере
CI/CD	Настроен автоматический пайплайн в GitHub Actions: сборка → публикация → деплой
Результат: Все компоненты работают стабильно. Инфраструктура полностью автоматизирована и готова к эксплуатации.
```
  
![alt text](https://github.com/SLzDevOps/netology-diplom-avfomichev/blob/main/screenshots/Screenshot_1128.png). 
  

### Ссылки:
Тестовое приложение	http://158.160.167.132/
  
Grafana	http://158.160.193.41/ (admin/netology)
  
Репозиторий инфраструктуры	https://github.com/SLzDevOps/netology-diplom-avfomichev
  
Репозиторий приложения	https://github.com/SLzDevOps/test-application
  
Docker Hub	https://hub.docker.com/r/slazer/nginx-app


# 🙌🎓🚀 Спасибо за обучение в Нетологии! 🙌🎓🚀
