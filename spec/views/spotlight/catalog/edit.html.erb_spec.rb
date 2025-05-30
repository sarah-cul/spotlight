# frozen_string_literal: true

RSpec.describe 'spotlight/catalog/edit.html.erb', type: :view do
  let(:blacklight_config) { Blacklight::Configuration.new }

  let(:document) { stub_model(SolrDocument) }

  before do
    allow(view).to receive_messages(blacklight_config:)
    allow(view).to receive_messages(current_exhibit: stub_model(Spotlight::Exhibit))
    assign(:document, document)
    allow(view).to receive(:document_counter)
    render
  end

  it 'renders a document div' do
    expect(rendered).to have_css '#document.document'
  end
end
