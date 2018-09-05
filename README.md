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

![how to test](https://github.com/cucumber/cucumber.io/blob/master/README.terminal.gif?raw=true)

In a few seconds, zeit will spin up a server at a new URL which you can use to manually test your changes.

## Getting access

To be able to deploy, you'll need release karma on Cucumber's zeit account. Current holders of this Karma are:

  * [Matt Wynne](http://github.com/mattwynne)
  * [Jayson Smith](http://github.com/jaysonesmith)
  * [Romain Gérard](http://github.com/romaingweb)

To get release Karma, send a pull request to this repo adding yourself to the list above.
