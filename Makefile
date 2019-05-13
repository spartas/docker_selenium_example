.PHONY: test

test :
	docker build -t docker_selenium_example .
	docker run docker_selenium_example

# vim: noexpandtab

