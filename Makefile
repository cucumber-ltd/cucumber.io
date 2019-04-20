.DEFAULT_GOAL := rspec

.PHONY: rspec
rspec: 
	bundle install
	bundle exec parallel_rspec spec/

.PHONY: test_local
test_local:
	make build_run
	make rspec
	make stop

.PHONY: test_local_setup
test_local_setup:
	bundle install
	make build_run
	make rspec
	make stop

.PHONY: build_run
build_run: 
	docker build -t web .
	docker run -i --name web -p 9001:9001 -d --rm --env PORT=9001 --env NAME=localhost --env NGINX_API_KEY=$NGINX_API_KEY web

.PHONY: stop
stop:
	docker stop web

.PHONY: rebuild
rebuild: 
	make stop
	make build_run

.PHONY: rubocop
rubocop: 
	bundle exec rubocop -a
