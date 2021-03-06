require 'rails_helper'

RSpec.describe Api::V1::EventsController, type: :controller  do
  describe 'POST /api/v1/events' do
    it 'should create a new event if given valid params' do
      organization = create(:organization)

      event_params = {
        organization_id: organization.id,
        name: "Blood Drive",
        category: "Healthcare",
        address: "5200 Wadsworth Blvd, Arvada CO 80001",
        phone: "928-779-7857",
        description: "Give us your blood",
        vols_required: 50,
        start_time: "2022-12-31 13:00",
        end_time: "2022-12-31 14:00"
      }
      headers = {"CONTENT_TYPE" => "application/json"}

      post :create, params: event_params
      created_event = Event.last

      expect(response).to be_successful
      expect(response.status).to eq(201)
    end
  end

  describe 'GET /api/v1/events' do
    it "should get a list of events" do

      organization = create(:organization)
      create_list(:event, 3, organization: organization)

      get :index

      expect(response).to be_successful
      expect(response.status).to eq(200)

      items = JSON.parse(response.body, symbolize_names: true)
    end
  end

  describe 'GET /api/v1/events/:id' do
    it "should return a single event" do
      organization = create(:organization)
      event = create :event, { organization: organization }

      get :show, params: { id: event.id }

      expect(response).to be_successful
      expect(response.status).to eq(200)
    end

    it "only returns an event that exists" do
      organization = create(:organization)
      get :show, params: { id: "DOES NOT MATCH"}

      expect(response).not_to be_successful
      expect(response.status).to eq(404)
      event_show = JSON.parse(response.body, symbolize_names: true)
      expect(event_show[:errors][:details]).to eq('Event doesnt exist')
    end
  end

  describe 'PATCH /api/v1/events/:id' do
    it "should update an event" do
      organization = create(:organization)
      event = create :event, { organization: organization }

      event_params = {
        id: event.id,
        name: "Edited Event",
        vols_required: 50,
      }

      expect(event.name).to_not eq("Edited Event")

      patch :update, params: event_params
      json_event = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(response.status).to eq(200)
      expect(json_event[:data][0][:name]).to eq("Edited Event")
    end
  end

  describe 'DELETE /api/v1/events/:id' do
    it "should delete an event" do
      organization = create(:organization)
      event = create :event, { organization: organization }

      delete :destroy, params: {id: event.id}

      expect(response).to be_successful
      expect(response.status).to eq(200)
    end
  end
  describe "#create" do
    include ActiveJob::TestHelper
    context "when an event is saved" do
      before do
        ActiveJob::Base.queue_adapter = :test
        @organization = create(:organization)
        @event = Event.create({
          organization_id: @organization.id,
          name: "Blood Drive",
          category: "Healthcare",
          address: "5200 Wadsworth Blvd, Arvada CO 80001",
          description: "Give us your blood",
          phone: "928-779-7857",
          vols_required: 50,
          start_time: "2022-12-31 13:00",
          end_time: "2022-12-31 14:00"
        })
        @mail = EventMailer.with(@event.id).new_event_email
      end

      it 'job is created' do
        expect {@mail.deliver_later}.to have_enqueued_job.on_queue('mailers')
      end

      it "event email is sent" do
        expect {
          perform_enqueued_jobs do
           @mail.deliver_later
         end
       }.to change { ActionMailer::Base.deliveries.size}.by(1)
      end

      it "event email is sent to the right user" do
        perform_enqueued_jobs do
          @mail.deliver_later
        end

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to[0]).to eq @organization.email
      end
    end
  end
end
