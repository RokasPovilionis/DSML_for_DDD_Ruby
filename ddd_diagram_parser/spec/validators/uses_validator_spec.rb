# frozen_string_literal: true

require 'spec_helper'
require_relative '../../validators/uses_validator'
require_relative '../../model'
require_relative '../../node'
require_relative '../../edge'
require_relative '../../validation_report'

RSpec.describe DddDiagramParser::Validators::UsesValidator do
  let(:validator) { described_class.new }
  let(:report) { DddDiagramParser::ValidationReport.new }

  describe '#validate' do
    context 'when uses targets an aggregate_root' do
      it 'passes validation' do
        service = DddDiagramParser::Node.new(id: '1', ddd_type: 'application_service', ddd_name: 'OrderService',
                                             props: {})
        agg = DddDiagramParser::Node.new(id: '2', ddd_type: 'aggregate_root', ddd_name: 'Order', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'uses')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [service, agg].each { |n| m.add_node(n) }
          [edge].each do |e|
            m.add_edge(e)
          end
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
        expect(report.warnings).to be_empty
      end
    end

    context 'when uses targets an application_service' do
      it 'passes validation' do
        service1 = DddDiagramParser::Node.new(id: '1', ddd_type: 'application_service', ddd_name: 'OrderService',
                                              props: {})
        service2 = DddDiagramParser::Node.new(id: '2', ddd_type: 'application_service', ddd_name: 'InventoryService',
                                              props: {})
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
        expect(report.warnings).to be_empty
      end
    end

    context 'when uses targets a domain_service' do
      it 'passes validation' do
        app_service = DddDiagramParser::Node.new(id: '1', ddd_type: 'application_service', ddd_name: 'OrderService',
                                                 props: {})
        domain_service = DddDiagramParser::Node.new(id: '2', ddd_type: 'domain_service', ddd_name: 'PricingService',
                                                    props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'uses')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [app_service, domain_service].each do |n|
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

    context 'when uses targets a repository' do
      it 'passes validation' do
        service = DddDiagramParser::Node.new(id: '1', ddd_type: 'application_service', ddd_name: 'OrderService',
                                             props: {})
        repo = DddDiagramParser::Node.new(id: '2', ddd_type: 'repository', ddd_name: 'OrderRepository', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'uses')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [service, repo].each { |n| m.add_node(n) }
          [edge].each do |e|
            m.add_edge(e)
          end
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
        expect(report.warnings).to be_empty
      end
    end

    context 'when uses targets a value_object (disallowed)' do
      it 'adds an error' do
        service = DddDiagramParser::Node.new(id: '1', ddd_type: 'application_service', ddd_name: 'OrderService',
                                             props: {})
        vo = DddDiagramParser::Node.new(id: '2', ddd_type: 'value_object', ddd_name: 'Money', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'uses')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [service, vo].each { |n| m.add_node(n) }
          [edge].each do |e|
            m.add_edge(e)
          end
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R10_ILLEGAL_USES_TARGET')
        expect(report.warnings).to be_empty
      end
    end

    context 'when uses targets a domain_event (disallowed)' do
      it 'adds an error' do
        service = DddDiagramParser::Node.new(id: '1', ddd_type: 'application_service', ddd_name: 'OrderService',
                                             props: {})
        event = DddDiagramParser::Node.new(id: '2', ddd_type: 'domain_event', ddd_name: 'OrderPlaced', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'uses')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [service, event].each { |n| m.add_node(n) }
          [edge].each do |e|
            m.add_edge(e)
          end
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R10_ILLEGAL_USES_TARGET')
        expect(report.warnings).to be_empty
      end
    end

    context 'when uses targets an unusual type (not in allowed list)' do
      it 'adds a warning' do
        service = DddDiagramParser::Node.new(id: '1', ddd_type: 'application_service', ddd_name: 'OrderService',
                                             props: {})
        external = DddDiagramParser::Node.new(id: '2', ddd_type: 'external_system', ddd_name: 'PaymentGateway',
                                              props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'uses')
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
        expect(report.warnings.count).to eq(1)
        expect(report.warnings.first.code).to eq('R10_UNUSUAL_USES_TARGET')
      end
    end
  end
end
