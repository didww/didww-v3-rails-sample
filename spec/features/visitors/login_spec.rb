# frozen_string_literal: true

RSpec.describe 'Sign In', type: :feature, js: true do

  describe 'GET /login' do

    subject { visit '/login' }

    it 'displays Please Sign In title' do
      subject
      expect(page).to have_css('.panel-title', text: 'Please Sign In')
    end

    it 'displays the Login button' do
      subject
      expect(page).to have_selector("input[type=submit][value='Login']")
    end

    it 'displays the Sandbox button' do
      subject
      expect(page).to have_selector("input[type=radio][value='sandbox']")
    end
    it 'displays the Live button' do
      subject
      expect(page).to have_selector("input[type=radio][value='production']")
    end
  end

  context 'API Access required validation' do
    subject { visit '/login' }

    before do
      WebMock.allow_net_connect!
    end

    it 'shows warning alert when API key is missing' do
      subject

      click_button ('Login')
      expect(page).to have_selector('#flash_warning', text: 'You must provide a valid API key.')
      expect(page).to have_selector('.alert.alert-warning')
    end

    it 'shows warning alert when API key is invalid' do
      subject

      fill_in 'API key', with: 'test_api_key'
      click_button ('Login')

      expect(page).to have_selector('.alert.alert-danger')
      expect(page).to have_selector('#flash_danger', text: 'Login failed! Check API key and mode.')
    end
  end
end
