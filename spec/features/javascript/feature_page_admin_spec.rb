# frozen_string_literal: true

RSpec.describe 'Feature Pages Adminstration', js: true do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:exhibit_curator) { FactoryBot.create(:exhibit_curator, exhibit:) }
  let!(:page1) do
    FactoryBot.create(
      :feature_page,
      title: 'FeaturePage1',
      exhibit:
    )
  end
  let!(:page2) do
    FactoryBot.create(
      :feature_page,
      title: 'FeaturePage2',
      exhibit:,
      display_sidebar: true
    )
  end

  before { login_as exhibit_curator }

  it 'is able to create new pages' do
    visit spotlight.exhibit_dashboard_path(exhibit)

    click_link 'Feature pages'

    add_new_via_button('My New Page')

    expect(page).to have_content 'The feature page was created.'
    expect(page).to have_css('li.dd-item')
    expect(page).to have_css('h3', text: 'My New Page')
  end

  it 'can order the pages' do
    visit spotlight.exhibit_dashboard_path(exhibit)

    click_link 'Feature pages'

    add_new_via_button('FeaturePage3')

    page1 = find('.dd-item', text: 'FeaturePage1').find('.dd-handle')
    page2 = find('.dd-item', text: 'FeaturePage2').find('.dd-handle')
    page1.drag_to(page2)

    click_button('Save changes')
    all_page_items = all('li.dd-item h3')
    expect(all_page_items.map(&:text)).to eq(%w[FeaturePage2 FeaturePage1 FeaturePage3])

    # This save is to make sure the weights are correctly initialized. We expect nothing to change
    click_button('Save changes')
    all_page_items = all('li.dd-item h3')
    expect(all_page_items.map(&:text)).to eq(%w[FeaturePage2 FeaturePage1 FeaturePage3])
  end

  it 'updates the page titles' do
    visit spotlight.exhibit_dashboard_path(exhibit)

    click_link 'Feature pages'
    within("[data-id='#{page1.id}']") do
      within('h3') do
        expect(page).to have_content('FeaturePage1')
        expect(page).to have_css('.title-field', visible: false)
        click_link('FeaturePage1')
        expect(page).to have_css('.title-field', visible: true)
        find('.title-field').set('NewFeaturePage1')
      end
    end
    click_button('Save changes')
    within("[data-id='#{page1.id}']") do
      within('h3') do
        expect(page).to have_content('NewFeaturePage1')
      end
    end
  end

  it 'stays in curation mode if a user has unsaved data' do
    skip('Chromedriver automatically dismisses alerts so this test does not work')

    visit spotlight.edit_exhibit_feature_page_path(page1.exhibit, page1)

    fill_in('Title', with: 'Some Fancy Title')

    page.dismiss_confirm do
      click_link 'Cancel'
    end
    expect(page).to have_no_selector 'a', text: 'Edit'
  end

  it 'stays in curation mode if a user has unsaved contenteditable data' do
    skip('Chromedriver automatically dismisses alerts so this test does not work')

    visit spotlight.edit_exhibit_feature_page_path(page1.exhibit, page1)

    add_widget 'solr_documents'
    content_editable = find('.st-text-block')
    content_editable.set('Some Fancy Text.')

    page.accept_confirm do
      click_link 'Cancel'
    end
    expect(page).to have_no_selector 'a', text: 'Edit'
  end

  it 'does not update the pages list when the user has unsaved changes' do
    visit spotlight.exhibit_dashboard_path(exhibit)

    click_link 'Feature pages'

    within("[data-id='#{page1.id}']") do
      within('h3') do
        expect(page).to have_content('FeaturePage1')
        expect(page).to have_css('.title-field', visible: false)
        click_link('FeaturePage1')
        expect(page).to have_css('.title-field', visible: true)
        find('.title-field').set('NewFancyTitle')
      end
    end

    within '#exhibit-navbar' do
      page.accept_alert do
        click_link 'Home'
      end
    end
    expect(page).to have_no_content('Feature pages were successfully updated.')
    # NOTE: get flash message about unsaved changes
    expect(page).to have_content('Welcome to your new exhibit')

    # ensure page title not changed
    click_link exhibit_curator.email
    within '#user-util-collapse .dropdown' do
      click_link 'Exhibit dashboard'
    end
    click_link 'Feature pages'
    within("[data-id='#{page1.id}']") do
      within('h3') do
        expect(page).to have_content('FeaturePage1') # old title
      end
    end
  end

  it 'is able to update home page titles' do
    visit spotlight.exhibit_dashboard_path(exhibit)

    click_link 'Feature pages'

    within('.home_page') do
      within('h3.card-title') do
        expect(page).to have_content(exhibit.home_page.title)
        expect(page).to have_css('.title-field', visible: false)
        click_link(exhibit.home_page.title)
        expect(page).to have_css('.title-field', visible: true)
        find('.title-field').set('New Home Page Title')
      end
    end

    click_button('Save changes')

    within('.home_page') do
      within('h3.card-title') do
        expect(page).to have_content('New Home Page Title')
      end
    end
  end
end
