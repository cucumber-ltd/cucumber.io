# frozen_string_literal: true

describe 'docs routes' do
  describe '/docs' do
    it 'redirects to cucumber.io/docs' do
      res = Faraday.get "#{BASE_URL}/docs"

      expect(res.status).to eq 200
      expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.netlify.com/'
    end
  end

  describe 'docs.cucumber' do
    it 'redirects to cucumber.io/docs' do
      res = Faraday.get "https://docs.cucumber.io"

      expect(res.status).to eq 301
      expect(res.headers.dig('location')).to eq 'https://cucumber.io/docs'
    end
  end

  describe 'css and js assets' do
    context '/css/cucumber.css' do
      it 'redirects to the docs css file' do
        res = Faraday.get "#{BASE_URL}/css/cucumber.css"

        expect(res.status).to eq 200
        expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.netlify.com/css/cucumber.css'
      end
    end

    context '/js/site.js' do
      it 'redirects to the docs js file' do
        res = Faraday.get "#{BASE_URL}/js/site.js"

        expect(res.status).to eq 200
        expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.netlify.com/js/site.js'
      end
    end

    context '/img/cucumber-black-128.png' do
      it 'redirects to the docs logo file' do
        res = Faraday.get "#{BASE_URL}/img/cucumber-black-128.png"

        expect(res.status).to eq 200
        expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.netlify.com/img/cucumber-black-128.png'
      end
    end
  end

  describe 'miscellaneous paths' do
    context 'docs/installation' do
      it 'redirects to the installation main page' do
        res = Faraday.get "#{BASE_URL}/docs/installation/"

        expect(res.status).to eq 200
        expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.netlify.com/docs/installation/'
      end
    end

    context 'docs/guides' do
      it 'redirects to the guides main page' do
        res = Faraday.get "#{BASE_URL}/docs/guides/"

        expect(res.status).to eq 200
        expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.netlify.com/docs/guides/'
      end
    end

    context 'docs/guides/10-minute-tutorial/' do
      it 'redirects to the specific guide page' do
        res = Faraday.get "#{BASE_URL}/docs/guides/10-minute-tutorial/"

        expect(res.status).to eq 200
        expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.netlify.com/docs/guides/10-minute-tutorial/'
      end
    end
  end
end
