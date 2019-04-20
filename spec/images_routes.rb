# frozen_string_literal: true

describe 'images routes' do
  describe 'a ghost hosted image via the /content directory' do
    it 'proxies to the applicable ghost url' do
      res = Faraday.get "#{BASE_URL}/content/images/2019/02/cucumber-black-512.png"

      expect(res.status).to eq 200
      expect(res.headers.dig('x-proxy-pass')).to eq 'https://cucumber.ghost.io/content/images/2019/02/cucumber-black-512.png'
    end
  end

  describe 'a squarespace hosted image in the /static directory' do
    it 'proxies to the applicable squarespace url' do
      res = Faraday.get "#{BASE_URL}/static/5b64cabf5b409bbf05dbd8b3/t/5b8fad55352f53909ed52c75/1536057610588/Cukenfest+2018-1681.jpg"

      expect(res.status).to eq 200
      expect(res.headers.dig('x-proxy-pass')).to eq 'https://static1.squarespace.com/static/5b64cabf5b409bbf05dbd8b3/t/5b8fad55352f53909ed52c75/1536057610588/Cukenfest+2018-1681.jpg'
    end
  end
end
