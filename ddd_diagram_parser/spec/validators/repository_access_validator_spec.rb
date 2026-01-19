# frozen_string_literal: true

require 'spec_helper'
require_relative '../../validators/repository_access_validator'
require_relative '../../model'
require_relative '../../node'
require_relative '../../edge'
require_relative '../../validation_report'

RSpec.describe DddDiagramParser::Validators::RepositoryAccessValidator do
  let(:validator) { described_class.new }
  let(:report) { DddDiagramParser::ValidationReport.new }

  describe '#validate' do
    context 'when repository_access is ApplicationService -> Repository' do
      it 'passes validation' do
        service = DddDiagramParser::Node.new(id: '1', ddd_type: 'application_service', ddd_name: 'OrderService',
                                             props: {})
        repo = DddDiagramParser::Node.new(id: '2', ddd_type: 'repository', ddd_name: 'OrderRepository', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'repository_access')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [service, repo].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
      end
    end

    context 'when repository_access is DomainService -> Repository' do
      it 'passes validation' do
        service = DddDiagramParser::Node.new(id: '1', ddd_type: 'domain_service', ddd_name: 'PricingService', props: {})
        repo = DddDiagramParser::Node.new(id: '2', ddd_type: 'repository', ddd_name: 'OrderRepository', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'repository_access')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [service, repo].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
      end
    end

    context 'when repository_access source is not a service' do
      it 'adds an error' do
        agg = DddDiagramParser::Node.new(id: '1', ddd_type: 'aggregate_root', ddd_name: 'Order', props: {})
        repo = DddDiagramParser::Node.new(id: '2', ddd_type: 'repository', ddd_name: 'OrderRepository', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'repository_access')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [agg, repo].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R8_INVALID_REPOSITORY_ACCESS_SOURCE')
      end
    end

    context 'when repository_access target is not repository' do
      it 'adds an error' do
        service = DddDiagramParser::Node.new(id: '1', ddd_type: 'application_service', ddd_name: 'OrderService',
                                             props: {})
        entity = DddDiagramParser::Node.new(id: '2', ddd_type: 'entity', ddd_name: 'LineItem', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'repository_access')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [service, entity].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R8_INVALID_REPOSITORY_ACCESS_TARGET')
      end
    end
  end
end
