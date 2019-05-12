# frozen_string_literal: true

require_relative '../../lib/sitemap_generator/get_children.rb'

describe 'SitemapGenerator' do
  describe 'child_sitemaps' do
    context 'children sitemaps are present in parent sitemap' do
      it 'returns true' do
        stub_request(:any, 'https://cucumber.ghost.io/sitemap.xml')
          .to_return(body: 'foo')

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

    # context 'children sitemaps are not present in parent sitemap' do
    #   it 'returns false' do
    #     stub_request(:any, 'https://cucumber.ghost.io/sitemap.xml')
    #       .to_return(headers: { 'last-modified' => 'Sun, 01 May 2019 04:59:14 GMT' })
    #     stub_request(:any, 'https://cucumber.io/sitemap.xml')
    #       .to_return(headers: { 'last-modified' => 'Sun, 10 May 2019 04:59:14 GMT' })

    #     actual = SitemapGenerator.needs_update?('sitemap.xml')

    #     expect(actual).to be false
    #   end
    # end
  end
end
