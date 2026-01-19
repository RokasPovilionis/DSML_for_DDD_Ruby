# frozen_string_literal: true

require 'spec_helper'
require_relative '../../validators/composition_validator'
require_relative '../../model'
require_relative '../../node'
require_relative '../../edge'
require_relative '../../validation_report'

RSpec.describe DddDiagramParser::Validators::CompositionValidator do
  let(:validator) { described_class.new }
  let(:report) { DddDiagramParser::ValidationReport.new }

  describe '#validate' do
    context 'when composition is AggregateRoot -> Entity' do
      it 'passes validation' do
        agg = DddDiagramParser::Node.new(id: '1', ddd_type: 'aggregate_root', ddd_name: 'Order', props: {})
        entity = DddDiagramParser::Node.new(id: '2', ddd_type: 'entity', ddd_name: 'LineItem', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'composition')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [agg, entity].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
      end
    end

    context 'when composition is AggregateRoot -> ValueObject' do
      it 'passes validation' do
        agg = DddDiagramParser::Node.new(id: '1', ddd_type: 'aggregate_root', ddd_name: 'Order', props: {})
        vo = DddDiagramParser::Node.new(id: '2', ddd_type: 'value_object', ddd_name: 'Money', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'composition')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [agg, vo].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
      end
    end

    context 'when composition source is not aggregate_root' do
      it 'adds an error' do
        service = DddDiagramParser::Node.new(id: '1', ddd_type: 'application_service', ddd_name: 'OrderService',
                                             props: {})
        entity = DddDiagramParser::Node.new(id: '2', ddd_type: 'entity', ddd_name: 'LineItem', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'composition')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [service, entity].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R5_INVALID_COMPOSITION_SOURCE')
      end
    end

    context 'when composition target is not entity or value_object' do
      it 'adds an error' do
        agg = DddDiagramParser::Node.new(id: '1', ddd_type: 'aggregate_root', ddd_name: 'Order', props: {})
        service = DddDiagramParser::Node.new(id: '2', ddd_type: 'application_service', ddd_name: 'OrderService',
                                             props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'composition')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [agg, service].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R5_INVALID_COMPOSITION_TARGET')
      end
    end

    context 'when composition has invalid source and target' do
      it 'adds two errors' do
        service1 = DddDiagramParser::Node.new(id: '1', ddd_type: 'application_service', ddd_name: 'Service1', props: {})
        service2 = DddDiagramParser::Node.new(id: '2', ddd_type: 'application_service', ddd_name: 'Service2', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'composition')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [service1, service2].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(2)
        expect(report.errors.map(&:code)).to contain_exactly(
          'R5_INVALID_COMPOSITION_SOURCE',
          'R5_INVALID_COMPOSITION_TARGET'
        )
      end
    end
  end
end
