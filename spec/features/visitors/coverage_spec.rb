# frozen_string_literal: true

RSpec.describe 'Coverage', type: :feature do
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

  describe 'GET /coverage' do
    include_context 'with a logged-in user'

    subject { visit '/coverage' }

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
          }).to_return(status: 200, body: identities_response_body.to_json, headers: response_headers)

      WebMock.stub_request(:get, 'https://sandbox-api.didww.com/v3/countries?filter%5Bis_available%5D=true').
        with(
          headers: {
	          'Accept'=>'application/vnd.api+json',
	          'Accept-Encoding'=>'gzip,deflate',
	          'Content-Type'=>'application/vnd.api+json',
	          'User-Agent'=>'didww-v3 Ruby gem v4.1.0',
	          'X-Didww-Api-Version'=>'2022-05-10'
          }).to_return(status: 200, body: countries_response_body.to_json, headers: response_headers)

      WebMock.stub_request(:get, 'https://sandbox-api.didww.com/v3/did_group_types').
        with(
          headers: {
	          'Accept'=>'application/vnd.api+json',
	          'Accept-Encoding'=>'gzip,deflate',
	          'Content-Type'=>'application/vnd.api+json',
	          'User-Agent'=>'didww-v3 Ruby gem v4.1.0',
	          'X-Didww-Api-Version'=>'2022-05-10'
          }).to_return(status: 200, body: did_group_types_response_body.to_json, headers: response_headers)

      WebMock.stub_request(:get, 'https://sandbox-api.didww.com/v3/did_groups?').
        with(
          query: {
            'include' => 'country,city,region,did_group_type,stock_keeping_units,requirement',
            'page[number]' => '1',
            'page[size]' => '10',
            'sort' => 'country.name'
          },
          headers: {
	          'Accept'=>'application/vnd.api+json',
	          'Accept-Encoding'=>'gzip,deflate',
	          'Content-Type'=>'application/vnd.api+json',
	          'User-Agent'=>'didww-v3 Ruby gem v4.1.0',
	          'X-Didww-Api-Version'=>'2022-05-10'
          }).to_return(status: 200, body: did_groups_response_body.to_json, headers: response_headers)
    end

    let(:country) { double('country', id: SecureRandom.uuid, name: 'United States', prefix: '1', iso: 'US') }
    let(:countries) { double('countries', [country, did_group_country] ) }

    let(:identities_response_body) do
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
              iso_code: country.iso
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
    let(:countries_response_body) do
      {
        data: [
            {
              id: did_group_country.id,
              type: 'countries',
              attributes: {
                name: did_group_country.name,
                prefix: did_group_country.prefix,
                iso: did_group_country.iso
              }
            },
            {
              id: country.id,
              type: 'countries',
              attributes: {
                name: country.name,
                prefix: country.prefix,
                iso: country.iso
              }
          }]
      }
    end

    let(:did_group_type_global) { double('DidGroupType', id: SecureRandom.uuid, name: 'Global') }
    let(:did_group_type_local) { double('DidGroupType', id: SecureRandom.uuid, name: 'Local') }
    let(:did_group_type_mobile) { double('DidGroupType', id: SecureRandom.uuid, name: 'Mobile') }
    let(:did_group_type_national) { double('DidGroupType', id: SecureRandom.uuid, name: 'National') }
    let(:did_group_type_shared_cost) { double('DidGroupType', id: SecureRandom.uuid, name: 'Shared Cost') }
    let(:did_group_type_toll_free) { double('DidGroupType', id: SecureRandom.uuid, name: 'Toll-free') }

    let(:did_group_types_response_body) do
      {
        data: [
          {
            id: did_group_type_local.id,
            type: 'did_group_types',
            attributes: {
              name: did_group_type_local.name
            }
          },
          {
            id: did_group_type_national.id,
            type: 'did_group_types',
            attributes: {
              name: did_group_type_national.name
            }
          },
          {
            id: did_group_type_toll_free.id,
            type: 'did_group_types',
            attributes: {
              name: did_group_type_toll_free.name
            }
          },
          {
            id: did_group_type_mobile.id,
            type: 'did_group_types',
            attributes: {
              name: did_group_type_mobile.name
            }
          },
          {
            id: did_group_type_shared_cost.id,
            type: 'did_group_types',
            attributes: {
              name: did_group_type_shared_cost.name
            }
          },
          {
            id: did_group_type_global.id,
            type: 'did_group_types',
            attributes: {
              name: did_group_type_global.name
            }
          }
        ]
      }
    end
    let(:did_group_country) { double('Country', id: SecureRandom.uuid, name: 'Ukraine', prefix: '380', iso: 'UA') }
    let(:sku) { double('sku', id: SecureRandom.uuid, setup_price: '1.23', monthly_price: '4.56', channels_included_count: '0') }
    let(:did_groups_response_body) do
      {
        data: [
          {
            id: SecureRandom.uuid,
            type: 'did_groups',
            attributes: {
              prefix: '632',
              local_prefix: '',
              features: ['voice', 'voice_out', 't38'],
              is_metered: true,
              area_name: 'Life',
              allow_additional_channels: false
            },
            relationships: {
              country: {
                data: {
                  id: did_group_country.id,
                  type: 'countries'
                }
              },
              did_group_type:{
                data: {
                  type: 'did_group_types',
                  id: did_group_type_mobile.id
                }
              },
              stock_keeping_units: {
                data: [
                  {
                    type: 'stock_keeping_units',
                    id: sku.id
                  }
                ]
              }
            },
            meta: {
                available_dids_enabled: false,
                needs_registration: false,
                is_available: true,
                total_count: 10
            }
        }],
        included: [
          {
            id: did_group_country.id,
            type: 'countries',
            attributes: {
              name: did_group_country.name,
              prefix: did_group_country.prefix,
              iso: did_group_country.iso
            }
          },
          {
            id: did_group_type_mobile.id,
            type: 'did_group_types',
            attributes: {
              name: did_group_type_mobile.name,
            }
          },
          {
            id: sku.id,
            type: 'stock_keeping_units',
            attributes: {
              setup_price: sku.setup_price,
              monthly_price: sku.monthly_price,
              channels_included_count: sku.channels_included_count
            }
          }
        ],
        meta: {
        total_records: '1',
        api_version: '2022-05-10'
        }
      }
    end

    it 'displays headings' do
      subject { visit '/coverage' }
      expect(page).to have_css('.panel-heading', text: 'Coverage')
    end

    it 'displays Search button' do
      subject { visit '/coverage' }
      expect(page).to have_button('Search')
    end

    it 'displays Clear button' do
      subject { visit '/coverage' }
      expect(page).to have_link('Clear', href: '/coverage')
    end

    it 'shoud have Required features panel with unselected field by default' do
      subject { visit '/coverage' }
      expect(page).to have_unchecked_field('Voice IN', with: 'voice_in')
      expect(page).to have_unchecked_field('T.38 Fax', with: 't38')
      expect(page).to have_unchecked_field('SMS IN', with: 'sms_in')
    end

    it 'shoud have Country filter field with Select country option by default' do
      subject { visit '/coverage' }
      expect(find('select[name="q[country.id]"]').value).to eq('')
    end

    it 'shoud have Country filter has countries options ' do
      subject { visit '/coverage' }

      expect(page).to have_select('q_country.id', with_options: ['Select country...', did_group_country.name, country.name])
    end

    it 'shoud can be selecteble Required features field' do
      subject { visit '/coverage' }
      check('Voice IN')
      check('T.38 Fax')
      check('SMS IN')

      expect(page).to have_checked_field('Voice IN', with: 'voice_in')
      expect(page).to have_checked_field('T.38 Fax', with: 't38')
      expect(page).to have_checked_field('SMS IN', with: 'sms_in')

    end

    it 'shoud have Number Types panel with selected field by default' do
      subject { visit '/coverage' }

      expect(page).to have_checked_field('Global', with: did_group_type_global.id)
      expect(page).to have_checked_field('Local', with: did_group_type_local.id)
      expect(page).to have_checked_field('Mobile', with: did_group_type_mobile.id)
      expect(page).to have_checked_field('National', with: did_group_type_national.id)
      expect(page).to have_checked_field('Shared Cost', with: did_group_type_shared_cost.id)
      expect(page).to have_checked_field('Toll-free', with: did_group_type_toll_free.id)
    end

    context 'Coverage list' do

      it 'shoud have setup_price and monthly_price for included channels' do
        subject { visit '/coverage' }

        puts "\nSKU ID: #{sku.id}"
        puts "SKU setup_price: #{sku.setup_price}"
        puts "SKU monthly_price: #{sku.monthly_price}"
        puts "SKU channels_included_count: #{sku.channels_included_count}"

        select sku.channels_included_count, from: 'order[items_attributes][][sku_id]'
        expect(page).to have_select('order[items_attributes][][sku_id]', selected: '0')
      end
      it 'displays the available did group' do
        subject { visit '/coverage' }

        expect(page).to have_css('table tbody tr', count: 1)
        expect(page).to have_css('td', text: '380-632')
        expect(page).to have_css('td', text: 'Ukraine')
        expect(page).to have_css('td', text: 'Life')
        expect(page).to have_css('td', text: 'Mobile')
        expect(page).to have_css('td', text: 'Not Required')
        expect(page).to have_css('td', text: '✓')
        expect(page).to have_css('td', text: '✗   ✓   ✗')
        expect(page).to have_css('td', text: '✓')
        expect(page).to have_css('td', text: 'No')
        expect(page).to have_css('td', text: '0')

        select sku.channels_included_count, from: 'order[items_attributes][][sku_id]'
        expect(page).to have_select('order[items_attributes][][sku_id]', selected: '0')
        expect(page).to have_css('option[data-nrc="1.23"][data-mrc="4.56"]', text: '0')
        #expect(page).to have_css('td', text: '1.23')
        #expect(page).to have_css('td', text: '4.56')
        #expect(page).to have_css('td', text: '1')
      end
    end
  end
end
