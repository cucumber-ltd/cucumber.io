# frozen_string_literal: true

describe 'jam routes' do
  describe '/jam' do
    it 'redirects to jam.convertflowpages.com/sales' do
      res = Faraday.get 'http://localhost:9001/jam'

      found = res.headers.dig('x-proxy-pass').include?('https://jam.convertflowpages.com/sales')
      expect(res.status).to eq(200)
      expect(found).to be true
    end
  end

  describe '/pro' do
    it 'redirects to jam.convertflowpages.com/sales' do
      res = Faraday.get 'http://localhost:9001/jam'

      found = res.headers.dig('x-proxy-pass').include?('https://jam.convertflowpages.com/sales')
      expect(res.status).to eq(200)
      expect(found).to be true
    end
  end
end
