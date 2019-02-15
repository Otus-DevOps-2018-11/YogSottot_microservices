# YogSottot_microservices

YogSottot microservices repository ![Build Status](https://travis-ci.com/Otus-DevOps-2018-11/YogSottot_microservices.svg?branch=master)

## ДЗ №12  

<details><summary>Спойлер</summary><p>

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

</p></details>

## ДЗ №13  

<details><summary>Спойлер</summary><p>

- Создан новый проект в gce ```gcloud projects create docker-231609 --name docker``` и выбран по умолчанию ```gcloud config set project docker-231609```  
- Экспортирована переменная с id проекта ```export GOOGLE_PROJECT=docker-231609```
- Создана впс в gcp с помощью docker-machine

  ```bash

  $ docker-machine create --driver google \
  --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
  --google-machine-type n1-standard-1 \
  --google-zone europe-north1-b \
  docker-host
  
  ```

  <details><summary>Запуск</summary><p>

  ```bash
  Running pre-create checks...
  (docker-host) Check that the project exists
  (docker-host) Check if the instance already exists
  Creating machine...
  (docker-host) Generating SSH Key
  (docker-host) Creating host...
  (docker-host) Opening firewall ports
  (docker-host) Creating instance
  (docker-host) Waiting for Instance
  (docker-host) Uploading SSH Key
  Waiting for machine to be running, this may take a few minutes...
  Detecting operating system of created instance...
  Waiting for SSH to be available...
  Detecting the provisioner...
  Provisioning with ubuntu(systemd)...
  Installing Docker...
  Copying certs to the local machine directory...
  Copying certs to the remote machine...
  Setting Docker configuration on the remote daemon...
  Checking connection to Docker...
  Docker is up and running!
  To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: docker-machine env docker-host

  ```

  ```bash

  docker-machine env docker-host
  export DOCKER_TLS_VERIFY="1"
  export DOCKER_HOST="tcp://35.228.237.45:2376"
  export DOCKER_CERT_PATH="~/.docker/machine/machines/docker-host"
  export DOCKER_MACHINE_NAME="docker-host"
  # Run this command to configure your shell:
  # eval $(docker-machine env docker-host)

  ```

  </p></details>

- Добавлены dockerfile и дополнительные файлы для создания образа  
- Создан образ

  <details><summary>Создание</summary><p>

  ```bash

  docker build -t reddit:latest .
  ...
      Removing intermediate container bb9ca919facb
   ---> 83511ea833a6
  Step 9/10 : RUN chmod 0777 /start.sh
   ---> Running in 701a752398c7
  Removing intermediate container 701a752398c7
   ---> 6467da45c817
  Step 10/10 : CMD ["/start.sh"]
   ---> Running in e35e7764a918
  Removing intermediate container e35e7764a918
   ---> 46b066c0201a
  Successfully built 46b066c0201a
  Successfully tagged reddit:latest

  ```

  ```bash

  > docker images -a
  REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
  <none>              <none>              6467da45c817        3 minutes ago       678MB
  reddit              latest              46b066c0201a        3 minutes ago       678MB
  <none>              <none>              83511ea833a6        3 minutes ago       678MB
  <none>              <none>              fb427dbce449        3 minutes ago       639MB
  <none>              <none>              b2b1cf19a8e9        3 minutes ago       639MB
  <none>              <none>              1eeb04537b82        3 minutes ago       639MB
  <none>              <none>              c9f32f0bc094        3 minutes ago       639MB
  <none>              <none>              8cb982c3c72f        3 minutes ago       638MB
  <none>              <none>              45c5c48188b6        4 minutes ago       636MB
  ubuntu              16.04               7e87e2b3bf7a        3 weeks ago         117MB

  ```

  </p></details>

- Запущен контейнер ```docker run --name reddit -d --network=host reddit:latest```  
- Разрешён входящий TCP-трафик на порт 9292

  ```bash

  $ gcloud compute firewall-rules create reddit-app \
  --allow tcp:9292 \
  --target-tags=docker-machine \
  --description="Allow PUMA connections" \
  --direction=INGRESS

  ```

- Проверено, что приложение стало доступным  
- Аутентифицирован на docker hub с хранением секрета через [```docker-credential-pass```](https://github.com/docker/docker-credential-helpers/issues/102#issuecomment-388974092)  
- Образ помечен тегом ```docker tag reddit:latest yogsottot/otus-reddit:1.0```  
- Образ загружен в docker.hub ```docker push yogsottot/otus-reddit:1.0```  
- Загруженный контейнер запущен локально ```docker run --name reddit -d -p 9292:9292 yogsottot/otus-reddit:1.0```  

- C помощью следующих команд:
  - изучены логи контейнера ```docker logs reddit -f```

    <details><summary>Логи контейнера</summary><p>

    ```bash
  
    >docker logs reddit -f
    about to fork child process, waiting until server is ready for connections.
    forked process: 9
    ERROR: child process failed, exited with error number 100
    Puma starting in single mode...
    * Version 3.10.0 (ruby 2.3.1-p112), codename: Russell's Teapot
    * Min threads: 0, max threads: 16
    * Environment: development
    /reddit/helpers.rb:4: warning: redefining `object_id' may cause serious problems
    D, [2019-02-13T11:38:16.872960 #14] DEBUG -- : MONGODB | Topology type 'unknown' initializing.
    D, [2019-02-13T11:38:16.873074 #14] DEBUG -- : MONGODB | Server 127.0.0.1:27017 initializing.
    D, [2019-02-13T11:56:02.170351 #13] DEBUG -- : MONGODB | Connection refused - connect(2) for 127.0.0.1:27017
    * Listening on tcp://0.0.0.0:9292
    Use Ctrl-C to stop

    ```

    </p></details>

  - зашёл в выполняемый контейнер ```docker exec -it reddit bash```
  - посмотрел список процессов  ```ps auxf```

    <details><summary>Процессы контейнера</summary><p>

    ```bash

    root@e88d520c0836:/# ps auxf
    USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    root       174  0.0  0.0  18236  3316 pts/0    Ss   11:59   0:00 bash
    root       234  0.0  0.0  34424  2960 pts/0    R+   12:00   0:00  \_ ps auxf
    root         1  0.0  0.0  18032  2772 ?        Ss   11:56   0:00 bash /start.sh
    root        13  0.2  0.4 651060 32428 ?        Sl   11:56   0:00 puma 3.10.0 (tcp://0.0.0.0:9292) [reddit]

    ```

    </p></details>

  - при просмотре логов была выявлена проблема с запуском mongodb

    <details><summary>Логи mongodb</summary><p>

    ```bash

    ERROR: Insufficient free space for journal files
    [initandlisten] Please make at least 3379MB available in /var/lib/mongodb/journal or use --smallfiles
  
    ```

    </p></details>

    Проблема решена путём внесения изменений в конфиг ```mongod.conf```, а также исправлением опечатки в ```start.sh```  
    Был создан исправленный образ yogsottot/otus-reddit:1.02
    Удалил старый контейнер и запустил новый ```docker run --name reddit -d -p 9292:9292 yogsottot/otus-reddit:1.02```

    <details><summary>Изменения</summary><p>

    ```bash
    cat /etc/mongod.conf

    storage:
        smallFiles: true

    ```

    ```bash

    cat start.sh
    --config /etc/mongod.conf вместо /etc/mongodb.conf

    ```

    </p></details>

  - вызвал остановку контейнера ```killall5 1```
  - запустил его повторно ```docker start reddit```, убедился, что приложение работает корректно  
  - остановил и удалил ```docker stop reddit && docker rm reddit```
  - запустил контейнер без запуска приложения и посмотрел процессы ```docker run --name reddit --rm -it yogsottot/otus-reddit:1.02 bash```

    <details><summary>Без запуска приложения</summary><p>

    ```bash

    >docker run --name reddit --rm -it yogsottot/otus-reddit:1.02 bash
    root@f0fa490388bd:/# ps auxf
    USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    root         1  0.6  0.0  18236  3220 pts/0    Ss   14:09   0:00 bash
    root        15  0.0  0.0  34424  2844 pts/0    R+   14:09   0:00 ps auxf
    root@f0fa490388bd:/# exit

    ```

    </p></details>

  - посмотрел подробную информацию об образе ```docker inspect yogsottot/otus-reddit:1.02```

    <details><summary>Информация об образе</summary><p>

    ```bash

    >docker inspect yogsottot/otus-reddit:1.02
    [
        {
            "Id": "sha256:7c4894d7591c103ddae2383800ca942bf2e3fd476c83ec2e60d9361c938c2686",
            "RepoTags": [
                "yogsottot/otus-reddit:1.02"
            ],
            "RepoDigests": [
                "yogsottot/otus-reddit@sha256:4b20de2c1144e38a4ebf161b71ded27daa82448e9868d39eea511b17f1914e6f"
            ],
            "Parent": "",
            "Comment": "",
            "Created": "2019-02-13T13:03:36.805788752Z",
            "Container": "2faf0287353c17766520c61a47729bd4d5bfdd0efeffddb67bcb9bada2a530f1",
            "ContainerConfig": {
                "Hostname": "2faf0287353c",
                "Domainname": "",
                "User": "",
                "AttachStdin": false,
                "AttachStdout": false,
                "AttachStderr": false,
                "Tty": false,
                "OpenStdin": false,
                "StdinOnce": false,
                "Env": [
                    "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
                ],
                "Cmd": [
                    "/bin/sh",
                    "-c",
                    "#(nop) ",
                    "CMD [\"/start.sh\"]"
                ],
                "ArgsEscaped": true,
                "Image": "sha256:add263cec92cd867829f5886de5b9b67ac47bec21869575dd39d487a970bfa5d",
                "Volumes": null,
                "WorkingDir": "",
                "Entrypoint": null,
                "OnBuild": null,
                "Labels": {}
            },
            "DockerVersion": "18.09.2",
            "Author": "",
            "Config": {
                "Hostname": "",
                "Domainname": "",
                "User": "",
                "AttachStdin": false,
                "AttachStdout": false,
                "AttachStderr": false,
                "Tty": false,
                "OpenStdin": false,
                "StdinOnce": false,
                "Env": [
                    "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
                ],
                "Cmd": [
                    "/start.sh"
                ],
                "ArgsEscaped": true,
                "Image": "sha256:add263cec92cd867829f5886de5b9b67ac47bec21869575dd39d487a970bfa5d",
                "Volumes": null,
                "WorkingDir": "",
                "Entrypoint": null,
                "OnBuild": null,
                "Labels": null
            },
            "Architecture": "amd64",
            "Os": "linux",
            "Size": 678186931,
            "VirtualSize": 678186931,
            "GraphDriver": {
                "Data": {
                    "LowerDir": "/var/lib/docker/overlay2/075c4eb4b1d86e01be73c46c5bda1691933a9f2d4e8e34934cea2504e5e0c5e8/diff:/var/lib/docker/overlay2/d09c0bd543b4394806759ee13751279545a07f741cc9f72d0f5e14aa440e435a/diff:/var/lib/docker/overlay2/d79588ff9afdef1cd931329adb21f1857831e0e719e6ad5d93722e9ca6155896/diff:/var/lib/docker/overlay2/dc714f7b9be2e07e502a63fe948d1bbfb48aa81d8e5186c4cf06e5f458429b6e/diff:/var/lib/docker/overlay2/071db8621e40b6b79817e090de8c546eb726540a31d44e96b693ad014ab0635a/diff:/var/lib/docker/overlay2/2afd26f1614689031ad1f1b1d663789d288344c57b824812a916ec7982c407ff/diff:/var/lib/docker/overlay2/e30dbb3415a8a704609596e465bff304bf65d55ad8321be8a823c1c52a41695b/diff:/var/lib/docker/overlay2/d23eee8a190cff4ce21abf6aeb8ddc298378b8a5eeb2a408d2af5b5c65c8dede/diff:/var/lib/docker/overlay2/af577f34abcd2995c0c90e63da250b75cc5e860bd6cc5c406cf3e8b16d989f2d/diff:/var/lib/docker/overlay2/a1b5dbb6f13937fe6a5981c060ea5be1abbff2345323ec0431b392a54563ccf2/diff:/var/lib/docker/overlay2/95fb9d6f751847de59e731c3aa30ffe9a4cf41d92c6fa5d63b3c54cc4dfe930a/diff",
                    "MergedDir": "/var/lib/docker/overlay2/d2bfd45def40d502a69561472a1a635cd6b069af7a1646e9f74284fe82171870/merged",
                    "UpperDir": "/var/lib/docker/overlay2/d2bfd45def40d502a69561472a1a635cd6b069af7a1646e9f74284fe82171870/diff",
                    "WorkDir": "/var/lib/docker/overlay2/d2bfd45def40d502a69561472a1a635cd6b069af7a1646e9f74284fe82171870/work"
                },
                "Name": "overlay2"
            },
            "RootFS": {
                "Type": "layers",
                "Layers": [
                    "sha256:0de2edf7bff41238438e25b6f2de055b97c7fb6fe095cd560c2095b8dd70fc99",
                    "sha256:b2fd8b4c3da7e720f748179985ff20f537d504a9f4b0df09ac7611b390addab8",
                    "sha256:f67191ae09b8f583063c9f2e369ce3743a4f4eca91e2f7c4c3e4f5a7fba6b24a",
                    "sha256:68dda0c9a8cd82911fa164ad1461ded7901784ddc4f221c3bd0ae6acbea7ad36",
                    "sha256:24f80a2c71e08dd40ec4cbdffffdc5f406fcc9d51c830059097eefeff554674c",
                    "sha256:2840ac005625268ba87ebd14686c1d9411a9a9facfa79ed7b63d629b419382f2",
                    "sha256:9eb6337a262e08b183c3c53b08f1d0f7fe30c87fc3d731e864abdb7c645b037e",
                    "sha256:5b4c71b573d0ebe0230d450af565f08991612273a8538af0deae06cf95354f39",
                    "sha256:113f3a69854f4cff82457e4612564c72cb3b80bd2759034e1a63e6b1d14b12ca",
                    "sha256:10eaa0370604cc74429c7043eeb91d98e9d39389e1f84c29169c6d28ed12f7d5",
                    "sha256:212ea33e1c32c571e618bd409bc8ddb78078221e563780b364fce2983e31a711",
                    "sha256:7ab07c89835047f072949816054c1c685bec9f0e2154e4c50ae4c2c2f997c90d"
                ]
            },
            "Metadata": {
                "LastTagTime": "0001-01-01T00:00:00Z"
            }
        }
    ]

    ```

    </p></details>

  - вывел только определенный фрагмент информации ```docker inspect yogsottot/otus-reddit:1.02 -f '{{.ContainerConfig.Cmd}}'```

    <details><summary>Проверка</summary><p>

    ```bash

    >docker inspect yogsottot/otus-reddit:1.02 -f '{{.ContainerConfig.Cmd}}'
    [/bin/sh -c #(nop)  CMD ["/start.sh"]]

    ```

    </p></details>

  - запустил приложение и добавил/удалил папки и посмотрел дифф,
  
    <details><summary>Проверка</summary><p>

    ```bash

    >docker run --name reddit -d -p 9292:9292 yogsottot/otus-reddit:1.02
    d2981256e51c6b2dd96c768013c7b2c7d81b97bcc2a6cf1ba5e150c49b7ecc12
    [neko:~/IdeaProjects] $
    >docker exec -it reddit bash
    root@d2981256e51c:/# mkdir /test1234
    root@d2981256e51c:/# touch /test1234/testfile
    root@d2981256e51c:/# rmdir /opt
    root@d2981256e51c:/# exit
    exit
    [neko:~/IdeaProjects] 19s $
    >docker diff reddit
    C /var
    C /var/lib
    C /var/lib/mongodb
    A /var/lib/mongodb/_tmp
    A /var/lib/mongodb/journal
    A /var/lib/mongodb/journal/j._0
    A /var/lib/mongodb/journal/prealloc.1
    A /var/lib/mongodb/journal/prealloc.2
    A /var/lib/mongodb/local.0
    A /var/lib/mongodb/local.ns
    A /var/lib/mongodb/mongod.lock
    C /var/log
    C /var/log/mongodb
    A /var/log/mongodb/mongod.log
    C /root
    A /root/.bash_history
    A /test1234
    A /test1234/testfile
    C /tmp
    A /tmp/mongodb-27017.sock
    D /opt

    ```

    </p></details>

  - проверил что после остановки и удаления контейнера никаких изменений не останется:

    <details><summary>Проверка</summary><p>

    ```bash

    >docker stop reddit && docker rm reddit
    reddit
    reddit
    [neko:~/IdeaProjects] 11s $
    >docker run --name reddit --rm -it yogsottot/otus-reddit:1.02 bash
    root@0baad30581f4:/# ls /
    bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  reddit  root  run  sbin  srv  start.sh  sys  tmp  usr  var

    ```

    </p></details>

### Задание со *  

- Настроено поднятие инстансов с помощью Terraform, их количество задается переменной ```count_app```  
  ```cd terraform/stage && terraform get && terraform init && terraform apply -auto-approve=true```  
- Добавлено несколько плейбуков Ansible (```site_dynamic.yml```, ```docker_dynamic.yml```, ```deploy_dynamic.yml```) с использованием динамического инвентори для установки докера и запуска там образа приложения. Используется скрипт ```gce_googleapiclient.py```. Отличается от ```gce.py``` тем, что использует для авторизации тот же механизм, что и утилиты gcloud. Нет необходимости скачивать service_account.json
- Добавлен шаблон пакера, который делает образ с уже установленным Docker с помощью плейбука ```packer_docker.yml```  
  ```packer.io build -var-file=docker-monolith/infra/packer/variables.json docker-monolith/infra/packer/docker.json``` 
 
  <details><summary>Создание образа</summary><p>

  ```bash

  >packer.io validate -var-file=docker-monolith/infra/packer/variables.json docker-monolith/infra/packer/docker.json
  Template validated successfully.
  [neko:~/IdeaProjects/YogSottot_microservices] $
  >packer.io build -var-file=docker-monolith/infra/packer/variables.json docker-monolith/infra/packer/docker.json
  googlecompute output will be in this color.
  
  ==> googlecompute: Checking image does not exist...
  ==> googlecompute: Creating temporary SSH key for instance...
  ==> googlecompute: Using image: ubuntu-1604-xenial-v20190212
  ==> googlecompute: Creating instance...
      googlecompute: Loading zone: europe-north1-b
      googlecompute: Loading machine type: f1-micro
      googlecompute: Requesting instance creation...
      googlecompute: Waiting for creation operation to complete...
      googlecompute: Instance has been created!
  ==> googlecompute: Waiting for the instance to become running...
      googlecompute: IP: 35.228.178.92
  ==> googlecompute: Using ssh communicator to connect: 35.228.178.92
  ==> googlecompute: Waiting for SSH to become available...
  ==> googlecompute: Connected to SSH!
  ==> googlecompute: Provisioning with Ansible...
  ==> googlecompute: Executing Ansible: ansible-playbook --extra-vars packer_build_name=googlecompute packer_builder_type=googlecompute -i /tmp/packer-provisioner-ansible167512139 ~/YogSottot_microservices/docker-monolith/infra/ansible/playbooks/packer_docker.yml -e ansible_ssh_private_key_file=/tmp/ansible-key903690140
      googlecompute:
      googlecompute: PLAY [Configure App] ***********************************************************
      googlecompute:
      googlecompute: TASK [Gathering Facts] *********************************************************
      googlecompute: ok: [default]
      googlecompute:
      googlecompute: TASK [geerlingguy.docker : include_tasks] **************************************
      googlecompute: skipping: [default]
      googlecompute:
      googlecompute: TASK [geerlingguy.docker : include_tasks] **************************************
      googlecompute: included: ~/YogSottot_microservices/docker-monolith/infra/ansible/roles/geerlingguy.docker/tasks/setup-Debian.yml for default
      googlecompute:
      googlecompute: TASK [geerlingguy.docker : Ensure old versions of Docker are not installed.] ***
      googlecompute: ok: [default]
      googlecompute:
      googlecompute: TASK [geerlingguy.docker : Ensure dependencies are installed.] *****************
      googlecompute: ok: [default]
      googlecompute:
      googlecompute: TASK [geerlingguy.docker : Add Docker apt key.] ********************************
      googlecompute: changed: [default]
      googlecompute:
      googlecompute: TASK [geerlingguy.docker : Ensure curl is present (on older systems without SNI).] ***
      googlecompute: skipping: [default]
      googlecompute:
      googlecompute: TASK [geerlingguy.docker : Add Docker apt key (alternative for older systems without SNI).] ***
      googlecompute: skipping: [default]
      googlecompute:
      googlecompute: TASK [geerlingguy.docker : Add Docker repository.] *****************************
      googlecompute: changed: [default]
      googlecompute:
      googlecompute: TASK [geerlingguy.docker : Install Docker.] ************************************
      googlecompute: changed: [default]
      googlecompute:
      googlecompute: TASK [geerlingguy.docker : Ensure containerd service dir exists.] **************
      googlecompute: changed: [default]
      googlecompute:
      googlecompute: TASK [geerlingguy.docker : Add shim to ensure Docker can start in all environments.] ***
      googlecompute: changed: [default]
      googlecompute:
      googlecompute: TASK [geerlingguy.docker : Reload systemd daemon if template is changed.] ******
      googlecompute: ok: [default]
      googlecompute:
      googlecompute: TASK [geerlingguy.docker : Ensure Docker is started and enabled at boot.] ******
      googlecompute: ok: [default]
      googlecompute:
      googlecompute: RUNNING HANDLER [geerlingguy.docker : restart docker] **************************
      googlecompute: changed: [default]
      googlecompute:
      googlecompute: TASK [geerlingguy.docker : include_tasks] **************************************
      googlecompute: skipping: [default]
      googlecompute:
      googlecompute: TASK [geerlingguy.docker : include_tasks] **************************************
      googlecompute: skipping: [default]
      googlecompute:
      googlecompute: PLAY RECAP *********************************************************************
      googlecompute: default                    : ok=12   changed=6    unreachable=0    failed=0
      googlecompute:
  ==> googlecompute: Deleting instance...
      googlecompute: Instance has been deleted!
  ==> googlecompute: Creating image...
  ==> googlecompute: Deleting disk...
      googlecompute: Disk has been deleted!
  Build 'googlecompute' finished.
  
  ==> Builds finished. The artifacts of successful builds are:
  --> googlecompute: A disk image was created: reddit-docker-1550134658

  ```

  </p></details>

</p></details>

## ДЗ №14. Docker образы. Микросервисы  

- Скачан архив reddit-microservices и добавлены докерфайлы. Учтены замечания hadolint.
- Запущена сборка контейнеров.  
  ```docker build -t yogsottot/post:1.0 ./post-py```  

  <details><summary>сборка</summary><p>

  ```bash

   unable to execute 'gcc': No such file or directory
   error: command 'gcc' failed with exit status 1

  ```

  Добавил установку gcc в dockerfile

  ```bash

  Successfully built 8d1048ab658c
  Successfully tagged yogsottot/post:1.0

  ```

  </p></details>

  ```docker build -t yogsottot/comment:1.0 ./comment```  
  ```docker build -t yogsottot/ui:1.0 ./ui```  

- Создадна специальная сеть для приложения ```docker network create reddit```  
- Запущены контейнеры  
  
  <details><summary>Команды запуска</summary><p>

  ```bash

  docker run -d --network=reddit \
  --network-alias=post_db --network-alias=comment_db mongo:latest
  docker run -d --network=reddit \
  --network-alias=post yogsottot/post:1.0
  docker run -d --network=reddit \
  --network-alias=comment yogsottot/comment:1.0
  docker run -d --network=reddit \
  -p 9292:9292 yogsottot/ui:1.0

  ```

  </p></details>

- Проверена работа приложения  

  <details><summary>Тест</summary><p>

  ![reddit](https://i.imgur.com/EJGFtbF.png)

  </p></details>

### Задание со ⭐  

- Остановлены контейнеры: ```docker kill $(docker ps -q)```
- Запущены контейнеры с другими сетевыми алиасами
- При запуске контейнеров (docker run) заданы переменные окружения соответствующие новым сетевым
алиасам, не пересоздавая образ  
  
  <details><summary>Запуск</summary><p>

  ```bash

  docker run -d --network=reddit \
  --network-alias=post_db_test1 --network-alias=comment_db_test1 mongo:latest
  docker run -d --env "POST_DATABASE_HOST=post_db_test1" --network=reddit \
  --network-alias=post_test1 yogsottot/post:1.0
  docker run -d --env "COMMENT_DATABASE_HOST=comment_db_test1" --network=reddit \
  --network-alias=comment_test1 yogsottot/comment:1.0
  docker run -d --env "POST_SERVICE_HOST=post_test1" --env "COMMENT_SERVICE_HOST=comment_test1" --network=reddit \
  -p 9292:9292 yogsottot/ui:1.0

  ```

  </p></details>

- Проверена работоспособность сервиса  

  <details><summary>Тест</summary><p>

  ![reddit](https://i.imgur.com/343Kvi9.png)

  </p></details>

### Уменьшение образов  

- Проверен текущий размер ```docker images```

  <details><summary>размеры</summary><p>

    ```bash

    >docker images
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    yogsottot/ui        1.0                 a5d1712293ce        About an hour ago   767MB
    yogsottot/comment   1.0                 6f09813109a0        About an hour ago   765MB
    yogsottot/post      1.0                 8d1048ab658c        About an hour ago   198MB
    <none>              <none>              72aba88ff33d        About an hour ago   88.6MB
    <none>              <none>              4d85cb9b8aeb        About an hour ago   257MB
    <none>              <none>              f13ada26a87e        About an hour ago   257MB
    <none>              <none>              745ef9e135eb        About an hour ago   88.6MB
    <none>              <none>              a58bdd4d0f43        2 hours ago         88.6MB
    mongo               latest              0da05d84b1fe        9 days ago          394MB
    ruby                2.2                 6c8e6f9667b2        9 months ago        715MB
    python              3.6.0-alpine        cb178ebbf0f2        23 months ago       88.6MB

    ```

    </p></details>

- Изменён и собран новый образ ui ```docker build -t yogsottot/ui:2.0 ./ui```

  <details><summary>новый размер</summary><p>

  ```bash

  >docker images
  REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
  yogsottot/ui        2.0                 7a08f0564a4b        3 seconds ago       398MB
  yogsottot/ui        1.0                 a5d1712293ce        About an hour ago   767MB
  yogsottot/comment   1.0                 6f09813109a0        About an hour ago   765MB
  yogsottot/post      1.0                 8d1048ab658c        About an hour ago   198MB
  <none>              <none>              72aba88ff33d        About an hour ago   88.6MB
  <none>              <none>              4d85cb9b8aeb        2 hours ago         257MB
  <none>              <none>              f13ada26a87e        2 hours ago         257MB
  <none>              <none>              745ef9e135eb        2 hours ago         88.6MB
  <none>              <none>              a58bdd4d0f43        2 hours ago         88.6MB
  mongo               latest              0da05d84b1fe        9 days ago          394MB
  ubuntu              16.04               7e87e2b3bf7a        3 weeks ago         117MB
  ruby                2.2                 6c8e6f9667b2        9 months ago        715MB
  python              3.6.0-alpine        cb178ebbf0f2        23 months ago       88.6MB

  ```

  </p></details>

#### Задания со ⭐  

- Собраны образы ui-2.3 / comment-1.6 на основе Alpine Linux  

  <details><summary>новый размер</summary><p>

  ```bash

  >docker images
  yogsottot/ui        2.3                 60e670a09925        6 seconds ago        42MB
  yogsottot/ui        2.2                 d6df5c580d72        4 seconds ago        208MB
  yogsottot/ui        2.0                 7a08f0564a4b        3 hours ago          398MB
  yogsottot/ui        1.0                 a5d1712293ce        4 hours ago          767MB
  yogsottot/comment   1.6                 a132beb50a01        7 seconds ago        39.5MB
  yogsottot/comment   1.5                 6cc1d265f29b        6 minutes ago        206MB
  yogsottot/comment   1.0                 6f09813109a0        4 hours ago          765MB
  
  ```

  </p></details>

- Добавлены файлы .dockerignore  
- Добавил удаление pip cache ```rm -r /root/.cache``` в ```post-py``` и удаление сборочных зависимостей (gcc musl). Снижен размер образа на 92 Мб.
  
  <details><summary>новый размер /post</summary><p>

  ```bash

  >docker images
  yogsottot/post      1.5                 e58d479f8fdd        About a minute ago  106MB
  yogsottot/post      1.0                 8d1048ab658c        3 hours ago         198MB

  ```

  </p></details>

### Работа с volume  

- Создадан Docker volume: ```docker volume create reddit_db```  
- Подключен к контейнеру с MongoDB  ```-v reddit_db:/data/db```  
- Запущено приложение, создано сообщение.

  <details><summary>Команды запуска</summary><p>

  ```bash

  docker run -d --network=reddit \
  --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
  docker run -d --network=reddit \
  --network-alias=post yogsottot/post:1.5
  docker run -d --network=reddit \
  --network-alias=comment yogsottot/comment:1.6
  docker run -d --network=reddit \
  -p 9292:9292 yogsottot/ui:2.3

  ```

  </p></details>

- Перезапущено приложение. Проверено что сообщение осталось на месте.  
  
  <details><summary>Тест</summary><p>

  ![reddit](https://i.imgur.com/TxbhKE9.png)

  </p></details>
