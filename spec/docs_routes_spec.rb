# frozen_string_literal: true

describe 'docs routes' do
  describe '/docs' do
    xit 'redirects to docs.cucumber.io' do
      res = Faraday.get 'http://localhost:9001/docs'

      expect(res.status).to eq 200
      expect(res.headers.dig('x-proxy-pass')).to eq 'https://docs.cucumber.io/'
    end
  end
end
