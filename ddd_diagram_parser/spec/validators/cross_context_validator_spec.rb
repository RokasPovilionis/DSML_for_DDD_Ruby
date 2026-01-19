# frozen_string_literal: true

require 'spec_helper'
require_relative '../../validators/cross_context_validator'
require_relative '../../model'
require_relative '../../node'
require_relative '../../edge'
require_relative '../../validation_report'

RSpec.describe DddDiagramParser::Validators::CrossContextValidator do
  let(:validator) { described_class.new }
  let(:report) { DddDiagramParser::ValidationReport.new }

  describe '#validate' do
    context 'when relationships are within same bounded context' do
      it 'passes validation' do
        agg1 = DddDiagramParser::Node.new(id: '1', ddd_type: 'aggregate_root', ddd_name: 'Order',
                                          props: { 'bounded_context' => 'Sales' })
        agg2 = DddDiagramParser::Node.new(id: '2', ddd_type: 'aggregate_root', ddd_name: 'Product',
                                          props: { 'bounded_context' => 'Sales' })
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'uses')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [agg1, agg2].each { |n| m.add_node(n) }
          [edge].each do |e|
            m.add_edge(e)
          end
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
        expect(report.warnings).to be_empty
      end
    end

    context 'when integration crosses bounded contexts' do
      it 'allows it without error or warning' do
        service = DddDiagramParser::Node.new(id: '1', ddd_type: 'application_service', ddd_name: 'OrderService',
                                             props: { 'bounded_context' => 'Sales' })
        external = DddDiagramParser::Node.new(id: '2', ddd_type: 'external_system', ddd_name: 'PaymentGateway',
                                              props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'integration')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [service, external].each do |n|
            m.add_node(n)
          end
          [edge].each do |e|
            m.add_edge(e)
          end
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
        expect(report.warnings).to be_empty
      end
    end

    context 'when composition crosses bounded contexts' do
      it 'adds an error' do
        agg1 = DddDiagramParser::Node.new(id: '1', ddd_type: 'aggregate_root', ddd_name: 'Order',
                                          props: { 'bounded_context' => 'Sales' })
        entity = DddDiagramParser::Node.new(id: '2', ddd_type: 'entity', ddd_name: 'Product',
                                            props: { 'bounded_context' => 'Catalog' })
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'composition')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [agg1, entity].each { |n| m.add_node(n) }
          [edge].each do |e|
            m.add_edge(e)
          end
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R14_CROSS_CONTEXT_COMPOSITION')
        expect(report.errors.first.message).to include('Sales → Catalog')
      end
    end

    context 'when association crosses bounded contexts' do
      it 'adds an error' do
        agg1 = DddDiagramParser::Node.new(id: '1', ddd_type: 'aggregate_root', ddd_name: 'Order',
                                          props: { 'bounded_context' => 'Sales' })
        agg2 = DddDiagramParser::Node.new(id: '2', ddd_type: 'aggregate_root', ddd_name: 'Product',
                                          props: { 'bounded_context' => 'Catalog' })
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'association')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [agg1, agg2].each { |n| m.add_node(n) }
          [edge].each do |e|
            m.add_edge(e)
          end
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R14_CROSS_CONTEXT_COMPOSITION')
      end
    end

    context 'when uses crosses bounded contexts' do
      it 'adds a warning' do
        service1 = DddDiagramParser::Node.new(id: '1', ddd_type: 'application_service', ddd_name: 'OrderService',
                                              props: { 'bounded_context' => 'Sales' })
        service2 = DddDiagramParser::Node.new(id: '2', ddd_type: 'application_service', ddd_name: 'InventoryService',
                                              props: { 'bounded_context' => 'Inventory' })
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'uses')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [service1, service2].each do |n|
            m.add_node(n)
          end
          [edge].each do |e|
            m.add_edge(e)
          end
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
        expect(report.warnings.count).to eq(1)
        expect(report.warnings.first.code).to eq('R14_CROSS_CONTEXT_USES')
      end
    end

    context 'when event relationship crosses bounded contexts' do
      it 'adds a warning' do
        agg = DddDiagramParser::Node.new(id: '1', ddd_type: 'aggregate_root', ddd_name: 'Order',
                                         props: { 'bounded_context' => 'Sales' })
        event = DddDiagramParser::Node.new(id: '2', ddd_type: 'domain_event', ddd_name: 'OrderPlaced',
                                           props: { 'bounded_context' => 'Shipping' })
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'publishes_event')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [agg, event].each { |n| m.add_node(n) }
          [edge].each do |e|
            m.add_edge(e)
          end
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
        expect(report.warnings.count).to eq(1)
        expect(report.warnings.first.code).to eq('R14_CROSS_CONTEXT_EVENT')
      end
    end

    context 'when repository access crosses bounded contexts' do
      it 'adds an error' do
        service = DddDiagramParser::Node.new(id: '1', ddd_type: 'application_service', ddd_name: 'OrderService',
                                             props: { 'bounded_context' => 'Sales' })
        repo = DddDiagramParser::Node.new(id: '2', ddd_type: 'repository', ddd_name: 'ProductRepository',
                                          props: { 'bounded_context' => 'Catalog' })
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'repository_access')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [service, repo].each { |n| m.add_node(n) }
          [edge].each do |e|
            m.add_edge(e)
          end
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R14_CROSS_CONTEXT_REPOSITORY')
      end
    end

    context 'when node is a bounded context itself' do
      it 'uses the BC name as its context' do
        bc1 = DddDiagramParser::Node.new(id: '1', ddd_type: 'bounded_context', ddd_name: 'Sales', props: {})
        bc2 = DddDiagramParser::Node.new(id: '2', ddd_type: 'bounded_context', ddd_name: 'Inventory', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'uses')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [bc1, bc2].each { |n| m.add_node(n) }
          [edge].each do |e|
            m.add_edge(e)
          end
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
        expect(report.warnings.count).to eq(1)
        expect(report.warnings.first.code).to eq('R14_CROSS_CONTEXT_USES')
      end
    end
  end
end
