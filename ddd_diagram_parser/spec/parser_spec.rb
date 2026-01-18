# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DddDiagramParser::Parser do
  let(:example_file) do
    File.join(__dir__, '../../examples/sales_example/model.drawio.xml')
  end

  describe '.parse' do
    subject(:model) { described_class.parse(example_file) }

    it 'returns a Model instance' do
      expect(model).to be_a(DddDiagramParser::Model)
    end

    it 'parses the correct number of nodes' do
      expect(model.nodes.count).to eq(3)
    end

    it 'parses the correct number of edges' do
      expect(model.edges.count).to eq(1)
    end

    it 'sets the diagram name' do
      expect(model.diagram_name).to eq('Page-1')
    end

    context 'when file does not exist' do
      it 'raises an error' do
        expect { described_class.parse('nonexistent.drawio') }.to raise_error
      end
    end
  end

  describe 'parsed nodes' do
    subject(:model) { described_class.parse(example_file) }

    describe 'bounded context node' do
      let(:bc_node) { model.nodes_by_type('bounded_context').first }

      it 'has correct type' do
        expect(bc_node.ddd_type).to eq('bounded_context')
      end

      it 'has correct name' do
        expect(bc_node.ddd_name).to eq('Sales')
      end

      it 'has context_key property' do
        expect(bc_node['context_key']).to eq('sales')
      end
    end

    describe 'application service node' do
      let(:service_node) { model.nodes_by_type('application_service').first }

      it 'has correct type' do
        expect(service_node.ddd_type).to eq('application_service')
      end

      it 'has correct name' do
        expect(service_node.ddd_name).to eq('PlaceOrder')
      end

      it 'has bounded_context property' do
        expect(service_node['bounded_context']).to eq('Sales')
      end

      it 'has exposed_as property' do
        expect(service_node['exposed_as']).to eq('rest')
      end
    end

    describe 'aggregate root node' do
      let(:aggregate_node) { model.nodes_by_type('aggregate_root').first }

      it 'has correct type' do
        expect(aggregate_node.ddd_type).to eq('aggregate_root')
      end

      it 'has correct name' do
        expect(aggregate_node.ddd_name).to eq('Order')
      end

      it 'has id_type property' do
        expect(aggregate_node['id_type']).to eq('uuid')
      end

      it 'has rails_resource property as boolean' do
        expect(aggregate_node['rails_resource']).to eq(true)
      end

      it 'has bounded_context property' do
        expect(aggregate_node['bounded_context']).to eq('Sales')
      end
    end
  end

  describe 'parsed edges' do
    subject(:model) { described_class.parse(example_file) }

    let(:edge) { model.edges.first }

    it 'has correct relation_type' do
      expect(edge.relation_type).to eq('uses')
    end

    it 'connects PlaceOrder to Order' do
      source = model.node(edge.source_id)
      target = model.node(edge.target_id)

      expect(source.ddd_name).to eq('PlaceOrder')
      expect(target.ddd_name).to eq('Order')
    end
  end
end
