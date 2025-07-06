# frozen_string_literal: true

RSpec.describe 'Identities', type: :feature do
  RSpec.shared_context 'with a logged-in user' do
    let(:dummy_api_key) { 'dummy_api_key' }

    before do
      # Simulate a logged-in user
      allow_any_instance_of(ActionDispatch::Request::Session).to receive(:[]).and_wrap_original do |original_method, key|
        if key == :api_key
          dummy_api_key
        elsif key == :cached_balance
          { balance: 1_000 }
        else
          original_method.call(key)
        end
      end
    end
  end

  describe 'GET /identities' do
    include_context 'with a logged-in user'

    subject { visit '/identities' }

    before do
      WebMock.stub_request(:get, 'https://sandbox-api.didww.com/v3/identities').
        with(
          query: {
            'include' => 'country,proofs.proof_type,addresses,addresses.country,permanent_documents',
            'page[number]' => '1',
            'page[size]' => '10',
            'sort' => '-created_at'
          },
          headers: {
            'Accept'=>'application/vnd.api+json',
            'Content-Type'=>'application/vnd.api+json',
            'X-Didww-Api-Version'=>'2022-05-10'
          }).to_return(status: 200, body: response_body.to_json, headers: response_headers)
    end
    let(:country) { double('Country', id: SecureRandom.uuid, name: 'United States', prefix: '+1', iso_code: 'US') }

    let(:response_body) do
      {
        data: [
          {
            id: SecureRandom.uuid,
            type: 'identities',
            attributes: {
              first_name: 'John',
              last_name: 'Doe',
              company_name: 'Acme Corp'
            },
            relationships: {
              country: {
                data: {
                  id: country.id,
                  type: 'countries'
                }
              },
            }
          }
        ],
        included: [
          {
            id: country.id,
            type: 'countries',
            attributes: {
              name: country.name,
              prefix: country.prefix,
              iso_code: country.iso_code
            }
          }
        ]
      }
    end
    let(:response_headers) do
      {
        'Content-Type' => 'application/vnd.api+json; charset=utf-8'
      }
    end

    it 'displays headings' do
      subject
      expect(page).to have_css('.panel-heading strong', text: 'Identities')
    end

    it 'displays the identity list' do
      subject
      expect(page).to have_css('table tbody tr', count: 1)
      expect(page).to have_css('td', text: 'John Doe')
      expect(page).to have_css('td', text: 'Acme Corp')
      expect(page).to have_css('td', text: 'United States')
    end
  end

  describe 'GET /identities/:id' do
    include_context 'with a logged-in user'
  end
end
