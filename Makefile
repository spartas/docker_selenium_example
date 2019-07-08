DOCKER_IMG_NAME 	:= docker_selenium_example
.PHONY: test build clean

build: 
	docker build -t $(DOCKER_IMG_NAME) .

test : build
	docker run $(DOCKER_IMG_NAME)

clean:
	docker rmi -f $(DOCKER_IMG_NAME)

# vim: noexpandtab

