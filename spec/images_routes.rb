# frozen_string_literal: true

describe 'images routes' do
    describe 'an image in the /content directory' do
      it 'proxies to the applicable ghost url' do
        res = Faraday.get "#{BASE_URL}/content/images/2019/02/cucumber-black-512.png"
  
        expect(res.status).to eq 200
        expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.ghost.io/content/images/2019/02/cucumber-black-512.png'
      end
    end
  end
  