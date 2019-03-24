# frozen_string_literal: true

describe 'squarespace routes' do
  describe '/' do
    it 'redirects to cucumber-website.squarespace.com/' do
      res = Faraday.get "#{BASE_URL}/"

      expect(res.status).to eq 200
      expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber-website.squarespace.com'
    end
  end
end
