# frozen_string_literal: true

require 'spec_helper'
require_relative '../../validators/consumes_event_validator'
require_relative '../../model'
require_relative '../../node'
require_relative '../../edge'
require_relative '../../validation_report'

RSpec.describe DddDiagramParser::Validators::ConsumesEventValidator do
  let(:validator) { described_class.new }
  let(:report) { DddDiagramParser::ValidationReport.new }

  describe '#validate' do
    context 'when consumes_event is DomainEvent -> ApplicationService' do
      it 'passes validation' do
        event = DddDiagramParser::Node.new(id: '1', ddd_type: 'domain_event', ddd_name: 'OrderPlaced', props: {})
        service = DddDiagramParser::Node.new(id: '2', ddd_type: 'application_service', ddd_name: 'OrderService',
                                             props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'consumes_event')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [event, service].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
      end
    end

    context 'when consumes_event is DomainEvent -> DomainService' do
      it 'passes validation' do
        event = DddDiagramParser::Node.new(id: '1', ddd_type: 'domain_event', ddd_name: 'OrderPlaced', props: {})
        service = DddDiagramParser::Node.new(id: '2', ddd_type: 'domain_service', ddd_name: 'PricingService', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'consumes_event')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [event, service].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
      end
    end

    context 'when consumes_event source is not domain_event' do
      it 'adds an error' do
        agg = DddDiagramParser::Node.new(id: '1', ddd_type: 'aggregate_root', ddd_name: 'Order', props: {})
        service = DddDiagramParser::Node.new(id: '2', ddd_type: 'application_service', ddd_name: 'OrderService',
                                             props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'consumes_event')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [agg, service].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R7_INVALID_CONSUMES_SOURCE')
      end
    end

    context 'when consumes_event target is not a service' do
      it 'adds an error' do
        event = DddDiagramParser::Node.new(id: '1', ddd_type: 'domain_event', ddd_name: 'OrderPlaced', props: {})
        entity = DddDiagramParser::Node.new(id: '2', ddd_type: 'entity', ddd_name: 'LineItem', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'consumes_event')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [event, entity].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R7_INVALID_CONSUMES_TARGET')
      end
    end
  end
end
