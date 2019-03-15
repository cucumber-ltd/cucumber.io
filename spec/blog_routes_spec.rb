require 'faraday'
require 'pry-byebug'

describe "blog routes" do
    describe "/blog" do
        it "redirects to cucumber.ghost.io/" do
            res = Faraday.get "http://localhost:9001/blog"

        end
    end
end
