# frozen_string_literal: true

require_relative '../../lib/sitemap_generator/child_sitemaps.rb'

describe 'SitemapGenerator' do
  describe 'child_sitemaps' do
    context 'children sitemaps are present in parent sitemap' do
      it 'returns a list of the found sitemaps' do
        stub_request(:any, 'https://cucumber.ghost.io/sitemap.xml')
          .to_return(body:
            '<?xml version="1.0" encoding="UTF-8"?><?xml-stylesheet type="text/xsl" href="//cucumber.io/sitemap.xsl"?>
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
            </sitemapindex>')

        expected = [
          'https://cucumber.ghost.io/sitemap-pages.xml',
          'https://cucumber.ghost.io/sitemap-posts.xml',
          'https://cucumber.ghost.io/sitemap-authors.xml',
          'https://cucumber.ghost.io/sitemap-tags.xml'
        ]

        actual = SitemapGenerator.child_sitemaps

        expect(actual).to eq expected
      end
    end

    context 'children sitemaps are not present in parent sitemap' do
      it 'returns empty' do
        stub_request(:any, 'https://cucumber.ghost.io/sitemap.xml')
          .to_return(body:
            '<?xml version="1.0" encoding="UTF-8"?><?xml-stylesheet type="text/xsl" href="//cucumber.io/sitemap.xsl"?>
            <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            </sitemapindex>')

        actual = SitemapGenerator.child_sitemaps

        expect(actual).to be_empty
      end
    end
  end
end
