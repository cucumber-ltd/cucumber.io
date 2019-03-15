# frozen_string_literal: true

require 'faraday'
require 'pry-byebug'

describe 'blog routes' do
  describe '/blog root' do
    context '/blog with no trailing slash' do
      it 'redirects to cucumber.ghost.io/' do
        res = Faraday.get 'http://localhost:9001/blog'

        found = res.headers.dig('set-cookie').include?('cucumber.ghost.io')

        expect(found).to be true
      end
    end

    context '/blog with no trailing slash' do
      it 'redirects to cucumber.ghost.io/' do
        res = Faraday.get 'http://localhost:9001/blog/'

        found = res.headers.dig('set-cookie').include?('cucumber.ghost.io')

        expect(found).to be true
      end
    end
  end

  describe 'old blog url with date in path /blog/1111/11/blog-slug' do
    it '301s to /blog/blog-slug' do
      res = Faraday.get 'http://localhost:9001/blog/2014/01/28/cukeup-2014'

      expect(res.status).to eq(301)
      expect(res.headers.dig('location')).to eq('http://localhost:9001/blog/cukeup-2014')
    end
  end

  describe
end
