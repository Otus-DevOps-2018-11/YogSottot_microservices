# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= docker/.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# all
all: create-vm build-all run-app run-monitoring

logging: create-vm build-logging run-logging build-app run-app

# build all images
build-all: build-app build-monitoring build-logging

build-app: build-reddit-comment build-reddit-post build-reddit-ui

build-monitoring: build-prometheus build-mongodb-exporter build-alertmanager build-telegraf build-grafana

build-logging: build-fluentd

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

# build alertmanager
build-alertmanager:
	eval $$(docker-machine env docker-host) ; docker build --build-arg ALERTMANAGER_VERSION=$(ALERTMANAGER_VERSION) -t $(USERNAME)/alertmanager:$(ALERTMANAGER_VERSION) monitoring/alertmanager/

# build telegraf
build-telegraf:
	eval $$(docker-machine env docker-host) ; docker build --build-arg TELEGRAF_VERSION=$(TELEGRAF_VERSION) -t $(USERNAME)/telegraf:$(TELEGRAF_VERSION) monitoring/telegraf/

# build grafana
build-grafana:
	eval $$(docker-machine env docker-host) ; docker build --build-arg GRAFANA_VERSION=$(GRAFANA_VERSION) -t $(USERNAME)/grafana:$(GRAFANA_VERSION) monitoring/grafana/

# build autoheal
build-autoheal:
	eval $$(docker-machine env docker-host) ; docker build --build-arg OPENSHIFT_VERSION=$(OPENSHIFT_VERSION) --build-arg AUTOHEAL_VERSION=$(AUTOHEAL_VERSION) -t $(USERNAME)/autoheal:$(AUTOHEAL_VERSION) monitoring/autoheal/

# build fluentd
build-fluentd:
	eval $$(docker-machine env docker-host) ; docker build --build-arg FLUENTD_VERSION=$(FLUENTD_VERSION) -t $(USERNAME)/fluentd:$(FLUENTD_VERSION) logging/fluentd/


# push all images
push-all: push-app push-monitoring push-logging

push-app: push-ui push-comment push-post

push-monitoring: push-prometheus push-mongodb_exporter push-blackbox-exporter push-alertmanager push-telegraf push-grafana

push-logging: push-fluentd

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

# push telegraf
push-telegraf:
	eval $$(docker-machine env docker-host) ; docker login ; docker push $(USERNAME)/telegraf:$(TELEGRAF_VERSION)

# push grafana
push-grafana:
	eval $$(docker-machine env docker-host) ; docker login ; docker push $(USERNAME)/grafana:$(GRAFANA_VERSION)


# push fluentd
push-fluentd:
	eval $$(docker-machine env docker-host) ; docker login ; docker push $(USERNAME)/fluentd:$(FLUENTD_VERSION)

# make vm
create-vm:
	docker-machine create --engine-opt experimental --engine-opt metrics-addr=172.17.0.1:9323 \
	--driver google \
	--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
	--google-machine-type n1-standard-1 \
	--google-zone europe-north1-b \
	--google-scopes "https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring" \
	--google-tags http-server,https-server \
	--google-open-port 3000/tcp \
	--google-open-port 5601/tcp \
	--google-open-port 8080/tcp \
	--google-open-port 9090/tcp \
	--google-open-port 9093/tcp \
	--google-open-port 9115/tcp \
	--google-open-port 9292/tcp \
	--google-open-port 9411/tcp \
	docker-host && \
	docker-machine ssh docker-host "sudo sysctl -w vm.max_map_count=262144"
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

# run logging
run-logging:
	eval $$(docker-machine env docker-host) ; cd docker/ ; docker-compose -f docker-compose-logging.yml down ; docker-compose -f docker-compose-logging.yml up -d

# down monitoring
down-monitoring:
	eval $$(docker-machine env docker-host) ; cd docker/ ; docker-compose -f docker-compose-monitoring.yml down

# show env
show-env:
	docker-machine env docker-host

cluster-run:
	cd kubernetes/terraform && terraform get && terraform init && terraform apply -auto-approve=true

cluster-destroy:
	cd kubernetes/terraform && terraform destroy -auto-approve=true

cluster-get-ip:
	kubectl get ingress -n dev | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
