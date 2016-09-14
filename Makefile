PROJECT_NAME=rcja_robo
DOCKER_NAMESPACE=rcja_robo
SERVICES=consul logstash rethinkdb redis
JSLINT_ARGS=--node --nomen --indent=2
JS_FILES=app.js lib/*/*.js
ROOT := $(shell pwd)
PRODUCTION_CONTAINER_NAME=robocup

DOCKERRUN := docker run -it --rm \
	-v ${ROOT}:/usr/src/app \
	-w /usr/src/app \
	--net="$(DOCKER_NAMESPACE)" \
	-p 3000:3000 \
	--name robo

DOCKERFULLRUN := $(DOCKERRUN) ${PROJECT_NAME}_work_image

sh: build/rcja_robo_work_image
	$(DOCKERRUN) --entrypoint="sh" ${PROJECT_NAME}_work_image

run: build/rcja_robo_work_image
	$(DOCKERFULLRUN) node app.js

npm: build/rcja_robo_work_image 
	$(DOCKERRUN) --entrypoint="sh" ${PROJECT_NAME}_work_image -c "apk add --no-cache --virtual .npm-deps git python make gcc linux-headers alpine-sdk && /usr/bin/npm set progress=false && /usr/bin/npm install"
	
build/rcja_robo_work_image:
	mkdir -p ${ROOT}/build
	docker rmi -f rcja_robo_work_image > /dev/null 2>&1 || true
	docker build -t rcja_robo_work_image .
	docker inspect -f "{{ .ID }}" rcja_robo_work_image > build/rcja_robo_work_image

clean:
	rm -rf build \
	&& docker rmi rcja_robo_work_image > /dev/null 2>&1 || true

ensureNetwork:
	docker network create $(DOCKER_PROJECT_NAME) > /dev/null 2>&1 || true;

firstDeploy:
	eval $$(triton env --docker) && \
	docker pull davefinster/rcja-dance:latest && \
	docker run -d --name $(PRODUCTION_CONTAINER_NAME) -e "ENVIRONMENT=production" -e "RETHINK_ADDRESS=robocuprethinkdb.svc.davefinster.cns.blenco.net.au" -l "triton.cns.services=robocup" davefinster/rcja-dance:latest && \
	triton instance disable-firewall robocup

deploy:
	eval $$(triton env --docker) && \
	docker stop $(PRODUCTION_CONTAINER_NAME) && \
	docker rm $(PRODUCTION_CONTAINER_NAME) && \
	docker pull davefinster/rcja-dance:latest && \
	docker run -d --name $(PRODUCTION_CONTAINER_NAME) -e "ENVIRONMENT=production" -e "RETHINK_ADDRESS=robocuprethinkdb.svc.davefinster.cns.blenco.net.au" -l "triton.cns.services=robocup" davefinster/rcja-dance:latest && \
	triton instance disable-firewall robocup