# YogSottot_microservices

YogSottot microservices repository ![Build Status](https://travis-ci.com/Otus-DevOps-2018-11/YogSottot_microservices.svg?branch=master)

## ДЗ №12  

- Установлены Docker, docker-compose, docker-machine  
- Запущен ```docker run hello-world```  
- Запущен ```docker run -it ubuntu:16.04 /bin/bash``` несколько раз с созданием файл в одном из контейнеров  
- Найден старый контейнер ```docker ps -a```
- Подключился к старому контейнеру ```docker start 4c47507d586b && docker attach 4c47507d586b``` 
- Создал образ на основе этого контейнера ```docker commit 4c47507d586b yogsottot/ubuntu-tmp-file```
- Сохранил вывод команды ```docker images``` в файл ```docker-monolith/docker-1.log```  

### Задание со *  

- Сравнил вывод двух следующих команд  
  
  ```bash

  >docker inspect <u_container_id>
  >docker inspect <u_image_id>
  
  ```

- На основе вывода команд выяснил чем отличается контейнер от образа. Объяснение дописано в файл docker-monolith/docker-1.log  
