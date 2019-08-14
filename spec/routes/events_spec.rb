# frozen_string_literal: true

describe '/events routes' do

  describe 'old event urls (pre-squarespace)' do
    it '301s to the /events landing page' do
      res = Faraday.get "#{BASE_URL}/events/some-old-event"

      expect(res.status).to eq 301
      expect(res.headers.dig('location')).to eq("#{BASE_URL}/events")
    end
  end

end
