# frozen_string_literal: true

require 'spec_helper'
require_relative '../../validators/aggregate_ownership_validator'
require_relative '../../model'
require_relative '../../node'
require_relative '../../edge'
require_relative '../../validation_report'

RSpec.describe DddDiagramParser::Validators::AggregateOwnershipValidator do
  let(:validator) { described_class.new }
  let(:report) { DddDiagramParser::ValidationReport.new }

  describe '#validate' do
    context 'when entity has both property and composition edge' do
      it 'passes validation' do
        agg = DddDiagramParser::Node.new(id: '1', ddd_type: 'aggregate_root', ddd_name: 'Order', props: {})
        entity = DddDiagramParser::Node.new(id: '2', ddd_type: 'entity', ddd_name: 'LineItem',
                                            props: { 'aggregate' => 'Order' })
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'composition')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [agg, entity].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
        expect(report.warnings).to be_empty
      end
    end

    context 'when entity has property but no composition edge' do
      it 'adds a warning' do
        agg = DddDiagramParser::Node.new(id: '1', ddd_type: 'aggregate_root', ddd_name: 'Order', props: {})
        entity = DddDiagramParser::Node.new(id: '2', ddd_type: 'entity', ddd_name: 'LineItem',
                                            props: { 'aggregate' => 'Order' })
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [agg, entity].each { |n| m.add_node(n) }
          [].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
        expect(report.warnings.count).to eq(1)
        expect(report.warnings.first.code).to eq('R11_MISSING_COMPOSITION_EDGE')
      end
    end

    context 'when entity has composition edge but no property' do
      it 'adds a warning' do
        agg = DddDiagramParser::Node.new(id: '1', ddd_type: 'aggregate_root', ddd_name: 'Order', props: {})
        entity = DddDiagramParser::Node.new(id: '2', ddd_type: 'entity', ddd_name: 'LineItem', props: {})
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'composition')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [agg, entity].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
        expect(report.warnings.count).to eq(1)
        expect(report.warnings.first.code).to eq('R11_MISSING_AGGREGATE_PROPERTY')
      end
    end

    context 'when entity has neither property nor composition edge' do
      it 'adds an error' do
        entity = DddDiagramParser::Node.new(id: '2', ddd_type: 'entity', ddd_name: 'LineItem', props: {})
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [entity].each { |n| m.add_node(n) }
          [].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R11_MISSING_AGGREGATE_OWNERSHIP')
      end
    end

    context 'when entity references non-existent aggregate' do
      it 'adds an error' do
        entity = DddDiagramParser::Node.new(id: '2', ddd_type: 'entity', ddd_name: 'LineItem',
                                            props: { 'aggregate' => 'NonExistent' })
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [entity].each { |n| m.add_node(n) }
          [].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R11_INVALID_AGGREGATE_REFERENCE')
      end
    end

    context 'when entity has mismatched property and composition edge' do
      it 'adds a warning' do
        agg1 = DddDiagramParser::Node.new(id: '1', ddd_type: 'aggregate_root', ddd_name: 'Order', props: {})
        agg2 = DddDiagramParser::Node.new(id: '3', ddd_type: 'aggregate_root', ddd_name: 'Product', props: {})
        entity = DddDiagramParser::Node.new(id: '2', ddd_type: 'entity', ddd_name: 'LineItem',
                                            props: { 'aggregate' => 'Order' })
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '3', target_id: '2', relation_type: 'composition')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [agg1, agg2, entity].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
        expect(report.warnings.count).to eq(1)
        expect(report.warnings.first.code).to eq('R11_AGGREGATE_MISMATCH')
      end
    end

    context 'when value object has both property and composition edge' do
      it 'passes validation' do
        agg = DddDiagramParser::Node.new(id: '1', ddd_type: 'aggregate_root', ddd_name: 'Order', props: {})
        vo = DddDiagramParser::Node.new(id: '2', ddd_type: 'value_object', ddd_name: 'Money',
                                        props: { 'aggregate' => 'Order' })
        edge = DddDiagramParser::Edge.new(id: 'e1', source_id: '1', target_id: '2', relation_type: 'composition')
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [agg, vo].each { |n| m.add_node(n) }
          [edge].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
        expect(report.warnings).to be_empty
      end
    end
  end
end
