cucumber.io web server
----------------------

This repo contains the source for an nginx web server that runs at https://cucumber.io to handle our incoming traffic. Its 
job is to forward on URLs to different web servers that serve the content for different parts of our website.

The routing configuration is in `nginx/server.conf`

It's automatically deployed to https://zeit.co when you push to master.

[![CircleCI](https://circleci.com/gh/cucumber/cucumber.io/tree/master.svg?style=svg)](https://circleci.com/gh/cucumber/cucumber.io/tree/master)

## Testing changes

To test changes to the config, install the [zeit `now` CLI](https://zeit.co/download#now-cli) and use 
it to publish your local working copy to a docker instance in the cloud (you don't have to commit to git).

In a few seconds, zeit will spin up a server at a new URL which you can use to manually test your changes.
