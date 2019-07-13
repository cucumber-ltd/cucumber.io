# frozen_string_literal: true

describe 'sitemap routes' do
    describe '/sitemap.xml' do
      it 'returns the current version on S3' do
        res = Faraday.get "#{BASE_URL}/sitemap.xml"
  
        expect(res.status).to eq 200
        expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.io/sitemap.xml'
      end
    end

    describe '/sitemap.xsl' do
        it 'returns the current version on S3' do
          res = Faraday.get "#{BASE_URL}/sitemap.xsl"
    
          expect(res.status).to eq 200
          expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.io/sitemap.xsl'
        end
      end
  end
  