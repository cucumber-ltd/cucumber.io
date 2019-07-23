# frozen_string_literal: true

describe 'asset routes' do
    describe '/assets/ui-icons.svg' do
      it 'redirects to Squarespace' do
        res = Faraday.get "#{BASE_URL}/assets/ui-icons.svg"
  
        expect(res.status).to eq 200
        expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber-website.squarespace.com'
      end
    end
  
    describe '/assets/css/screen.css' do
      it 'redirects to Ghost assets' do
        res = Faraday.get "#{BASE_URL}/assets/css/screen.css"
  
        expect(res.status).to eq 200
        expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.ghost.io/assets/css/screen.css'
      end
    end
  end
  