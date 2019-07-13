# frozen_string_literal: true

describe 'robots routes' do
  describe '/robots.txt' do
    it 'returns the current version on S3' do
      res = Faraday.get "#{BASE_URL}/robots.txt"

      expect(res.status).to eq 200
      expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.io/robots.txt'
    end
  end
end
