.DEFAULT_GOAL := unit

.PHONY: unit
unit: 
	bundle exec rspec

.PHONY: rebuild
rebuild: 
	docker stop web
	docker build -t web .
	docker run -i --name web -p 9001:9001 -d --rm --env PORT=9001 --env NAME=localhost web

.PHONY: rubocop
rubocop: 
	bundle exec rubocop -a
