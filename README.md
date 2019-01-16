cucumber.io proxy server
------------------------

This repo contains the source for an nginx web server that runs at https://cucumber.io to handle our incoming traffic. Its 
job is to forward on URLs to different web servers that serve the content for different parts of our website.

The routing configuration is in [`nginx/server.conf`](https://github.com/cucumber/cucumber.io/blob/master/nginx/server.conf)

It's automatically deployed to Heroku when you push to master.

[![CircleCI](https://circleci.com/gh/cucumber/cucumber.io/tree/master.svg?style=svg)](https://circleci.com/gh/cucumber/cucumber.io/tree/master)
