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

    >docker exec -it reddit bash
    root@d2981256e51c:/# mkdir /test1234
    root@d2981256e51c:/# touch /test1234/testfile
    root@d2981256e51c:/# rmdir /opt
    root@d2981256e51c:/# exit
    exit

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

<details><summary>Сойлер</summary><p>

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
  yogsottot/ui        2.3                 60e670a09925        6 seconds ago        38.6MB
  yogsottot/ui        2.2                 d6df5c580d72        4 seconds ago        208MB
  yogsottot/ui        2.0                 7a08f0564a4b        3 hours ago          398MB
  yogsottot/ui        1.0                 a5d1712293ce        4 hours ago          767MB
  yogsottot/comment   1.6                 a132beb50a01        7 seconds ago        36.2MB
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

- Создан Docker volume: ```docker volume create reddit_db```  
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

</p></details>

## ДЗ №15. Сетевое взаимодействие Docker контейнеров. Docker Compose. Тестирование образов  

<details><summary>Спойлер</summary><p>

### Сетевые драйверы  

#### None network driver  

- Выполнен ```ifconfig``` в контейнере ```joffotron/docker-net-tools```

  <details><summary>Результат</summary><p>

  ```bash

  >docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig
  Unable to find image 'joffotron/docker-net-tools:latest' locally
  latest: Pulling from joffotron/docker-net-tools
  3690ec4760f9: Pull complete
  0905b79e95dc: Pull complete
  Digest: sha256:5752abdc4351a75e9daec681c1a6babfec03b317b273fc56f953592e6218d5b5
  Status: Downloaded newer image for joffotron/docker-net-tools:latest
  lo        Link encap:Local Loopback  
            inet addr:127.0.0.1  Mask:255.0.0.0
            UP LOOPBACK RUNNING  MTU:65536  Metric:1
            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:1000
            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

  ```

  </p></details>

#### Host network driver  

- Выполнен ```ifconfig``` в контейнере ```joffotron/docker-net-tools```

  <details><summary>Результат</summary><p>

  ```bash

  >docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig
  docker0   Link encap:Ethernet  HWaddr 02:42:43:BE:92:1B  
            inet addr:172.17.0.1  Bcast:172.17.255.255  Mask:255.255.0.0
            UP BROADCAST MULTICAST  MTU:1500  Metric:1
            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:0
            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
  
  ens4      Link encap:Ethernet  HWaddr 42:01:0A:A6:00:0F  
            inet addr:10.166.0.15  Bcast:10.166.0.15  Mask:255.255.255.255
            inet6 addr: fe80::4001:aff:fea6:f%32511/64 Scope:Link
            UP BROADCAST RUNNING MULTICAST  MTU:1460  Metric:1
            RX packets:5735 errors:0 dropped:0 overruns:0 frame:0
            TX packets:4861 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:1000
            RX bytes:82716762 (78.8 MiB)  TX bytes:459695 (448.9 KiB)
  
  lo        Link encap:Local Loopback  
            inet addr:127.0.0.1  Mask:255.0.0.0
            inet6 addr: ::1%32511/128 Scope:Host
            UP LOOPBACK RUNNING  MTU:65536  Metric:1
            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:1000
            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

  ```

  </p></details>

- Выполнен ```ifconfig``` непосредственно на хосте. Результаты одинаковы, так как используется сеть хоста.

  <details><summary>Результат</summary><p>

  ```bash

  >docker-machine ssh docker-host ifconfig
  docker0   Link encap:Ethernet  HWaddr 02:42:43:be:92:1b  
            inet addr:172.17.0.1  Bcast:172.17.255.255  Mask:255.255.0.0
            UP BROADCAST MULTICAST  MTU:1500  Metric:1
            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:0 
            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
  
  ens4      Link encap:Ethernet  HWaddr 42:01:0a:a6:00:0f  
            inet addr:10.166.0.15  Bcast:10.166.0.15  Mask:255.255.255.255
            inet6 addr: fe80::4001:aff:fea6:f/64 Scope:Link
            UP BROADCAST RUNNING MULTICAST  MTU:1460  Metric:1
            RX packets:5789 errors:0 dropped:0 overruns:0 frame:0
            TX packets:4912 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:1000 
            RX bytes:82726568 (82.7 MB)  TX bytes:468659 (468.6 KB)
  
  lo        Link encap:Local Loopback  
            inet addr:127.0.0.1  Mask:255.0.0.0
            inet6 addr: ::1/128 Scope:Host
            UP LOOPBACK RUNNING  MTU:65536  Metric:1
            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:1000 
            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)


  ```

  </p></details>

- Запущен несколько раз (2-4) ```docker run --network host -d nginx```. В ```docker ps``` видно, что остался запущен только один контейнер. Это происходит из-за того, что используется один интерфейс и порт уже занят, остальные контейнеры падают с ошибкой.  
- Выполнена команда ```docker-machine ssh docker-host 'sudo ln -s /var/run/docker/netns /var/run/netns'```
- Теперь можно просматривать существующие в данный момент ```net-namespaces``` с помощью команды: ```docker-machine ssh docker-host 'sudo ip netns'```  
- Повторены запуски контейнеров с использованием драйверов ```none``` и ```host``` и просмотрено, как меняется список namespace-ов

  <details><summary>none</summary><p>

  ```bash

  >docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig
  lo        Link encap:Local Loopback  
            inet addr:127.0.0.1  Mask:255.0.0.0
            UP LOOPBACK RUNNING  MTU:65536  Metric:1
            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:1000
            RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

  >docker-machine ssh docker-host 'sudo ip netns'
  RTNETLINK answers: Invalid argument
  RTNETLINK answers: Invalid argument
  82c6b5ac974e
  default

  ```

  </p></details>

  <details><summary>host</summary><p>

  ```bash

  sudo docker run --network host -d nginx ; sudo ip netns
  c9c659c97ac73c81d70abf371b6d75cf207d8d6d83c2fdd967ac4794f1532f2a
  default
  docker-user@docker-host:~$ sudo docker run --network host -d nginx ; sudo ip netns
  9f7130c39ea36eab06456cef23facc0cbb7fe10d7dc37ce4553a8a1f24a19d57
  default
  docker-user@docker-host:~$ sudo docker run --network host -d nginx ; sudo ip netns
  c5ed6a16b5441dd53512d78b3de97b8be5e62a0d05d2ede1087f03d2b6796393
  default
  docker-user@docker-host:~$ sudo docker run --network host -d nginx ; sudo ip netns
  ad9c91b904c668693d6c73fc723f28144d0bd4dc9778ee8bba45b0270bb6fc4f
  default

  ```

  </p></details>

#### Bridge network driver  

- Создана bridge-сеть в docker ```docker network create reddit --driver bridge```
- Созданый образы и запущены контейнеры приложения

  <details><summary>Результат</summary><p>

  ```bash

  >docker run -d --network=reddit mongo:latest
  275bbb836d9441e124db82db384c93c9dc530ee698e896fa84fbb5e6d48512a0
  
  >docker run -d --network=reddit yogsottot/post:1.0
  b12dc50614f532eae9e9557bd3fa7741b0cc690165287d4d7936a12dc0091243
  
  >docker run -d --network=reddit yogsottot/comment:1.0
  326ce4126f0d8557aae2ad8d826ef796e5ad9492b7d746fc0a70ba5a00eabc0d
  
  >docker run -d --network=reddit -p 9292:9292 yogsottot/ui:1.0
  1c87de96124e9e8a2a9e9eec5f79be0070d0144a77893f9744d4306f539fc3ce

  ```

  </p></details>

- Проверено, что приложение функционирует некорректно. Созданы новые контейнеры с присвоением сетевых псевдонимов  

  <details><summary>Результат</summary><p>

  ```bash

  >docker kill $(docker ps -q)
  1c87de96124e
  326ce4126f0d
  b12dc50614f5
  275bbb836d94
  a1bc8daf4eb0
  
  >docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
  2d833cd504d45d8ab6631a2edf1364504b5a34df7c5eea08444f8450359f65cb
  
  >docker run -d --network=reddit --network-alias=post yogsottot/post:1.0
  1794db901b524405f7125da6c03cbda74ad2b50bb5300fc07e9c0321a1a91ca9
  
  >docker run -d --network=reddit --network-alias=comment yogsottot/comment:1.0
  40f52ef941d24d16e73ab33b067c0e96b3efc00689114031d87ca8fc08ee9d08
  
  >docker run -d --network=reddit -p 9292:9292 yogsottot/ui:1.0
  274842f11cd093432235b0f8a20e29223556d5f91d7609ac077a4b944be456fd

  ```

  </p></details>

- Приложение функционирует корректно  
- Запущен проект в 2-х bridge сетях. Так, чтобы сервис ui не имел доступа к базе данных  
  - Созданы docker-сети

    ```bash

    > docker network create back_net --subnet=10.0.2.0/24
    > docker network create front_net --subnet=10.0.1.0/24
  
    ```

  - Запущены контейнеры

    ```bash

    docker run -d --network=front_net -p 9292:9292 --name ui yogsottot/ui:1.0
    docker run -d --network=back_net --name comment yogsottot/comment:1.0
    docker run -d --network=back_net --name post yogsottot/post:1.0
    docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest

    ```

- Убедились, что приложени работает некорректно, так как Docker при инициализации контейнера может подключить к нему только 1
сеть  
- Подключены дополнительные сети для контейнеров post и comment  

  ```bash

  >docker network connect front_net post
  >docker network connect front_net comment

  ```

- Приложение работает корректно  
- Произведена установка пакета bridge-utils на docker-host

  ```bash

  docker-machine ssh docker-host
  sudo apt-get update && sudo apt-get install bridge-utils

  ```

- Выполнена команда ```docker network ls``` и найдены ID сетей, созданных в рамках проекта

  <details><summary>Результат</summary><p>

  ```bash

  sudo docker network ls
  NETWORK ID          NAME                DRIVER              SCOPE
  0736038172aa        back_net            bridge              local
  0e587934b032        bridge              bridge              local
  75f4f9d59467        front_net           bridge              local
  8b2a6e3bd204        host                host                local
  298c0549376b        none                null                local
  77aa870d23be        reddit              bridge              local

  ```

  </p></details>

- Выполнено ```ifconfig | grep br``` и найдены bridge-интерфейсы для каждой из сетей  

  <details><summary>Результат</summary><p>

  ```bash

  ifconfig | grep br
  br-0736038172aa Link encap:Ethernet  HWaddr 02:42:62:72:dd:81  
  br-75f4f9d59467 Link encap:Ethernet  HWaddr 02:42:c1:01:5c:5b  
  br-77aa870d23be Link encap:Ethernet  HWaddr 02:42:21:71:68:ef

  ```

  </p></details>

- Просмотрена информация о каждом интерфейсе

  <details><summary>Результат</summary><p>

  ```bash

  ~$ brctl show br-0736038172aa
  bridge name     bridge id               STP enabled     interfaces
  br-0736038172aa         8000.02426272dd81       no              veth70b6207
                                                          veth74deabe
                                                          vethee70efc
  ~$ brctl show br-75f4f9d59467
  bridge name     bridge id               STP enabled     interfaces
  br-75f4f9d59467         8000.0242c1015c5b       no              veth1a58b06
                                                          veth73dd2ad
                                                          veth9b151d5
  ~$ brctl show br-77aa870d23be
  bridge name     bridge id               STP enabled     interfaces
  br-77aa870d23be         8000.0242217168ef       no

  ```

  </p></details>

- Выполнено ```sudo iptables -nL -t nat```

  <details><summary>Результат</summary><p>

  ```bash

  sudo iptables -v -nL -t nat
  Chain PREROUTING (policy ACCEPT 2138 packets, 127K bytes)
   pkts bytes target     prot opt in     out     source               destination
    115  9826 DOCKER     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL
  
  Chain INPUT (policy ACCEPT 12 packets, 680 bytes)
   pkts bytes target     prot opt in     out     source               destination
  
  Chain OUTPUT (policy ACCEPT 68 packets, 4689 bytes)
   pkts bytes target     prot opt in     out     source               destination
      0     0 DOCKER     all  --  *      *       0.0.0.0/0           !127.0.0.0/8          ADDRTYPE match dst-type LOCAL
  
  Chain POSTROUTING (policy ACCEPT 2012 packets, 121K bytes)
   pkts bytes target     prot opt in     out     source               destination
    180  9270 MASQUERADE  all  --  *      !br-75f4f9d59467  10.0.1.0/24          0.0.0.0/0
      4   218 MASQUERADE  all  --  *      !br-0736038172aa  10.0.2.0/24          0.0.0.0/0
   3659  203K MASQUERADE  all  --  *      !br-77aa870d23be  172.18.0.0/16        0.0.0.0/0
    259 15707 MASQUERADE  all  --  *      !docker0  172.17.0.0/16        0.0.0.0/0
      0     0 MASQUERADE  tcp  --  *      *       10.0.1.2             10.0.1.2             tcp dpt:9292
  
  Chain DOCKER (2 references)
   pkts bytes target     prot opt in     out     source               destination
      0     0 RETURN     all  --  br-75f4f9d59467 *       0.0.0.0/0            0.0.0.0/0
      0     0 RETURN     all  --  br-0736038172aa *       0.0.0.0/0            0.0.0.0/0
      0     0 RETURN     all  --  br-77aa870d23be *       0.0.0.0/0            0.0.0.0/0
      0     0 RETURN     all  --  docker0 *       0.0.0.0/0            0.0.0.0/0
      2   120 DNAT       tcp  --  !br-75f4f9d59467 *       0.0.0.0/0            0.0.0.0/0            tcp dpt:9292 to:10.0.1.2:9292

  ```

  </p></details>

- Выполенено ```ps ax | grep docker-proxy```. Проверено, что docker-proxy слушает порт 9292  

  <details><summary>Результат</summary><p>

  ```bash

  docker-+ 20035  0.0  0.0  12944   940 pts/0    S+   10:42   0:00              \_ grep --color=auto docker-proxy
  root     12987  0.0  0.0   8356  2896 ?        Sl   10:19   0:00  \_ /usr/bin/docker-proxy -proto tcp -host-ip 0.0.0.0 -host-port 9292 -container-ip 10.0.1.2 -container-port 9292


  ```

  </p></details>

### Docker-compose  

- Добавлен файл docker-compose.yml
- Собраны образы и запущены контейнеры с помощью ```docker-compose```. Проверено, что приложение работает.

  <details><summary>Результат</summary><p>

  ```bash

  >export USERNAME=yogsottot
  
  >docker-compose up -d
  Creating network "src_reddit" with the default driver
  Creating volume "src_post_db" with default driver
  Pulling post_db (mongo:3.2)...
  3.2: Pulling from library/mongo
  a92a4af0fb9c: Pull complete
  74a2c7f3849e: Pull complete
  927b52ab29bb: Pull complete
  e941def14025: Pull complete
  be6fce289e32: Pull complete
  f6d82baac946: Pull complete
  7c1a640b9ded: Pull complete
  e8b2fc34c941: Pull complete
  1fd822faa46a: Pull complete
  61ba5f01559c: Pull complete
  db344da27f9a: Pull complete
  Digest: sha256:0463a91d8eff189747348c154507afc7aba045baa40e8d58d8a4c798e71001f3
  Status: Downloaded newer image for mongo:3.2
  Creating src_ui_1      ... done
  Creating src_post_1    ... done
  Creating src_post_db_1 ... done
  Creating src_comment_1 ... done
  
  >docker-compose ps
      Name                  Command             State           Ports
  ----------------------------------------------------------------------------
  src_comment_1   puma                          Up
  src_post_1      python3 post_app.py           Up
  src_post_db_1   docker-entrypoint.sh mongod   Up      27017/tcp
  src_ui_1        puma                          Up      0.0.0.0:9292->9292/tcp

  ```

  </p></details>

#### Задания для самостоятельной работы  

- Изменён ```docker-compose``` под кейс с множеством сетей, сетевых алиасов
- Параметризированы с помощью переменных окружений:
  - порт публикации сервиса ui
  - версии сервисов
- Параметризованные параметры записаны в отдельный файл ```.env```  
- Проверено, что без использования команд ```source``` и ```export``` ```docker-compose``` подхватывает переменные из этого файла  
- Базовое имя проекта, по умолчанию, образуется на основе имени директории из которой производится запуск  
  Способы изменения:
  - запустить ```docker-compose up -d -p new_project_name```  
  - задать в переменной окружения ```COMPOSE_PROJECT_NAME```  

#### Задание со *  

- Создан ```docker-compose.override.yml``` для reddit проекта, который позволяет
  - Изменять код каждого из приложений, не выполняя сборку образа, с помощью монтирования директорий содержащих код в volume. Нужно копировать директории с кодом на docker-host.
  - Запускать puma для руби приложений в дебаг режиме с двумя воркерами (флаги --debug и -w 2), с помощью параметра ```entrypoint```  

    <details><summary>Результат</summary><p>

    ```bash

    >docker-compose ps
         Name                  Command             State           Ports
    -----------------------------------------------------------------------------
    otus_comment_1   puma --debug -w 2             Up
    otus_post_1      python3 post_app.py           Up
    otus_post_db_1   docker-entrypoint.sh mongod   Up      27017/tcp
    otus_ui_1        puma --debug -w 2             Up      0.0.0.0:9292->9292/tcp

    ```

    </p></details>

</p></details>

## ДЗ №16. Устройство Gitlab CI. Построение процесса непрерывной интеграции  

<details><summary>Спойлер</summary><p>

- Создана вм

  <details><summary>Команда для создания</summary><p>

  ```bash

  docker-machine create --driver google \
  --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
  --google-machine-type n1-standard-1 \
  --google-zone europe-north1-b \
  --google-disk-size 60 \
  --google-tags http-server,https-server \
  gitlab

  ```

  </p></details>

- На новом сервере созданы необходимые директории и запущен контейнер gitlab.  

  <details><summary>Команда для создания</summary><p>

  ```bash

  mkdir -p /srv/gitlab/config /srv/gitlab/data /srv/gitlab/logs && \
  cd /srv/gitlab/ && \
  wget https://gist.githubusercontent.com/Nklya/c2ca40a128758e2dc2244beb09caebe1/raw/e9ba646b06a597734f8dfc0789aae79bc43a7242/docker-compose.yml
  # добавить ip вместо <YOUR-VM-IP>
  apt install docker-compose
  docker-compose up -d

  ```

  </p></details>

- Создана группа, проект и загружено содержимое репозиторя microservices  
- Добавлен файл .gitlab-ci.yml  
- Запущен и зарегистрирован gitlab-runner

  <details><summary>Команда для создания</summary><p>

  ```bash

  docker run -d --name gitlab-runner --restart always \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:latest

  ```

  </p></details>

- Добавлен исходный код reddit в репозиторий  

  <details><summary>Процесс</summary><p>

  ```bash

  git clone https://github.com/express42/reddit.git && rm -rf ./reddit/.git
  git add reddit/
  git commit -m "Add reddit app"
  git push gitlab gitlab-ci-1

  ```

  </p></details>

- Добавлены тесты в gitlab-ci  
- Добавлено dev окружение, результат виден в Opeations → Environments  
- Добавлены stage и production окружения  
- Добавлена директива, которая не позволяет выкатить на staging и production код,не помеченный с помощью тэга в git (only: - /^\d+\.\d+\.\d+/)  
- Добавлен job, который определяет динамическое окружение для каждой ветки в репозитории, кроме ветки master

</p></details>

## ДЗ №17. Введение в мониторинг. Модели и принципы работы систем мониторинга  

<details><summary>Спойлер</summary><p>

- Создана новая вм и запущен контейнер prometheus  
- Создана директория monitoring, добавлен dockerfile для создания настроенного образа prometheus, собран образ  
- Добавлена секция запуска prometheus в docker-compose. Созданы образы приложения с помощью docker_build.sh  
- Запущены сервисы с помощью docker-compose  
- Проверно, что указанные в кофнигурации endpoints в состоянии UP  
- Протестировано реагирование графиков на отключение сервисов  
- Добавлен запуск node exporter в docker-compose для сбора информации о хосте  
- Образы загружены в [docker registry](https://hub.docker.com/u/yogsottot)  

### Задание со * №1

- Добавлен в Prometheus мониторинг MongoDB с использованием [percona/mongodb_exporter](https://github.com/percona/mongodb_exporter/). Dockerfile в ```monitoring/mongodb_exporter```. Образ загружен в [docker registry](https://cloud.docker.com/u/yogsottot/repository/docker/yogsottot/mongodb_exporter)  
- Добавлен blackbox exporter для проверки доступности сервисов по http  
  Конфигурация для экспортера загружается на впс с помощью [docker-machine mount](https://docs.docker.com/machine/reference/mount/)

  <details><summary>Процесс</summary><p>

  ```bash
  cd docker
  docker-machine ssh prometheus mkdir blackbox_exporter
  docker-machine mount prometheus:/home/docker-user/blackbox_exporter ../monitoring/blackbox_exporter/mount
  # после завершения тетсов, отмонтировать
  docker-machine mount -u prometheus:/home/docker-user/blackbox_exporter ../monitoring/blackbox_exporter/mount

  ```

  </p></details>

### Задание со * №2

- Создан Makefile, который умеет:
  1. Билдить все образы, которые сейчас используются (blackbox-exporter тоже переведён на использование образа со встроенным конфигом, чтобы не было необходимости монтировать директорию) или любой образ по выбору.
  2. Умеет пушить их все или любой образ в докер хаб
  3. Умеет создавать и удалять вм в gce
  4. Умеет запускать и останавливать приложение

</p></details>

## ДЗ №18. Мониторинг приложения и инфраструктуры  

### Мониторинг Docker контейнеров  

- Запуск мониторинга вынесен в отдельный compose-файл. В makefile внесены нужные изменения.
- Добавлен запуск cAdvisor. Открыт порт для его веб-интерфейса. Проверено, что метрики собираются.

  <details><summary>Процесс</summary><p>

  ```bash
  gcloud compute firewall-rules create cadvisor-default --allow tcp:8080

  ```

  </p></details>

### Визуализация метрик  

- Добавлен запуск Grafana. Открыт порт.  
- Добавлена панель из hub.  

### Сбор метрик приложения  

- Создана панель для метрик приложения.  
- Использована для первого графика (UI http requests) функция rate аналогично второму графику (Rate of UI HTTP Requests with Error)
- Ознакомлен с гистограммами ```ui_request_response_time_bucket{path="/"}```
- Добавлена панель с перцентилем ```histogram_quantile(0.95, sum(rate(ui_request_response_time_bucket[5m])) by (le))```
- Панель экспортирована в файл.  

### Сбор метрик бизнес логики  

- Добавлена и экспортирован панель Business_Logic_Monitoring ```rate(post_count[1h])``` ```rate(comment_count[1h])```

### Алертинг  

- Добавлен alertmanager и конфиги для него.  
  
  <details><summary>Уведомление в slack</summary><p>

  ![alert](https://i.imgur.com/SZKfPBk.png)

  </p></details>

- Образы заружены [docker registry](https://hub.docker.com/u/yogsottot)
  
### Задания со *  

- В Makefile добавлены билд и публикация новых сервисов. (С версионированием)  
- В Docker в [экспериментальном режиме](https://docs.docker.com/config/thirdparty/prometheus/) реализована отдача метрик в формате Prometheus. Добавлен сбор этих метрик в Prometheus.  
  В ```makefile``` для команды ```create-vm``` добавлены параметры для активации данной функции докер-демона ```--engine-opt experimental --engine-opt metrics-addr=172.17.0.1:9323```  
  Добавлена панель [Docker Engine Metrics](https://grafana.com/dashboards/1229)
- Для сбора метрик с Docker демона также можно использовать [Telegraf от InfluxDB](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/docker). Добавлен сбор этих метрик в Prometheus. Добавлена панель ```Telegraf_Docker.json```  
  Внесены изменения в ```docker-compose-monitoring.yml``` и ```prometheus.yml```  
  Добавлен ```dockerfile``` и ```telegraf.conf``` в директорию ```monitoring/telegraf```  
  Внесены записи в ```makefile```  
- Реализован алерт, на 95 процентиль времени ответа UI. Для целей тестирования срабатывания алерта был установлено пороговое значение ```0.0050 sec```. Закоммичено со значением ```0.8 sec```

  <details><summary>Срабатывание</summary><p>

  ![alert](https://i.imgur.com/tKgcpik.png)

  </p></details>

- Настроена интеграция Alertmanager с e-mail помимо слака. Так как в GCE заблокирована возможность отсылать письма напрямую, используется сторонний smtp-сервер. В закомиченном конфиге используются заглушки. Было проведено тестирование с реальными данными.  
  
  <details><summary>Срабатывание</summary><p>

  ![alert](https://i.imgur.com/bsMqi7M.png)

  </p></details>

### Задания со **  

- Реализовано [автоматическое добавление](http://docs.grafana.org/administration/provisioning/) источника данных и созданных в данном ДЗ панелей в графану.  
- Реализован сбор метрик со Stackdriver с помощью встроенного в grafana источника данных.  
  Аутентификация в Stackdriver API происходит автоматически, так как grafana запущена внутри gce. (Должен быть [создан](http://docs.grafana.org/datasources/stackdriver/) GCE Default Service Account). Если используются утилиты gcloud, то он уже создан.  
  В ```makefile``` для создания вм [указано](https://developers.google.com/identity/protocols/googlescopes#monitoringv3) ```--google-scopes "https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring"```  
  Источник и панель добавлены в автопровизионинг.  

### Задания со ***

- Реализована схема с проксированием запросов от Grafana к Prometheus через [Trickster](https://github.com/Comcast/trickster), кеширующий прокси от Comcast. Внесены изменения в ```datasource.yaml``` и ```docker-compose-monitoring.yml```, теперь Trickster будет использоваться по умолчанию.  
