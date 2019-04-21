# frozen_string_literal: true

describe 'sitemap.xsl route' do
  describe '/sitemap.xsl' do
    it 'proxies to https://cucumber.ghost.io/sitemap.xsl' do
      res = Faraday.get "#{BASE_URL}/sitemap.xsl"

      expect(res.status).to eq 200
      expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.ghost.io/sitemap.xsl'
    end
  end
end
