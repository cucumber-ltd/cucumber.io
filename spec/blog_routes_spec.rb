# frozen_string_literal: true

describe '/blog routes' do
  describe '/blog root' do
    context '/blog with no trailing slash' do
      it 'redirects to cucumber.ghost.io/' do
        res = Faraday.get 'http://localhost:9001/blog'

        expect(res.status).to eq 200
        expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.ghost.io/blog/'
      end
    end

    context '/blog with no trailing slash' do
      it 'proxies to cucumber.ghost.io/' do
        res = Faraday.get 'http://localhost:9001/blog/'

        expect(res.status).to eq 200
        expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.ghost.io/blog/'
      end
    end
  end

  describe 'old blog url with date in path /blog/1111/11/blog-slug' do
    it '301s to /blog/blog-slug' do
      res = Faraday.get 'http://localhost:9001/blog/2014/01/28/cukeup-2014'

      expect(res.status).to eq 301
      expect(res.headers.dig('location')).to eq('http://localhost:9001/blog/cukeup-2014')
    end
  end

  describe 'blog/slug urls are proxied to ghost' do
    it 'proxies to cucumber.ghost.io/' do
      res = Faraday.get 'http://localhost:9001/blog/cukeup-2014/'

      expect(res.status).to eq 200
      expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.ghost.io/blog/cukeup-2014/'
    end
  end

  describe 'custom paths' do
    it 'proxies to cucumber.ghost.io/' do
      res = Faraday.get 'http://localhost:9001/blog/introducing-example-mapping'

      expect(res.status).to eq 302
      expect(res.headers.dig('location')).to eq('http://localhost:9001/blog/example-mapping-introduction/')
    end
  end
end
