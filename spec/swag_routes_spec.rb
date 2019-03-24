# frozen_string_literal: true

describe 'swag routes' do
  describe '/swag' do
    xit 'redirects to swag.cucumber.io' do
      res = Faraday.get "#{BASE_URL}/swag"

      expect(res.status).to eq 200
      expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumberbdd.threadless.com/'
    end
  end
end
