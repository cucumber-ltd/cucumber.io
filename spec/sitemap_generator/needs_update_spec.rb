# frozen_string_literal: true

require_relative '../../lib/sitemap_generator/needs_update.rb'

describe 'SitemapGenerator' do
  describe 'needs_update?' do
    context 'the external sitemap\'s last modified is newer than our sitemap\'s last modified' do
      it 'returns true' do
        stub_request(:any, 'https://cucumber.ghost.io/sitemap.xml')
          .to_return(headers: { 'last-modified' => 'Sun, 12 May 2019 04:59:14 GMT' })
        stub_request(:any, 'https://cucumber.io/sitemap.xml')
          .to_return(headers: { 'last-modified' => 'Sun, 01 May 2019 04:59:14 GMT' })

        actual = SitemapGenerator.needs_update?('sitemap.xml')

        expect(actual).to be true
      end
    end

    context 'the external sitemap\'s last modified is older than our sitemap\'s last modified' do
      it 'returns false' do
        stub_request(:any, 'https://cucumber.ghost.io/sitemap.xml')
          .to_return(headers: { 'last-modified' => 'Sun, 01 May 2019 04:59:14 GMT' })
        stub_request(:any, 'https://cucumber.io/sitemap.xml')
          .to_return(headers: { 'last-modified' => 'Sun, 10 May 2019 04:59:14 GMT' })

        actual = SitemapGenerator.needs_update?('sitemap.xml')

        expect(actual).to be false
      end
    end
  end
end
