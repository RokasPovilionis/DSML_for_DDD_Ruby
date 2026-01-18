# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DddDiagramParser::Model do
  let(:model) { described_class.new(diagram_name: 'Test Diagram') }

  describe '#initialize' do
    it 'sets the diagram name' do
      expect(model.diagram_name).to eq('Test Diagram')
    end

    it 'initializes with empty nodes' do
      expect(model.nodes).to be_empty
    end

    it 'initializes with empty edges' do
      expect(model.edges).to be_empty
    end
  end

  describe '#add_node' do
    let(:node) do
      DddDiagramParser::Node.new(
        id: 'n1',
        ddd_type: 'aggregate_root',
        ddd_name: 'Order'
      )
    end

    it 'adds node to the model' do
      model.add_node(node)
      expect(model.nodes.count).to eq(1)
    end

    it 'indexes node by id' do
      model.add_node(node)
      expect(model.node('n1')).to eq(node)
    end
  end

  describe '#add_edge' do
    let(:edge) do
      DddDiagramParser::Edge.new(
        id: 'e1',
        relation_type: 'uses',
        source_id: 'n1',
        target_id: 'n2'
      )
    end

    it 'adds edge to the model' do
      model.add_edge(edge)
      expect(model.edges.count).to eq(1)
    end
  end

  describe 'query methods' do
    before do
      model.add_node(DddDiagramParser::Node.new(
                       id: 'n1',
                       ddd_type: 'aggregate_root',
                       ddd_name: 'Order'
                     ))
      model.add_node(DddDiagramParser::Node.new(
                       id: 'n2',
                       ddd_type: 'application_service',
                       ddd_name: 'PlaceOrder'
                     ))
      model.add_edge(DddDiagramParser::Edge.new(
                       id: 'e1',
                       relation_type: 'uses',
                       source_id: 'n2',
                       target_id: 'n1'
                     ))
    end

    describe '#nodes_by_type' do
      it 'returns nodes of specified type' do
        aggregates = model.nodes_by_type('aggregate_root')
        expect(aggregates.count).to eq(1)
        expect(aggregates.first.ddd_name).to eq('Order')
      end
    end

    describe '#nodes_by_name' do
      it 'returns nodes with specified name' do
        nodes = model.nodes_by_name('Order')
        expect(nodes.count).to eq(1)
        expect(nodes.first.ddd_type).to eq('aggregate_root')
      end
    end

    describe '#edges_from' do
      it 'returns edges originating from node' do
        edges = model.edges_from('n2')
        expect(edges.count).to eq(1)
        expect(edges.first.target_id).to eq('n1')
      end
    end

    describe '#edges_to' do
      it 'returns edges pointing to node' do
        edges = model.edges_to('n1')
        expect(edges.count).to eq(1)
        expect(edges.first.source_id).to eq('n2')
      end
    end

    describe '#edges_for' do
      it 'returns all edges connected to node' do
        edges = model.edges_for('n1')
        expect(edges.count).to eq(1)
      end
    end

    describe '#stats' do
      it 'returns model statistics' do
        stats = model.stats
        expect(stats[:nodes_count]).to eq(2)
        expect(stats[:edges_count]).to eq(1)
        expect(stats[:nodes_by_type]['aggregate_root']).to eq(1)
        expect(stats[:edges_by_type]['uses']).to eq(1)
      end
    end
  end
end
