
require 'rails_helper'

RSpec.describe WebhooksController do
  it 'works' do
    post '/webhooks/alert',
         params: {
           action: 'test'
         }.to_json
    expect(response.status).to eq(200)
  end
end