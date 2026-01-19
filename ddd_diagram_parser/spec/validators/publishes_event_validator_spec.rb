# frozen_string_literal: true

require 'spec_helper'
require_relative '../../validators/publishes_event_validator'
require_relative '../../model'
require_relative '../../node'
require_relative '../../edge'
require_relative '../../validation_report'

RSpec.describe DddDiagramParser::Validators::PublishesEventValidator do
  let(:validator) { described_class.new }
  let(:report) { DddDiagramParser::ValidationReport.new }

  describe '#validate' do
    context 'when publishes_event is AggregateRoot -> DomainEvent' do
      it 'passes validation' do
        agg = DddDiagramParser::Node.new(id: '1', ddd_type: 'aggregate_root', ddd_name: 'Order', props: {})
        event = DddDiagramParser::Node.new(id: '2', ddd_type: 'domain_event', ddd_name: 'OrderPlaced', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'publishes_event')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [agg, event].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
      end
    end

    context 'when publishes_event source is not aggregate_root' do
      it 'adds an error' do
        service = DddDiagramParser::Node.new(id: '1', ddd_type: 'application_service', ddd_name: 'OrderService',
                                             props: {})
        event = DddDiagramParser::Node.new(id: '2', ddd_type: 'domain_event', ddd_name: 'OrderPlaced', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'publishes_event')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [service, event].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R6_INVALID_PUBLISHES_SOURCE')
      end
    end

    context 'when publishes_event target is not domain_event' do
      it 'adds an error' do
        agg = DddDiagramParser::Node.new(id: '1', ddd_type: 'aggregate_root', ddd_name: 'Order', props: {})
        entity = DddDiagramParser::Node.new(id: '2', ddd_type: 'entity', ddd_name: 'LineItem', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'publishes_event')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [agg, entity].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R6_INVALID_PUBLISHES_TARGET')
      end
    end
  end
end
