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

  # Shared countries data
  let(:usa_country) { double('Country', id: SecureRandom.uuid, name: 'United States', prefix: '+1', iso_code: 'US') }
  let(:ukraine_country) { double('Country', id: SecureRandom.uuid, name: 'Ukraine', prefix: '+380', iso_code: 'UA') }
  let(:uk_country) { double('Country', id: SecureRandom.uuid, name: 'United Kingdom', prefix: '+44', iso_code: 'GB') }

  let(:response_headers) do
    { 'Content-Type' => 'application/vnd.api+json; charset=utf-8' }
  end

  # Shared query parameters
  let(:base_query_params) do
    {
      'include' => 'country,proofs.proof_type,addresses,addresses.country,permanent_documents',
      'page[number]' => '1',
      'page[size]' => '10',
      'sort' => '-created_at'
    }
  end

  # Shared headers
  let(:base_headers) do
    {
      'Accept' => 'application/vnd.api+json',
      'Content-Type' => 'application/vnd.api+json',
      'X-Didww-Api-Version' => '2022-05-10'
    }
  end

  # Personal identity response body
  let(:personal_response_body) do
    {
      data: [
        {
          id: SecureRandom.uuid,
          type: 'identities',
          attributes: {
            first_name: 'John',
            last_name: 'Doe',
            company_name: nil
          },
          relationships: {
            country: {
              data: { id: usa_country.id, type: 'countries' }
            }
          }
        }
      ],
      included: [
        {
          id: usa_country.id,
          type: 'countries',
          attributes: {
            name: usa_country.name,
            prefix: usa_country.prefix,
            iso_code: usa_country.iso_code
          }
        }
      ]
    }
  end

  #The first Business identity response body
  let(:business_response_body) do
    {
      data: [
        {
          id: SecureRandom.uuid,
          type: 'identities',
          attributes: {
            first_name: 'Elon',
            last_name: 'Musk',
            company_name: 'Tesla'
          },
          relationships: {
            country: {
              data: { id: ukraine_country.id, type: 'countries' }
            }
          }
        }
      ],
      included: [
        {
          id: ukraine_country.id,
          type: 'countries',
          attributes: {
            name: ukraine_country.name,
            prefix: ukraine_country.prefix,
            iso_code: ukraine_country.iso_code
          }
        }
      ]
    }
  end

  # The second business identity response body
  let(:another_business_response_body) do
    {
      data: [
        {
          id: SecureRandom.uuid,
          type: 'identities',
          attributes: {
            first_name: 'Steve',
            last_name: 'Jobs',
            company_name: 'Apple'
          },
          relationships: {
            country: {
              data: { id: uk_country.id, type: 'countries' }
            }
          }
        }
      ],
      included: [
        {
          id: uk_country.id,
          type: 'countries',
          attributes: {
            name: uk_country.name,
            prefix: uk_country.prefix,
            iso_code: uk_country.iso_code
          }
        }
      ]
    }
  end

  # All identities response body
  let(:response_body) do
    {
      data: [
        personal_response_body[:data][0],
        business_response_body[:data][0],
        another_business_response_body[:data][0]
      ],
      included: [
        personal_response_body[:included][0],
        business_response_body[:included][0],
        another_business_response_body[:included][0]
      ]
    }
  end

  let(:empty_response_body) do
    { data: [], included: [] }
  end

  describe 'GET /identities' do
    include_context 'with a logged-in user'

    subject { visit '/identities' }

    before do
      WebMock.stub_request(:get, 'https://sandbox-api.didww.com/v3/identities')
        .with(query: base_query_params, headers: base_headers)
        .to_return(status: 200, body: response_body.to_json, headers: response_headers)
    end

    it 'displays headings' do
      subject
      expect(page).to have_css('.panel-heading strong', text: 'Identities')
    end

    it 'displays the identity list' do
      subject
      expect(page).to have_css('table tbody tr', count: 3)
      expect(page).to have_css('td', text: 'John Doe')
      expect(page).to have_css('td', text: 'Elon Musk')
      expect(page).to have_css('td', text: 'Steve Jobs')
      expect(page).to have_css('td', text: 'Tesla')
      expect(page).to have_css('td', text: 'Apple')
      expect(page).to have_css('td', text: 'United States')
      expect(page).to have_css('td', text: 'Ukraine')
      expect(page).to have_css('td', text: 'United Kingdom')
      # The text under the table
      expect(page).to have_text('Displaying all 3 entries')
    end

    it 'displays "Add new" button with dropdown menu' do
      subject
      expect(page).to have_button('Add new')
      expect(page).to have_css('button.btn.btn-success', text: 'Add new')

      expect(page).to have_css('.dropdown-menu')

      find('button.btn.btn-success').click

      expect(page).to have_link('Personal Identity')
      expect(page).to have_link('Business Identity')
    end

    it 'displays "Search" button' do
      subject
      expect(page).to have_button('Search')
      expect(page).to have_css('input.btn.btn-primary[value="Search"]')
    end

    it 'displays "Clear" link' do
      subject
      expect(page).to have_link('Clear')
      expect(page).to have_css('a.btn.btn-default', text: 'Clear')
    end

    context 'when API returns empty data' do
      before do
        WebMock.stub_request(:get, 'https://sandbox-api.didww.com/v3/identities')
          .with(query: base_query_params, headers: base_headers)
          .to_return(status: 200, body: empty_response_body.to_json, headers: response_headers)
        visit '/identities'
      end

      it 'displays empty state message' do
        expect(page).to have_css('table tbody tr', count: 0)
        expect(page).not_to have_css('td', text: 'John Doe')
        expect(page).not_to have_css('td', text: 'Elon Musk')
        expect(page).not_to have_css('td', text: 'Steve Jobs')
      end
    end
  end

  describe 'page filters' do
    include_context 'with a logged-in user'
    before do
      WebMock.stub_request(:get, 'https://sandbox-api.didww.com/v3/identities')
        .with(query: base_query_params, headers: base_headers)
        .to_return(status: 200, body: response_body.to_json, headers: response_headers)

      visit '/identities'
    end

    context 'when filters have default state' do
      it 'identity type filter' do
        expect(page).to have_select('q[identity_type]', with_options: ['Search by identity type...', 'Personal', 'Business'])

        select_element = find('select[name="q[identity_type]"]')
        expect(select_element.value).to eq('')

        expect(select_element.find('option:first-child').text).to eq('Search by identity type...')
        expect(select_element.find('option:first-child').value).to eq('')
      end
      it 'first name filter' do
        expect(page).to have_field('q[first_name_contains]', placeholder: 'First Name')
        expect(find('#q_first_name_contains').value).to be_blank
      end
      it 'last name filter' do
        expect(page).to have_field('q[last_name_contains]', placeholder: 'Last Name')
        expect(find('#q_last_name_contains').value).to be_blank
      end
      it 'company name filter' do
        expect(page).to have_field('q[company_name_contains]', placeholder: 'Company Name')
        expect(find('#q_company_name_contains').value).to be_blank
      end
      it 'description filter' do
        expect(page).to have_field('q[description_contains]', placeholder: 'Description')
        expect(find('#q_description_contains').value).to be_blank
      end
      it 'external reference id' do
        expect(page).to have_field('q[external_reference_id]', placeholder: 'External Reference ID')
        expect(find('#q_external_reference_id').value).to be_blank
      end
    end

    context 'filter by identity type - Personal' do
      let(:personal_filter_params) do
        base_query_params.merge('filter[identity_type]' => 'Personal')
      end
      before do
        WebMock.stub_request(:get, 'https://sandbox-api.didww.com/v3/identities')
          .with(query: personal_filter_params, headers: base_headers)
          .to_return(
            status: 200,
            body: personal_response_body.to_json,
            headers: response_headers
          )
      end

      it 'sends correct API request and shows only personal identity' do
        select 'Personal', from: 'q[identity_type]'
        click_button 'Search'

        # Сorrect filter parameters were applied
        expect(WebMock).to have_requested(:get, 'https://sandbox-api.didww.com/v3/identities')
          .with(query: personal_filter_params)

        expect(page).to have_css('table tbody tr', count: 1)
        expect(page).to have_css('td', text: 'John Doe')
        expect(page).to have_css('td', text: 'United States')

        # Business identities should not be displayed
        expect(page).not_to have_css('td', text: 'Elon Musk')
        expect(page).not_to have_css('td', text: 'Steve Jobs')
        expect(page).not_to have_css('td', text: 'Tesla')
        expect(page).not_to have_css('td', text: 'Apple')
      end
    end

    context 'filter by identity type - Business' do
      let(:business_filter_params) do
        base_query_params.merge('filter[identity_type]' => 'Business')
      end

      before do
        WebMock.stub_request(:get, 'https://sandbox-api.didww.com/v3/identities')
          .with(query: business_filter_params, headers: base_headers)
          .to_return(
            status: 200,
            body: business_response_body.to_json,
            headers: response_headers
          )
      end

      it 'sends correct API request and shows only business identity' do
        select 'Business', from: 'q[identity_type]'
        click_button 'Search'

        # Сorrect filter parameters were applied
        expect(WebMock).to have_requested(:get, 'https://sandbox-api.didww.com/v3/identities')
          .with(query: business_filter_params)

        expect(page).to have_css('table tbody tr', count: 1)
        expect(page).to have_css('td', text: 'Elon Musk')
        expect(page).to have_css('td', text: 'Tesla')
        expect(page).to have_css('td', text: 'Ukraine')

        # Personal identity should not be displayed
        expect(page).not_to have_css('td', text: 'John Doe')
        expect(page).not_to have_css('td', text: 'Steve Jobs')
        expect(page).not_to have_css('td', text: 'Apple')
      end
    end

    context 'filter by first name' do
      let(:first_name_filter_params) do
        base_query_params.merge('filter[first_name_contains]' => 'John')
      end

      before do
        WebMock.stub_request(:get, 'https://sandbox-api.didww.com/v3/identities')
          .with(query: first_name_filter_params, headers: base_headers)
          .to_return(
            status: 200,
            body: personal_response_body.to_json,
            headers: response_headers
          )
      end

      it 'sends correct API request and shows only matching identity' do
        fill_in 'q[first_name_contains]', with: 'John'
        click_button 'Search'

        # Сorrect filter parameters were applied
        expect(WebMock).to have_requested(:get, 'https://sandbox-api.didww.com/v3/identities')
          .with(query: first_name_filter_params)

        expect(page).to have_css('table tbody tr', count: 1)
        expect(page).to have_css('td', text: 'John Doe')

        # Other identities should not be displayed
        expect(page).not_to have_css('td', text: 'Elon Musk')
        expect(page).not_to have_css('td', text: 'Steve Jobs')
      end
    end

    context 'filter by company name' do
      let(:company_filter_params) do
        base_query_params.merge('filter[company_name_contains]' => 'Tesla')
      end

      before do
        WebMock.stub_request(:get, 'https://sandbox-api.didww.com/v3/identities')
          .with(query: company_filter_params, headers: base_headers)
          .to_return(
            status: 200,
            body: business_response_body.to_json,
            headers: response_headers
            )
      end

      it 'sends correct API request and shows only matching identity' do
        fill_in 'q[company_name_contains]', with: 'Tesla'
        click_button 'Search'

        # Сorrect filter parameters were applied
        expect(WebMock).to have_requested(:get, 'https://sandbox-api.didww.com/v3/identities')
           .with(query: company_filter_params)

        expect(page).to have_css('table tbody tr', count: 1)
        expect(page).to have_css('td', text: 'Elon Musk')
        expect(page).to have_css('td', text: 'Tesla')

        # Other identities should not be displayed
        expect(page).not_to have_css('td', text: 'John Doe')
        expect(page).not_to have_css('td', text: 'Steve Jobs')
      end
    end

    context 'clear filters functionality' do
      before do
        # Fill in some filters first
        select 'Business', from: 'q[identity_type]'
        fill_in 'q[first_name_contains]', with: 'Elon'
        fill_in 'q[company_name_contains]', with: 'Tesla'
      end

      it 'clears all filters when Clear link is clicked' do
        click_link 'Clear'

        expect(find('select[name="q[identity_type]"]').value).to eq('')
        expect(find('#q_first_name_contains').value).to be_blank
        expect(find('#q_company_name_contains').value).to be_blank
        expect(find('#q_description_contains').value).to be_blank
        expect(find('#q_external_reference_id').value).to be_blank
      end
    end
  end
end
