default: build

help:
	@echo 'Management commands for specinfer:'
	@echo
	@echo 'Usage:'
	@echo '    make build            Build the specinfer project.'
	@echo '    make preprocess       Preprocess step.'
	@echo '    make run              Boot up Docker container.'
	@echo '    make up               Build and run the project.'
	@echo '    make rm               Remove Docker container.'
	@echo '    make stop             Stop Docker container.'
	@echo '    make reset            Stop and remove Docker container.'
	@echo '    make docker-setup     Setup Docker permissions for the user.'

preprocess:
	@echo "Running preprocess step"
	@docker 

build:
	@echo "Building Docker image"
	@docker build . -t specinfer

run:
	@echo "Booting up Docker Container"
	@docker run -it --gpus '"device=3"' --ipc=host --name specinfer -v `pwd`:/workspace specinfer:latest /bin/bash

up: build run

rm: 
	@echo "Removing Docker container"
	@docker rm specinfer

stop:
	@echo "Stopping Docker container"
	@docker stop specinfer

reset: stop rm

docker-setup:
	@echo "Setting up Docker permissions for the current user"
	@sudo groupadd docker || true
	@sudo usermod -aG docker $(USER)
	@newgrp docker