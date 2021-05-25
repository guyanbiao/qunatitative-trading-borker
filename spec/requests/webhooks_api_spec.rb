
require 'rails_helper'

RSpec.describe WebhooksController do
  it 'works' do
    ActionController::Base.allow_forgery_protection = true
    post '/webhooks/alert',
         params: {
           action: 'test'
         }.to_json
    expect(response.status).to eq(200)
  end
end