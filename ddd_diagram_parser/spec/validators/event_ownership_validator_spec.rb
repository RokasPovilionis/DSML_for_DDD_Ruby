# frozen_string_literal: true

require 'spec_helper'
require_relative '../../validators/event_ownership_validator'
require_relative '../../model'
require_relative '../../node'
require_relative '../../edge'
require_relative '../../validation_report'

RSpec.describe DddDiagramParser::Validators::EventOwnershipValidator do
  let(:validator) { described_class.new }
  let(:report) { DddDiagramParser::ValidationReport.new }

  describe '#validate' do
    context 'when event has valid bounded_context and single publisher' do
      it 'passes validation' do
        bc = DddDiagramParser::Node.new(id: '1', ddd_type: 'bounded_context', ddd_name: 'Sales', props: {})
        agg = DddDiagramParser::Node.new(id: '2', ddd_type: 'aggregate_root', ddd_name: 'Order', props: {})
        event = DddDiagramParser::Node.new(id: '3', ddd_type: 'domain_event', ddd_name: 'OrderPlaced',
                                           props: { 'bounded_context' => 'Sales' })
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '2', target_id: '3', relation_type: 'publishes_event')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [bc, agg, event].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
        expect(report.warnings).to be_empty
      end
    end

    context 'when event is missing bounded_context property' do
      it 'adds an error' do
        event = DddDiagramParser::Node.new(id: '3', ddd_type: 'domain_event', ddd_name: 'OrderPlaced', props: {})
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [event].each { |n| m.add_node(n) }
          [].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R13_MISSING_BOUNDED_CONTEXT')
      end
    end

    context 'when event references non-existent bounded context' do
      it 'adds an error' do
        event = DddDiagramParser::Node.new(id: '3', ddd_type: 'domain_event', ddd_name: 'OrderPlaced',
                                           props: { 'bounded_context' => 'NonExistent' })
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [event].each { |n| m.add_node(n) }
          [].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R13_INVALID_BOUNDED_CONTEXT')
      end
    end

    context 'when event is not published by any aggregate' do
      it 'adds a warning' do
        bc = DddDiagramParser::Node.new(id: '1', ddd_type: 'bounded_context', ddd_name: 'Sales', props: {})
        event = DddDiagramParser::Node.new(id: '3', ddd_type: 'domain_event', ddd_name: 'OrderPlaced',
                                           props: { 'bounded_context' => 'Sales' })
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [bc, event].each { |n| m.add_node(n) }
          [].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
        expect(report.warnings.count).to eq(1)
        expect(report.warnings.first.code).to eq('R13_EVENT_NOT_PUBLISHED')
      end
    end

    context 'when event is published by multiple aggregates' do
      it 'adds an error' do
        bc = DddDiagramParser::Node.new(id: '1', ddd_type: 'bounded_context', ddd_name: 'Sales', props: {})
        agg1 = DddDiagramParser::Node.new(id: '2', ddd_type: 'aggregate_root', ddd_name: 'Order', props: {})
        agg2 = DddDiagramParser::Node.new(id: '4', ddd_type: 'aggregate_root', ddd_name: 'Product', props: {})
        event = DddDiagramParser::Node.new(id: '3', ddd_type: 'domain_event', ddd_name: 'OrderPlaced',
                                           props: { 'bounded_context' => 'Sales' })
        edge1 = DddDiagramParser::Edge.new(id: 'e1', source_id: '2', target_id: '3', relation_type: 'publishes_event')
        edge2 = DddDiagramParser::Edge.new(id: 'e2', source_id: '4', target_id: '3', relation_type: 'publishes_event')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [bc, agg1, agg2, event].each { |n| m.add_node(n) }
          [edge1, edge2].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R13_MULTIPLE_EVENT_PUBLISHERS')
        expect(report.errors.first.message).to include('Order, Product')
      end
    end
  end
end
