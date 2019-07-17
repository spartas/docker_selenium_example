DOCKER_IMG_NAME 	:= docker_selenium_example
.PHONY: test build clean shell

build: 
	docker build -t $(DOCKER_IMG_NAME) .

test : build
	docker run $(DOCKER_IMG_NAME)

shell : build
	docker run -it $(DOCKER_IMG_NAME) /bin/sh

clean:
	docker rmi -f $(DOCKER_IMG_NAME)

# vim: noexpandtab

