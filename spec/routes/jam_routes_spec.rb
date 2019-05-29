# frozen_string_literal: true

describe 'jam routes' do
  describe '/jam' do
    it 'redirects to jam.convertflowpages.com/sales' do
      res = Faraday.get "#{BASE_URL}/jam"

      expect(res.status).to eq 200
      expect(res.headers.dig('x-proxy-pass')).to eq 'https://jam.convertflowpages.com/sales'
    end
  end

  describe '/pro' do
    it 'redirects to jam.convertflowpages.com/sales' do
      res = Faraday.get "#{BASE_URL}/jam"

      expect(res.status).to eq 200
      expect(res.headers.dig('x-proxy-pass')).to eq 'https://jam.convertflowpages.com/sales'
    end
  end
end
