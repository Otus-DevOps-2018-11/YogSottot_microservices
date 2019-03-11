# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= docker/.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# all
all: create-vm build-all run-app

# build all images
build-all:
	eval $$(docker-machine env docker-host) ; docker build --build-arg PROMETHEUS_VERSION=$(PROMETHEUS_VERSION) -t $(USERNAME)/prometheus:$(PROMETHEUS_VERSION) monitoring/prometheus/
	eval $$(docker-machine env docker-host) ; docker build --build-arg BLACKBOX_EXPORTER_VERSION=$(BLACKBOX_EXPORTER_VERSION) -t $(USERNAME)/blackbox-exporter:$(BLACKBOX_EXPORTER_VERSION) monitoring/blackbox_exporter/
	eval $$(docker-machine env docker-host) ; docker build --build-arg MONGO_EXPORTER_VERSION=$(MONGO_EXPORTER_VERSION) -t $(USERNAME)/mongodb_exporter:$(MONGO_EXPORTER_VERSION) monitoring/mongodb_exporter/
	eval $$(docker-machine env docker-host) ; docker build -t $(USERNAME)/comment src/comment/
	eval $$(docker-machine env docker-host) ; docker build -t $(USERNAME)/post src/post-py/
	eval $$(docker-machine env docker-host) ; docker build -t $(USERNAME)/ui src/ui/
	eval $$(docker-machine env docker-host) ; docker build --build-arg ALERTMANAGER_VERSION=$(ALERTMANAGER_VERSION) -t $(USERNAME)/alertmanager:$(ALERTMANAGER_VERSION) monitoring/alertmanager/
	
# build prometheus
build-prometheus:
	eval $$(docker-machine env docker-host) ; docker build --build-arg PROMETHEUS_VERSION=$(PROMETHEUS_VERSION) -t $(USERNAME)/prometheus:$(PROMETHEUS_VERSION) monitoring/prometheus/

# build blackbox-exporter
build-blackbox-exporter:
	eval $$(docker-machine env docker-host) ; docker build --build-arg BLACKBOX_EXPORTER_VERSION=$(BLACKBOX_EXPORTER_VERSION) -t $(USERNAME)/blackbox-exporter:$(BLACKBOX_EXPORTER_VERSION) monitoring/blackbox_exporter/

# build mongodb_exporter
build-mongodb-exporter:
	eval $$(docker-machine env docker-host) ; docker build --build-arg MONGO_EXPORTER_VERSION=$(MONGO_EXPORTER_VERSION) -t $(USERNAME)/mongodb_exporter:$(MONGO_EXPORTER_VERSION) monitoring/mongodb_exporter/

# build reddit-comment
build-reddit-comment:
	eval $$(docker-machine env docker-host) ; docker build -t $(USERNAME)/comment src/comment/

# build reddit-post
build-reddit-post:
	eval $$(docker-machine env docker-host) ; docker build -t $(USERNAME)/post src/post-py/

# build reddit-ui
build-reddit-ui:
	eval $$(docker-machine env docker-host) ; docker build -t $(USERNAME)/ui src/ui/

# build reddit-ui
build-alertmanager:
	eval $$(docker-machine env docker-host) ; docker build --build-arg ALERTMANAGER_VERSION=$(ALERTMANAGER_VERSION) -t $(USERNAME)/alertmanager:$(ALERTMANAGER_VERSION) monitoring/alertmanager/


# push all images
push-all:
	eval $$(docker-machine env docker-host) ; docker login ; docker push $(USERNAME)/ui
	eval $$(docker-machine env docker-host) ; docker login ; docker push $(USERNAME)/comment
	eval $$(docker-machine env docker-host) ; docker login ; docker push $(USERNAME)/post
	eval $$(docker-machine env docker-host) ; docker login ; docker push $(USERNAME)/prometheus:$(PROMETHEUS_VERSION)
	eval $$(docker-machine env docker-host) ; docker login ; docker push $(USERNAME)/mongodb_exporter:$(MONGO_EXPORTER_VERSION)
	eval $$(docker-machine env docker-host) ; docker login ; docker push $(USERNAME)/blackbox-exporter:$(BLACKBOX_EXPORTER_VERSION)
	eval $$(docker-machine env docker-host) ; docker login ; docker push $(USERNAME)/alertmanager:$(ALERTMANAGER_VERSION)

# push ui
push-ui:
	eval $$(docker-machine env docker-host) ; docker login ; docker push $(USERNAME)/ui

# push comment
push-comment:
	eval $$(docker-machine env docker-host) ; docker login ; docker push $(USERNAME)/comment

# push post
push-post:
	eval $$(docker-machine env docker-host) ; docker login ; docker push $(USERNAME)/post

# push prometheus
push-prometheus:
	eval $$(docker-machine env docker-host) ; docker login ; docker push $(USERNAME)/prometheus:$(PROMETHEUS_VERSION)

# push mongodb_exporter
push-mongodb_exporter:
	eval $$(docker-machine env docker-host) ; docker login ; docker push $(USERNAME)/mongodb_exporter:$(MONGO_EXPORTER_VERSION)

# push blackbox-exporter
push-blackbox-exporter:
	eval $$(docker-machine env docker-host) ; docker login ; docker push $(USERNAME)/blackbox-exporter:$(BLACKBOX_EXPORTER_VERSION)

# push alertmanager
push-alertmanager:
	eval $$(docker-machine env docker-host) ; docker login ; docker push $(USERNAME)/alertmanager:$(ALERTMANAGER_VERSION)

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
	eval $$(docker-machine env docker-host) ; cd docker/ ; docker-compose down ; docker-compose up -d
	
# down app
down-app:
	eval $$(docker-machine env docker-host) ; cd docker/ ; docker-compose down

# run monitoring
run-monitoring:
	eval $$(docker-machine env docker-host) ; cd docker/ ; docker-compose -f docker-compose-monitoring.yml down ; docker-compose -f docker-compose-monitoring.yml up -d

# down monitoring
down-monitoring:
	eval $$(docker-machine env docker-host) ; cd docker/ ; docker-compose -f docker-compose-monitoring.yml down

# show env
show-env:
	docker-machine env docker-host
