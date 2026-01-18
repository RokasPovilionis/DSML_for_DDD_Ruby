# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DddDiagramParser::Node do
  let(:node) do
    described_class.new(
      id: 'n1',
      ddd_type: 'aggregate_root',
      ddd_name: 'Order',
      props: { 'id_type' => 'uuid', 'rails_resource' => true },
      raw_label: '<<aggregate root>> Order'
    )
  end

  describe '#initialize' do
    it 'sets the id' do
      expect(node.id).to eq('n1')
    end

    it 'sets the ddd_type' do
      expect(node.ddd_type).to eq('aggregate_root')
    end

    it 'sets the ddd_name' do
      expect(node.ddd_name).to eq('Order')
    end

    it 'sets the props' do
      expect(node.props).to include('id_type' => 'uuid')
    end

    it 'sets the raw_label' do
      expect(node.raw_label).to eq('<<aggregate root>> Order')
    end
  end

  describe '#[]' do
    it 'retrieves property value by string key' do
      expect(node['id_type']).to eq('uuid')
    end

    it 'retrieves property value by symbol key' do
      expect(node[:id_type]).to eq('uuid')
    end
  end

  describe '#has_property?' do
    it 'returns true for existing property' do
      expect(node.has_property?('id_type')).to be true
    end

    it 'returns false for non-existing property' do
      expect(node.has_property?('nonexistent')).to be false
    end
  end

  describe '#property_keys' do
    it 'returns all property keys' do
      expect(node.property_keys).to include('id_type', 'rails_resource')
    end
  end
end
