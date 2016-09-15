PROJECT_NAME=uqcsdemo
DOCKER_NAMESPACE=uqcsdemo_uqcs
ROOT := $(shell pwd)

DOCKERRUN := docker run -it --rm \
	-v ${ROOT}:/usr/src/app \
	-w /usr/src/app \
	--net="$(DOCKER_NAMESPACE)" \
	-p 3000:3000 \
	--name robo

DOCKERFULLRUN := $(DOCKERRUN) ${PROJECT_NAME}_work_image

sh: build/uqcsdemo_work_image
	$(DOCKERRUN) --entrypoint="sh" ${PROJECT_NAME}_work_image

run: build/uqcsdemo_work_image
	$(DOCKERFULLRUN) node app.js

npm: build/uqcsdemo_work_image 
	$(DOCKERRUN) --entrypoint="sh" ${PROJECT_NAME}_work_image -c "apk add --no-cache --virtual .npm-deps git python make gcc linux-headers alpine-sdk && /usr/bin/npm set progress=false && /usr/bin/npm install"
	
build/uqcsdemo_work_image: ensureNetwork
	mkdir -p ${ROOT}/build
	docker rmi -f ${PROJECT_NAME}_work_image > /dev/null 2>&1 || true
	docker build -t ${PROJECT_NAME}_work_image .
	docker inspect -f "{{ .ID }}" ${PROJECT_NAME}_work_image > build/${PROJECT_NAME}_work_image

clean:
	rm -rf build \
	&& docker rmi ${PROJECT_NAME}_work_image > /dev/null 2>&1 || true

ensureNetwork:
	docker network create $(PROJECT_NAME) > /dev/null 2>&1 || true;