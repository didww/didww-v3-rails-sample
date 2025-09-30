# frozen_string_literal: true

RSpec.describe 'Coverage', type: :feature, js: true do

  RSpec.shared_context 'with a logged-in user', type: :feature, js: true do
    let(:dummy_api_key) { 'dummy_api_key' }

    before do
      page.set_rack_session(api_key: dummy_api_key, cached_balance: { balance: 1000 })
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
          }).to_return(status: 200, body: did_groups_ua_usa_response_body.to_json, headers: response_headers)

      WebMock.stub_request(:get, 'https://sandbox-api.didww.com/v3/did_groups').
        with(
          query: {
            'filter[country.id]' => ua_country.id,
            'include' => 'country,city,region,did_group_type,stock_keeping_units,requirement',
            'page[number]' => '1',
            'page[size]' => '10',
            'sort' => 'area_name'
          },
          headers: {
	          'Accept'=>'application/vnd.api+json',
	          'Accept-Encoding'=>'gzip,deflate',
	          'Content-Type'=>'application/vnd.api+json',
	          'User-Agent'=>'didww-v3 Ruby gem v4.1.0',
	          'X-Didww-Api-Version'=>'2022-05-10'
          }).to_return(status: 200, body: did_groups_ua_country_response_body.to_json, headers: response_headers)

      WebMock.stub_request(:get, 'https://sandbox-api.didww.com/v3/did_groups').
        with(
          query: {
            'filter[country.id]' => ua_country.id,
            'filter[did_group_type.id]' => did_group_type_mobile.name,
            'include' => 'country,city,region,did_group_type,stock_keeping_units,requirement',
            'page[number]' => '1',
            'page[size]' => '10',
            'sort' => 'area_name'
          },
          headers: {
	          'Accept'=>'application/vnd.api+json',
	          'Accept-Encoding'=>'gzip,deflate',
	          'Content-Type'=>'application/vnd.api+json',
	          'User-Agent'=>'didww-v3 Ruby gem v4.1.0',
	          'X-Didww-Api-Version'=>'2022-05-10'
          }).to_return(status: 200, body: did_groups_ua_country_response_body.to_json, headers: response_headers)
    end

    let(:us_country) { double('Country', id: SecureRandom.uuid, name: 'United States', prefix: '1', iso: 'US') }
    let(:ua_country) { double('Country', id: SecureRandom.uuid, name: 'Ukraine', prefix: '380', iso: 'UA') }
    let(:countries) { double('countries', [us_country, ua_country] ) }

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
                  id: us_country.id,
                  type: 'countries'
                }
              },
            }
          }
        ],
        included: [
          {
            id: us_country.id,
            type: 'countries',
            attributes: {
              name: us_country.name,
              prefix: us_country.prefix,
              iso_code: us_country.iso
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
              id: ua_country.id,
              type: 'countries',
              attributes: {
                name: ua_country.name,
                prefix: ua_country.prefix,
                iso: ua_country.iso
              }
            },
            {
              id: us_country.id,
              type: 'countries',
              attributes: {
                name: us_country.name,
                prefix: us_country.prefix,
                iso: us_country.iso
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

    let(:ua_sku) { double('ua_sku', id: SecureRandom.uuid, setup_price: '1.23', monthly_price: '4.56', channels_included_count: '0') }
    let(:us_sku) { double('us_sku', id: SecureRandom.uuid, setup_price: '1.11', monthly_price: '2.22', channels_included_count: '5') }

    let(:ua_did_group) { double('DidGroupUA', id: SecureRandom.uuid, prefix: '632', local_prefix: '', features: ['voice', 'voice_out', 't38'], is_metered: true, area_name:'Life') }
    let(:us_did_group) { double('DidGroupUS', id: SecureRandom.uuid, prefix: '518', local_prefix: '', features: ['voice', 'voice_out'], is_metered: false, area_name:'Albany') }

    let(:ua_requirement) { double('RequirementUA', id: SecureRandom.uuid, identity_type: 'Any', personal_area_level: 'WorldWide', business_area_level: 'null', address_area_level: 'WorldWide', personal_proof_qty: 1, business_proof_qty: 0, address_proof_qty: 0, personal_mandatory_fields: 'null', business_mandatory_fields: 'null', service_description_required: false, restriction_message: 'Ukrainian Local DID registration requirement') }

    let(:did_groups_ua_country_response_body) do
      {
        data: [
          {
            id: ua_did_group.id,
            type: 'did_groups',
            attributes: {
              prefix: ua_did_group.prefix,
              local_prefix: ua_did_group.local_prefix,
              features: ua_did_group.features,
              is_metered: ua_did_group.is_metered,
              area_name: ua_did_group.area_name,
              allow_additional_channels: false
            },
            relationships: {
              country: {
                data: {
                  id: ua_country.id,
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
                    id: ua_sku.id
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
            id: ua_country.id,
            type: 'countries',
            attributes: {
              name: ua_country.name,
              prefix: ua_country.prefix,
              iso: ua_country.iso
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
            id: ua_sku.id,
            type: 'stock_keeping_units',
            attributes: {
              setup_price: ua_sku.setup_price,
              monthly_price: ua_sku.monthly_price,
              channels_included_count: ua_sku.channels_included_count
            }
          },
          {
            id: ua_requirement.id,
            type: 'requirements',
            attributes: {
                identity_type: ua_requirement.identity_type,
                personal_area_level: ua_requirement.personal_area_level,
                business_area_level: ua_requirement.business_area_level,
                address_area_level: ua_requirement.address_area_level,
                personal_proof_qty: ua_requirement.personal_proof_qty,
                business_proof_qty: ua_requirement.business_proof_qty,
                address_proof_qty: ua_requirement.address_proof_qty,
                personal_mandatory_fields: ua_requirement.personal_mandatory_fields,
                business_mandatory_fields: ua_requirement.business_mandatory_fields,
                service_description_required: ua_requirement.service_description_required,
                restriction_message: ua_requirement.restriction_message
          }
        }
        ],
        meta: {
        total_records: '1',
        api_version: '2022-05-10'
        }
      }
    end
    let(:did_groups_ua_usa_response_body) do
      {
        data: [
          {
            id: ua_did_group.id,
            type: 'did_groups',
            attributes: {
              prefix: ua_did_group.prefix,
              local_prefix: ua_did_group.local_prefix,
              features: ua_did_group.features,
              is_metered: ua_did_group.is_metered,
              area_name: ua_did_group.area_name,
              allow_additional_channels: false
            },
            relationships: {
              country: {
                data: {
                  id: ua_country.id,
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
                    id: ua_sku.id
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
          },
          {
            id: us_did_group.id,
            type: 'did_groups',
            attributes: {
              prefix: us_did_group.prefix,
              local_prefix: us_did_group.local_prefix,
              features: us_did_group.features,
              is_metered: us_did_group.is_metered,
              area_name: us_did_group.area_name,
              allow_additional_channels: true
            },
            relationships: {
              country: {
                data: {
                  id: us_country.id,
                  type: 'countries'
                }
              },
              did_group_type:{
                data: {
                  type: 'did_group_types',
                  id: did_group_type_local.id
                }
              },
              stock_keeping_units: {
                data: [
                  {
                    type: 'stock_keeping_units',
                    id: us_sku.id
                  }
                ]
              }
            },
            meta: {
                available_dids_enabled: false,
                needs_registration: false,
                is_available: true,
                total_count: 5
            }
        }],
        included: [
          {
            id: ua_country.id,
            type: 'countries',
            attributes: {
              name: ua_country.name,
              prefix: ua_country.prefix,
              iso: ua_country.iso
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
            id: ua_sku.id,
            type: 'stock_keeping_units',
            attributes: {
              setup_price: ua_sku.setup_price,
              monthly_price: ua_sku.monthly_price,
              channels_included_count: ua_sku.channels_included_count
            }
          },
          {
            id: us_country.id,
            type: 'countries',
            attributes: {
              name: us_country.name,
              prefix: us_country.prefix,
              iso: us_country.iso
            }
          },
          {
            id: did_group_type_local.id,
            type: 'did_group_types',
            attributes: {
              name: did_group_type_local.name,
            }
          },
          {
            id: us_sku.id,
            type: 'stock_keeping_units',
            attributes: {
              setup_price: us_sku.setup_price,
              monthly_price: us_sku.monthly_price,
              channels_included_count: us_sku.channels_included_count
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

    context 'Coverage filters block' do

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

      it 'shoud have Country filter field without option by default' do
        subject { visit '/coverage' }

        expect(find('select[name="q[country.id]"]').value).to eq('')
      end

      it 'shoud have Country filter with countries options' do
        subject { visit '/coverage' }

        expect(page).to have_select('q_country.id', with_options: ['Select country...', ua_country.name, us_country.name])
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

      it 'shoud have Metered filter without by defalt' do
        subject { visit '/coverage' }

        expect(find('select[name="q[is_metered]"]').value).to eq('')
      end

      it 'shoud have Metered filter with options' do
        subject { visit '/coverage' }

        expect(page).to have_select('q[is_metered]', with_options: ['any', 'Yes', 'No'])
      end

      it 'shoud have Allows additional channels filter without by defalt' do
        subject { visit '/coverage' }

        expect(find('select[name="q[allow_additional_channels]"]').value).to eq('')
      end

      it 'shoud have Allows additional channels filter with options' do
        subject { visit '/coverage' }

        expect(page).to have_select('q[allow_additional_channels]', with_options: ['any', 'Yes', 'No'])
      end

      it 'shoud have Registration filter without by defalt' do
        subject { visit '/coverage' }

        expect(find('select[name="q[needs_registration]"]').value).to eq('')
      end

      it 'shoud have Registration filter with options' do
        subject { visit '/coverage' }

        expect(page).to have_select('q[needs_registration]', with_options: ['any', 'Required', 'Not Required'])
      end

      it 'shoud have Availability filter without by defalt' do
        subject { visit '/coverage' }

        expect(find('select[name="q[is_available]"]').value).to eq('')
      end

      it 'shoud have Availability filter with options' do
        subject { visit '/coverage' }

        expect(page).to have_select('q[is_available]', with_options: ['any', 'Available', 'Not Available'])
      end

      it 'shoud have Available DIDs feature filter without by defalt' do
        subject { visit '/coverage' }

        expect(find('select[name="q[available_dids_enabled]"]').value).to eq('')
      end

      it 'shoud have Available DIDs feature filter with options' do
        subject { visit '/coverage' }

        expect(page).to have_select('q[available_dids_enabled]', with_options: ['any', 'Available', 'Not Available'])
      end
    end
    context 'Coverage list' do

      it 'shoud have setup_price and monthly_price for included channels for group from Ukraine' do
        subject { visit '/coverage' }

        within("tr[data-did-group-id='#{ua_did_group.id}']") do

          select ua_sku.channels_included_count, from: 'order[items_attributes][][sku_id]'

          expect(page).to have_select('order[items_attributes][][sku_id]', selected: ua_sku.channels_included_count)
          expect(page).to have_css("option[data-nrc=\"#{ua_sku.setup_price}\"][data-mrc=\"#{ua_sku.monthly_price}\"]", text: ua_sku.channels_included_count)
        end
      end

      it 'shoud have setup_price and monthly_price for included channels for group from United States' do
        subject { visit '/coverage' }

        within("tr[data-did-group-id='#{us_did_group.id}']") do

          select us_sku.channels_included_count, from: 'order[items_attributes][][sku_id]'
          expect(page).to have_select('order[items_attributes][][sku_id]', selected: us_sku.channels_included_count)
          expect(page).to have_css("option[data-nrc=\"#{us_sku.setup_price}\"][data-mrc=\"#{us_sku.monthly_price}\"]", text: us_sku.channels_included_count)
        end
      end

      it 'displays the available did group from Ukraine' do
        subject { visit '/coverage' }

        within("tr[data-did-group-id='#{ua_did_group.id}']") do
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

        #expect(page).to have_css('td', text: '1.23')
        #expect(page).to have_css('td', text: '4.56')
        #expect(page).to have_css('td', text: '1')
        end
      end

      it 'displays the available did group from United States' do
        subject { visit '/coverage' }

        within("tr[data-did-group-id='#{us_did_group.id}']") do
        expect(page).to have_css('td', text: '1-518')
        expect(page).to have_css('td', text: 'United States')
        expect(page).to have_css('td', text: 'Albany')
        expect(page).to have_css('td', text: 'Local')
        expect(page).to have_css('td', text: 'Not Required')
        expect(page).to have_css('td', text: '✓')
        expect(page).to have_css('td', text: '✗   ✗   ✗')
        expect(page).to have_css('td', text: '✗')
        expect(page).to have_css('td', text: 'Yes')
        expect(page).to have_css('td', text: '5')

        #expect(page).to have_css('td', text: '1.23')
        #expect(page).to have_css('td', text: '4.56')
        #expect(page).to have_css('td', text: '1')
        end
      end
    end

    context 'Coverage table filtering', :js do
      context 'Coverage Country filter' do
        it 'should be filtered by the Country filter' do

        subject { visit '/coverage' }
        select ua_country.name, from: 'q[country.id]'

        uncheck('Global')
        uncheck('Local')
        uncheck('Mobile')
        uncheck('National')
        uncheck('Shared Cost')
        uncheck('Toll-free')

        click_button 'Search'

        expect(page).to have_css('td', text: 'Ukraine')
        expect(page).not_to have_css('td', text: 'United States')
        end

        before do
        WebMock.stub_request(:get, 'https://sandbox-api.didww.com/v3/did_groups').
        with(
          query: {
            'filter[country.id]' => ua_country.id,
            'filter[did_group_type.id]' => did_group_type_mobile.id,
            'include' => 'country,city,region,did_group_type,stock_keeping_units,requirement',
            'page[number]' => '1',
            'page[size]' => '10',
            'sort' => 'area_name'
          },
          headers: {
	          'Accept'=>'application/vnd.api+json',
	          'Accept-Encoding'=>'gzip,deflate',
	          'Content-Type'=>'application/vnd.api+json',
	          'User-Agent'=>'didww-v3 Ruby gem v4.1.0',
	          'X-Didww-Api-Version'=>'2022-05-10'
          }).to_return(status: 200, body: did_groups_ua_country_response_body.to_json, headers: response_headers)
        end

        it 'should be filtered by the Country and Mobile group type filters' do

        subject { visit '/coverage' }
        select ua_country.name, from: 'q[country.id]'

        uncheck('Global')
        uncheck('Local')
        uncheck('National')
        uncheck('Shared Cost')
        uncheck('Toll-free')

        click_button 'Search'

        expect(page).to have_css('td', text: 'Ukraine')
        expect(page).to have_css('td', text: 'Mobile')
        expect(page).not_to have_css('td', text: 'United States')
        end
      end

      before do
        WebMock.stub_request(:get, 'https://sandbox-api.didww.com/v3/did_groups').
        with(
          query: {
            'filter[did_group_type.id]' => did_group_type_global.id,
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
          }).to_return(status: 200, body: did_groups_not_exist_response_body.to_json, headers: response_headers)
      end

      let(:did_groups_not_exist_response_body) do
          {
          data: []
          }
      end

      it 'should be No entries found for Empty Coverage table' do

        subject { visit '/coverage' }

        uncheck('Mobile')
        uncheck('Local')
        uncheck('National')
        uncheck('Shared Cost')
        uncheck('Toll-free')

        click_button 'Search'

        expect(page).to have_css('.paginate-info', text: 'No entries found')
      end
    end
  end
end
