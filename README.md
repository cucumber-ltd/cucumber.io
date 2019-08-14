[![CircleCI](https://circleci.com/gh/cucumber/cucumber.io/tree/master.svg?style=svg)](https://circleci.com/gh/cucumber/cucumber.io/tree/master)

# cucumber.io proxy server
------------------------

This repo contains the source for an nginx web server that runs at https://cucumber.io to handle our incoming traffic. Its
job is to forward on URLs to different web servers that serve the content for different parts of our website.

The routing configuration is in [`nginx/server.conf`](https://github.com/cucumber/cucumber.io/blob/master/nginx/server.conf)

It's automatically deployed to Heroku when you push to master if tests pass.

## How the whole thing works

All requests to https://cucumber.io are first managed by Cloudflare.

Cloudflare's DNS servers send requests to this nginx app, running at https://cucumber-io-proxy.herokuapp.com

This nginx app looks at the path in the request and, according to [its rules](https://github.com/cucumber/cucumber.io/blob/master/nginx/server.conf), makes another request to the server that's actually responsible for delivering content for that path.

For example, traffic to `/docs` is handled by our hugo app running with Netlify at https://cucumber.netlify.com whereas traffic to `/` or `/events` is handled by Squarespace running at https://cucumber-website.squarespace.com For our generated files like our sitemap.xml or rss feed, we have [another repo](https://github.com/cucumber/cucumber.io-file-generator) that builds nightly, sanitizes the urls to only be cucumber.io, and then uploads the new copies to Amazon's S3 for use. The nginx server's config points to those files for routing.

```
+-------------+        +----------------
|             |        |               |
|             |        |  cucumber.io  |         /            +----->   cucumber-website.squarespace.com
| Cloudflare  +-------->  nginx proxy  +------>  /blog        +----->   cucumber.ghost.io
|             |        |               |         /training    +----->   cucumber-website.squarespace.com
|             |        |               |         /docs        +----->   cucumber.netlify.com
|             |        |               |         /sitemap.xml +----->   cucumber-io-generated-files.s3-eu-west-1.amazonaws.com
+-------------+        +---------------+
```

## Why did you make it so complicated?!

Well. We wanted to be able to migrate the website one page at a time from the old Heroku app over to Squarespace. Using this proxy allows us to choose what content is delivered by what back-end. It's like Cloudflare's page rules, only we have much more control over them.

## Testing

### Local

`make test_local`

Spins up a local docker container on port 9001, runs rspec against it, and stops the container. If you'd like it to install gems for you too, run: `make local_test_setup`

### Local against the live deployment

`BASE_URL=https://cucumber.io make rspec`

Installs gems and runs rspec against the live site

### CircleCI

During builds CircleCI will install nginx locally, and run rspec against that.
