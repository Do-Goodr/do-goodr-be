require 'rails_helper'

RSpec.describe 'Search API' do
  describe 'GET /api/v1/search' do
    it 'should return events within a zip code radius' do
      organization = Organization.create!(name: "ARC", location: "Denver, CO", phone: "555-555-5555", email: "denver@arc.org")
      event1 = Event.create!(name: 'Soup Kitchen', category: 1, address: '1625 Fenton St., Lakewood CO 80214', description: 'Good food', vols_required: 5, organization_id: organization.id, start_time: "2022-12-31 13:00", duration: 2)
      event2 = Event.create!(name: 'Blood Drive', category: 2, address: '5280 Wadsworth Blvd, Arvada CO', description: 'Good blood', vols_required: 1, organization_id: organization.id, start_time: "2022-12-31 13:00", duration: 2)
      event3 = Event.create!(name: 'Homeless Living', category: 2, address: '2136 Champa St, Denver, CO 80205', description: 'Good blood', vols_required: 1, organization_id: organization.id, start_time: "2022-12-31 13:00", duration: 2)

      search_params = {
        zip: "80001",
        distance: 10
      }
      headers = {"CONTENT_TYPE" => "application/json"}

      get '/api/v1/search', params: search_params

      expect(response).to be_successful
      # expect(response.status).to eq(200)
    end
  end
end
