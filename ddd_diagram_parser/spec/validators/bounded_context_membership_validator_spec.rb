# frozen_string_literal: true

require 'spec_helper'
require_relative '../../validators/bounded_context_membership_validator'
require_relative '../../model'
require_relative '../../node'
require_relative '../../validation_report'

RSpec.describe DddDiagramParser::Validators::BoundedContextMembershipValidator do
  let(:validator) { described_class.new }
  let(:report) { DddDiagramParser::ValidationReport.new }

  describe '#validate' do
    context 'when aggregate has valid bounded_context' do
      it 'passes validation' do
        bc = DddDiagramParser::Node.new(id: '1', ddd_type: 'bounded_context', ddd_name: 'Sales', props: {})
        agg = DddDiagramParser::Node.new(id: '2', ddd_type: 'aggregate_root', ddd_name: 'Order',
                                         props: { 'bounded_context' => 'Sales' })
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [bc, agg].each { |n| m.add_node(n) }
          [].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors).to be_empty
      end
    end

    context 'when aggregate is missing bounded_context property' do
      it 'adds an error' do
        agg = DddDiagramParser::Node.new(id: '2', ddd_type: 'aggregate_root', ddd_name: 'Order', props: {})
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [agg].each { |n| m.add_node(n) }
          [].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R12_MISSING_BOUNDED_CONTEXT')
      end
    end

    context 'when aggregate has empty bounded_context property' do
      it 'adds an error' do
        agg = DddDiagramParser::Node.new(id: '2', ddd_type: 'aggregate_root', ddd_name: 'Order',
                                         props: { 'bounded_context' => '  ' })
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [agg].each { |n| m.add_node(n) }
          [].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R12_MISSING_BOUNDED_CONTEXT')
      end
    end

    context 'when aggregate references non-existent bounded context' do
      it 'adds an error' do
        agg = DddDiagramParser::Node.new(id: '2', ddd_type: 'aggregate_root', ddd_name: 'Order',
                                         props: { 'bounded_context' => 'NonExistent' })
        model = DddDiagramParser::Model.new(diagram_name: 'Test').tap do |m|
          [agg].each { |n| m.add_node(n) }
          [].each { |e| m.add_edge(e) }
        end

        validator.validate(model, report)

        expect(report.errors.count).to eq(1)
        expect(report.errors.first.code).to eq('R12_INVALID_BOUNDED_CONTEXT')
      end
    end
  end
end
