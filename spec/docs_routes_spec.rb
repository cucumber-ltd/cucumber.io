# frozen_string_literal: true

require 'pry-byebug'

describe 'docs routes' do
  describe '/docs' do
    it 'redirects to docs.cucumber.io' do
      res = Faraday.get 'http://localhost:9001/docs'

      found = res.headers.dig('x-proxy-pass').include?('https://docs.cucumber.io/')
      expect(res.status).to eq(200)
      expect(found).to be true
    end
  end
end
