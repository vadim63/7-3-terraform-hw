# Домашнее задание к занятию "Подъем инфраструктуры в облаке" - Качьянов Вадим


### Задание 1

С помощью terraform была поднята инфраструктура из лекции: VPC с двумя подсетями, NAT-шлюз, бастион и 2 веб-сервера. Весь код лежит в репозитории.

1) terraform plan
![terraform plan](img/plan1.1.png)
2) terraform apply
![terraform apply](img/apply1.1.png)
3) Поднятые ВМ в облаке
![VM](img/result1.1.png)



### Задание 2

Для установки nginx на web-a и web-b была написана роль nginx, которую вызывает playbook nginx.yml. Подключение к веб-серверам идёт через бастион.

1) Выполнение playbook
![ansible playbook](img/ansible2.1.png)
2) ВМ в облаке
![VM](img/ansible2.2.png)
3) Проверка nginx с бастиона
![curl](img/ansible2.3.png)



### Задание 3*

Была добавлена ВМ с PostgreSQL, проверка состояния службы сделана через модуль service_facts.

![postgresql](img/ansible3.1.png)



### Задание 4*

Из провайдера убрана авторизация, токен передаётся через переменную окружения YC_TOKEN. Команда для получения токена добавлена в ~/.zshrc, так как у меня zsh.

1) providers.tf
![providers](img/4.1.png)
2) terraform plan с токеном из переменной окружения
![terraform plan](img/4.2.png)
3) ~/.zshrc
![zshrc](img/4.3.png)
