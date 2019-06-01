# frozen_string_literal: true

describe 'rss routes' do
    describe '/rss' do
      it 'returns the local /rss.xml' do
        res = Faraday.get "#{BASE_URL}/blog/rss"
  
        expect(res.status).to eq 200
        expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.io/blog/rss.xml'
      end
    end
  end
  