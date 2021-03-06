require "rails_helper"

RSpec.describe EventMailer, type: :mailer do
  describe "notify" do
    before do
      @organization = create(:organization)
      @event = create(:event, organization: @organization)
      @mail = EventMailer.with(@event.id).new_event_email
    end
    it "renders the headers" do
      expect(@mail.subject).to eq("You created a new event!")
      expect(@mail.to).to eq([@organization.email])
      expect(@mail.from).to eq(["dogoodr.unattended@gmail.com"])
    end

    it "renders the body" do
      expect(@mail.body.encoded).to match("Please visit your Do Goodr Dashboard to manage further.")
    end
  end
end
