# frozen_string_literal: true

describe 'squarespace routes' do
  describe '/' do
    it 'redirects to cucumber-website.squarespace.com/' do
      res = Faraday.get 'http://localhost:9001/'
      found = res.headers.dig('x-proxy-pass').include?('https://cucumber-website.squarespace.com')

      expect(res.status).to eq(200)
      expect(found).to be true
    end
  end
end
