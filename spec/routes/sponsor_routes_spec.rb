# frozen_string_literal: true

describe 'sponsor routes' do
  describe '/sponsors' do
    it 'forwards to https://cucumber.netlify.com/sponsors' do
      res = Faraday.get "#{BASE_URL}/sponsors"

      expect(res.status).to eq 200
      expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.netlify.com/sponsors'
    end
  end

  describe '/sponsors/' do
    it 'forwards to https://cucumber.netlify.com/sponsors' do
      res = Faraday.get "#{BASE_URL}/sponsors/"

      expect(res.status).to eq 200
      expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.netlify.com/sponsors'
    end
  end
end
