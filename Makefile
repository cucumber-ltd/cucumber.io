.DEFAULT_GOAL := unit

.PHONY: unit
unit: 
	bundle exec rspec

.PHONY: build_run
build_run: 
	docker build -t web .
	docker run -i --name web -p 9001:9001 -d --rm --env PORT=9001 --env NAME=localhost web
	docker logs -f web

.PHONY: rebuild
rebuild: 
	docker stop web
	make build_run
	docker logs -f web

.PHONY: rubocop
rubocop: 
	bundle exec rubocop -a
