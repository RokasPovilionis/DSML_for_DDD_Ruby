# frozen_string_literal: true

require 'spec_helper'
require_relative '../../validators/integration_validator'
require_relative '../../model'
require_relative '../../node'
require_relative '../../edge'
require_relative '../../validation_report'

RSpec.describe DddDiagramParser::Validators::IntegrationValidator do
  let(:validator) { described_class.new }
  let(:report) { DddDiagramParser::ValidationReport.new }

  describe '#validate' do
    context 'when integration is ApplicationService -> ExternalSystem' do
      it 'passes validation' do
        service = DddDiagramParser::Node.new(id: '1', ddd_type: 'application_service', ddd_name: 'OrderService',
                                             props: {})
        external = DddDiagramParser::Node.new(id: '2', ddd_type: 'external_system', ddd_name: 'PaymentGateway',
                                              props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'integration')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [service, external].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
        expect(report.warnings).to be_empty
      end
    end

    context 'when integration is BoundedContext -> ExternalSystem' do
      it 'passes validation' do
        bc = DddDiagramParser::Node.new(id: '1', ddd_type: 'bounded_context', ddd_name: 'Sales', props: {})
        external = DddDiagramParser::Node.new(id: '2', ddd_type: 'external_system', ddd_name: 'PaymentGateway',
                                              props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'integration')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [bc, external].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
        expect(report.warnings).to be_empty
      end
    end

    context 'when integration target is not external_system' do
      it 'adds an error' do
        service = DddDiagramParser::Node.new(id: '1', ddd_type: 'application_service', ddd_name: 'OrderService',
                                             props: {})
        entity = DddDiagramParser::Node.new(id: '2', ddd_type: 'entity', ddd_name: 'LineItem', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'integration')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [service, entity].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R9_INVALID_INTEGRATION_TARGET')
      end
    end

    context 'when integration source is unusual (not service or BC)' do
      it 'adds a warning' do
        entity = DddDiagramParser::Node.new(id: '1', ddd_type: 'entity', ddd_name: 'Order', props: {})
        external = DddDiagramParser::Node.new(id: '2', ddd_type: 'external_system', ddd_name: 'PaymentGateway',
                                              props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'integration')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [entity, external].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
        expect(report.warnings.count).to eq(1)
        expect(report.warnings.first.code).to eq('R9_UNUSUAL_INTEGRATION_SOURCE')
      end
    end
  end
end
