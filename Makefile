.DEFAULT_GOAL := unit

.PHONY: unit
unit: 
	bundle exec rspec

.PHONY: rebuild
rebuild: 
	docker stop web
	docker build -t web --build-arg PORT=9001 --build-arg NAME=localhost .
	docker run -i --name web -p 9001:9001 -d --rm web

.PHONY: rubocop
rubocop: 
	bundle exec rubocop -a
