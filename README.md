cucumber.io web server
----------------------

This repo contains the source for an nginx web server that runs at https://cucumber.io to handle our incoming traffic. It's job is to forward on URLs to different web servers that handle different parts of our website.

Server config is `nginx.conf` and the routing is handled in `server.conf`

It's deployed to https://zeit.co by CircleCI

[![CircleCI](https://circleci.com/gh/cucumber/cucumber.io/tree/master.svg?style=svg)](https://circleci.com/gh/cucumber/cucumber.io/tree/master)
