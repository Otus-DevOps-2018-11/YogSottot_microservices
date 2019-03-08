# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= docker/.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# all
all: create-vm build-all run-app

# build all images
build-all:
	docker build -t $(USER_NAME)/prometheus monitoring/prometheus/
	docker build -t $(USER_NAME)/blackbox-exporter:$(BLACKBOX_EXPORTER_VERSION) monitoring/blackbox_exporter/
	docker build -t $(USERNAME)/mongodb_exporter:$(MONGO_EXPORTER_VERSION) monitoring/mongodb_exporter/
	docker build -t $(USERNAME)/comment src/comment/
	docker build -t $(USERNAME)/post src/post-py/
	docker build -t $(USERNAME)/ui src/ui/
	
# build prometheus
build-prometheus:
	docker build -t $(USER_NAME)/prometheus monitoring/prometheus/

# build blackbox-exporter
build-blackbox-exporter:
	docker build -t $(USER_NAME)/blackbox-exporter:$(BLACKBOX_EXPORTER_VERSION) monitoring/blackbox_exporter/

# build mongodb_exporter
build-mongodb-exporter:
	docker build -t $(USERNAME)/mongodb_exporter:$(MONGO_EXPORTER_VERSION) monitoring/mongodb_exporter/

# build reddit-comment
build-reddit-comment:
	docker build -t $(USERNAME)/comment src/comment/

# build reddit-post
build-reddit-post:
	docker build -t $(USERNAME)/post src/post-py/

# build reddit-ui
build-reddit-ui:
	docker build -t $(USERNAME)/ui src/ui/

# push all images
push-all:
	docker login
	docker push $(USER_NAME)/ui
	docker push $(USER_NAME)/comment
	docker push $(USER_NAME)/post
	docker push $(USER_NAME)/prometheus
	docker push $(USER_NAME)/mongodb_exporter:$(MONGO_EXPORTER_VERSION)
	docker push $(USER_NAME)/blackbox-exporter:$(BLACKBOX_EXPORTER_VERSION)

# push ui
push-ui:
	docker login
	docker push $(USER_NAME)/ui

# push comment
push-comment:
	docker login
	docker push $(USER_NAME)/comment

# push post
push-post:
	docker login
	docker push $(USER_NAME)/post

# push prometheus
push-prometheus:
	docker login
	docker push $(USER_NAME)/prometheus

# push mongodb_exporter
push-mongodb_exporter:
	docker login
	docker push $(USER_NAME)/mongodb_exporter:$(MONGO_EXPORTER_VERSION)

# push blackbox-exporter
push-blackbox-exporter:
	docker login
	docker push $(USER_NAME)/blackbox-exporter:$(BLACKBOX_EXPORTER_VERSION)

# make vm
create-vm:
	docker-machine create --driver google \
	--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
	--google-machine-type n1-standard-1 \
	--google-zone europe-north1-b \
	docker-host
	eval $$(docker-machine env docker-host)
	
# destroy vm
destroy-vm:
	eval $$(docker-machine env --unset)
	docker-machine rm docker-host -f

# run app
run-app:
	cd docker/ ; docker-compose down
	cd docker/ ; docker-compose up -d
	
# down app
down-app:
	cd docker/ ; docker-compose down

# show env
show-env:
	docker-machine env docker-host
