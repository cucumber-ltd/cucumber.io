# frozen_string_literal: true

require 'nokogiri'

require_relative '../../lib/sitemap_generator/sanitize.rb'

describe 'SitemapGenerator' do
  describe 'sanitize' do
    it 'returns an xml response with cucumber.ghost.io urls changed to cucumber.io' do
      input = 
'<?xml version="1.0" encoding="UTF-8"?><?xml-stylesheet type="text/xsl" href="//cucumber.ghost.io/sitemap.xsl"?>
  <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    <sitemap>
      <loc>https://cucumber.ghost.io/sitemap-pages.xml</loc>
      <lastmod>2019-04-10T15:19:50.801Z</lastmod>
    </sitemap>
    <sitemap>
      <loc>https://cucumber.ghost.io/sitemap-posts.xml</loc>
      <lastmod>2019-04-05T04:34:10.000Z</lastmod>
    </sitemap>
    <sitemap>
      <loc>https://cucumber.ghost.io/sitemap-authors.xml</loc>
      <lastmod>2019-04-18T03:21:26.896Z</lastmod>
    </sitemap>
    <sitemap>
      <loc>https://cucumber.ghost.io/sitemap-tags.xml</loc>
      <lastmod>2019-03-15T00:27:00.000Z</lastmod>
    </sitemap>
  </sitemapindex>'

      expected = 
'<?xml version="1.0" encoding="UTF-8"?><?xml-stylesheet type="text/xsl" href="//cucumber.io/sitemap.xsl"?>
  <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    <sitemap>
      <loc>https://cucumber.io/sitemap-pages.xml</loc>
      <lastmod>2019-04-10T15:19:50.801Z</lastmod>
    </sitemap>
    <sitemap>
      <loc>https://cucumber.io/sitemap-posts.xml</loc>
      <lastmod>2019-04-05T04:34:10.000Z</lastmod>
    </sitemap>
    <sitemap>
      <loc>https://cucumber.io/sitemap-authors.xml</loc>
      <lastmod>2019-04-18T03:21:26.896Z</lastmod>
    </sitemap>
    <sitemap>
      <loc>https://cucumber.io/sitemap-tags.xml</loc>
      <lastmod>2019-03-15T00:27:00.000Z</lastmod>
    </sitemap>
  </sitemapindex>'

      actual = SitemapGenerator.sanitize(input)

      expect(actual).to eq expected
    end
  end
end
