# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DddDiagramParser::Edge do
  let(:edge) do
    described_class.new(
      id: 'e1',
      relation_type: 'uses',
      source_id: 'n1',
      target_id: 'n2',
      props: { 'cardinality' => '1..*' },
      raw_label: 'Uses'
    )
  end

  describe '#initialize' do
    it 'sets the id' do
      expect(edge.id).to eq('e1')
    end

    it 'sets the relation_type' do
      expect(edge.relation_type).to eq('uses')
    end

    it 'sets the source_id' do
      expect(edge.source_id).to eq('n1')
    end

    it 'sets the target_id' do
      expect(edge.target_id).to eq('n2')
    end

    it 'sets the props' do
      expect(edge.props).to include('cardinality' => '1..*')
    end

    it 'sets the raw_label' do
      expect(edge.raw_label).to eq('Uses')
    end
  end

  describe '#[]' do
    it 'retrieves property value by string key' do
      expect(edge['cardinality']).to eq('1..*')
    end

    it 'retrieves property value by symbol key' do
      expect(edge[:cardinality]).to eq('1..*')
    end
  end

  describe '#has_property?' do
    it 'returns true for existing property' do
      expect(edge.has_property?('cardinality')).to be true
    end

    it 'returns false for non-existing property' do
      expect(edge.has_property?('nonexistent')).to be false
    end
  end
end
