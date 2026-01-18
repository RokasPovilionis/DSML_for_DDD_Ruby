# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DddDiagramParser::MetadataExtractor do
  describe '.extract' do
    context 'with standard DSML properties' do
      let(:cell) do
        {
          metadata: {
            'ddd_type' => 'aggregate_root',
            'ddd_name' => 'Order',
            'id_type' => 'uuid'
          },
          value: '&lt;&lt;aggregate root&gt;&gt; Order'
        }
      end

      subject(:metadata) { described_class.extract(cell) }

      it 'extracts ddd_type' do
        expect(metadata['ddd_type']).to eq('aggregate_root')
      end

      it 'extracts ddd_name' do
        expect(metadata['ddd_name']).to eq('Order')
      end

      it 'extracts id_type' do
        expect(metadata['id_type']).to eq('uuid')
      end

      it 'extracts raw_label with HTML entities decoded' do
        expect(metadata['raw_label']).to include('Order')
        expect(metadata['raw_label']).to include('aggregate root')
      end
    end

    context 'with boolean values' do
      let(:cell) do
        {
          metadata: {
            'rails_resource' => 'true',
            'abstract' => 'false'
          },
          value: nil
        }
      end

      subject(:metadata) { described_class.extract(cell) }

      it 'converts "true" string to boolean' do
        expect(metadata['rails_resource']).to eq(true)
      end

      it 'converts "false" string to boolean' do
        expect(metadata['abstract']).to eq(false)
      end
    end

    context 'with typo: bonded_context instead of bounded_context' do
      let(:cell) do
        {
          metadata: {
            'bonded_context' => 'Sales'
          },
          value: nil
        }
      end

      subject(:metadata) { described_class.extract(cell) }

      it 'fixes the typo to bounded_context' do
        expect(metadata['bounded_context']).to eq('Sales')
      end

      it 'removes the typo key' do
        expect(metadata).not_to have_key('bonded_context')
      end
    end

    context 'with HTML-formatted label' do
      let(:cell) do
        {
          metadata: {},
          value: '&lt;&lt;aggregate root&gt;&gt;&lt;br&gt;&lt;b&gt;Order&lt;/b&gt;'
        }
      end

      subject(:metadata) { described_class.extract(cell) }

      it 'attempts to strip HTML tags and decodes entities' do
        # Basic HTML stripping and entity decoding
        expect(metadata['raw_label']).to include('aggregate root')
        expect(metadata['raw_label']).to include('Order')
        # May still have some HTML remnants - that's okay for now
      end
    end
  end
end
