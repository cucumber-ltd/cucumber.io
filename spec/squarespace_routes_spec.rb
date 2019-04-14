# frozen_string_literal: true

describe 'squarespace routes' do
  describe '/' do
    it 'redirects to cucumber-website.squarespace.com/' do
      res = Faraday.get "#{BASE_URL}/"

      expect(res.status).to eq 200
      expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber-website.squarespace.com'
    end
  end

  describe '/events/bdd-kickstart-austin-18' do
    it 'redirects to posting the event\'s permanent page' do
      res = Faraday.get "#{BASE_URL}/events/bdd-kickstart-austin-18"

      expect(res.status).to eq 301
      if BASE_URL.include?('staging')
        expect(res.headers.dig('location')).to eq("https://cucumber-io-proxy-staging.herokuapp.com/events/2018/10/18/bdd-kickstart-austin")
      else
        expect(res.headers.dig('location')).to eq("#{BASE_URL}/events/2018/10/18/bdd-kickstart-austin")
      end
    end
  end

  describe '/posting-rules.html' do
    it 'redirects to posting rules in the support path' do
      res = Faraday.get "#{BASE_URL}/posting-rules.html"

      expect(res.status).to eq 301
      if BASE_URL.include?('staging')
        expect(res.headers.dig('location')).to eq("https://cucumber-io-proxy-staging.herokuapp.com/support/posting-rules")
      else
        expect(res.headers.dig('location')).to eq("#{BASE_URL}/support/posting-rules")
      end
    end
  end
end
