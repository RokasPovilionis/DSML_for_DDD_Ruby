# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DddDiagramParser::Validator do
  let(:model) { DddDiagramParser::Model.new }

  describe 'R1: Required fields validation' do
    context 'when node has both ddd_type and ddd_name' do
      before do
        model.add_node(DddDiagramParser::Node.new(
                         id: 'n1',
                         ddd_type: 'aggregate_root',
                         ddd_name: 'Order'
                       ))
      end

      it 'passes validation' do
        report = described_class.validate(model)

        r1_errors = report.errors.select { |e| e.code.start_with?('R1_') }
        expect(r1_errors).to be_empty
      end
    end

    context 'when node is missing ddd_type' do
      before do
        model.add_node(DddDiagramParser::Node.new(
                         id: 'n1',
                         ddd_type: nil,
                         ddd_name: 'Order'
                       ))
      end

      it 'reports R1_MISSING_DDD_TYPE error' do
        report = described_class.validate(model)

        expect(report.valid?).to be false
        error = report.errors.find { |e| e.code == 'R1_MISSING_DDD_TYPE' }
        expect(error).not_to be_nil
        expect(error.message).to include('must have a ddd_type')
      end
    end

    context 'when node is missing ddd_name' do
      before do
        model.add_node(DddDiagramParser::Node.new(
                         id: 'n1',
                         ddd_type: 'aggregate_root',
                         ddd_name: nil
                       ))
      end

      it 'reports R1_MISSING_DDD_NAME error' do
        report = described_class.validate(model)

        expect(report.valid?).to be false
        error = report.errors.find { |e| e.code == 'R1_MISSING_DDD_NAME' }
        expect(error).not_to be_nil
        expect(error.message).to include('must have a ddd_name')
      end
    end
  end

  describe 'R2: Uniqueness validation' do
    context 'when bounded context names are unique' do
      before do
        model.add_node(DddDiagramParser::Node.new(
                         id: 'bc1',
                         ddd_type: 'bounded_context',
                         ddd_name: 'Sales'
                       ))
        model.add_node(DddDiagramParser::Node.new(
                         id: 'bc2',
                         ddd_type: 'bounded_context',
                         ddd_name: 'Inventory'
                       ))
      end

      it 'passes validation' do
        report = described_class.validate(model)

        r2_errors = report.errors.select { |e| e.code.start_with?('R2_') }
        expect(r2_errors).to be_empty
      end
    end

    context 'when bounded context names are duplicated' do
      before do
        model.add_node(DddDiagramParser::Node.new(
                         id: 'bc1',
                         ddd_type: 'bounded_context',
                         ddd_name: 'Sales'
                       ))
        model.add_node(DddDiagramParser::Node.new(
                         id: 'bc2',
                         ddd_type: 'bounded_context',
                         ddd_name: 'Sales'
                       ))
      end

      it 'reports R2_DUPLICATE_BOUNDED_CONTEXT error' do
        report = described_class.validate(model)

        expect(report.valid?).to be false
        errors = report.errors.select { |e| e.code == 'R2_DUPLICATE_BOUNDED_CONTEXT' }
        expect(errors.count).to eq(2) # One for each duplicate
      end
    end

    context 'when aggregate names are unique within bounded context' do
      before do
        model.add_node(DddDiagramParser::Node.new(
                         id: 'a1',
                         ddd_type: 'aggregate_root',
                         ddd_name: 'Order',
                         props: { 'bounded_context' => 'Sales' }
                       ))
        model.add_node(DddDiagramParser::Node.new(
                         id: 'a2',
                         ddd_type: 'aggregate_root',
                         ddd_name: 'Customer',
                         props: { 'bounded_context' => 'Sales' }
                       ))
      end

      it 'passes validation' do
        report = described_class.validate(model)

        r2_errors = report.errors.select { |e| e.code == 'R2_DUPLICATE_AGGREGATE' }
        expect(r2_errors).to be_empty
      end
    end

    context 'when aggregate names are duplicated within bounded context' do
      before do
        model.add_node(DddDiagramParser::Node.new(
                         id: 'a1',
                         ddd_type: 'aggregate_root',
                         ddd_name: 'Order',
                         props: { 'bounded_context' => 'Sales' }
                       ))
        model.add_node(DddDiagramParser::Node.new(
                         id: 'a2',
                         ddd_type: 'aggregate_root',
                         ddd_name: 'Order',
                         props: { 'bounded_context' => 'Sales' }
                       ))
      end

      it 'reports R2_DUPLICATE_AGGREGATE error' do
        report = described_class.validate(model)

        expect(report.valid?).to be false
        errors = report.errors.select { |e| e.code == 'R2_DUPLICATE_AGGREGATE' }
        expect(errors.count).to eq(2)
      end
    end
  end

  describe 'R3: Required properties validation' do
    context 'when bounded context has required context_key' do
      before do
        model.add_node(DddDiagramParser::Node.new(
                         id: 'bc1',
                         ddd_type: 'bounded_context',
                         ddd_name: 'Sales',
                         props: { 'context_key' => 'sales' }
                       ))
      end

      it 'passes validation' do
        report = described_class.validate(model)

        r3_errors = report.errors.select { |e| e.code == 'R3_MISSING_REQUIRED_PROPERTY' }
        expect(r3_errors).to be_empty
      end
    end

    context 'when bounded context is missing context_key' do
      before do
        model.add_node(DddDiagramParser::Node.new(
                         id: 'bc1',
                         ddd_type: 'bounded_context',
                         ddd_name: 'Sales',
                         props: {}
                       ))
      end

      it 'reports R3_MISSING_REQUIRED_PROPERTY error' do
        report = described_class.validate(model)

        expect(report.valid?).to be false
        error = report.errors.find do |e|
          e.code == 'R3_MISSING_REQUIRED_PROPERTY' && e.message.include?('context_key')
        end
        expect(error).not_to be_nil
      end
    end

    context 'when aggregate root has all required properties' do
      before do
        model.add_node(DddDiagramParser::Node.new(
                         id: 'a1',
                         ddd_type: 'aggregate_root',
                         ddd_name: 'Order',
                         props: { 'bounded_context' => 'Sales', 'id_type' => 'uuid' }
                       ))
      end

      it 'passes validation' do
        report = described_class.validate(model)

        r3_errors = report.errors.select { |e| e.code == 'R3_MISSING_REQUIRED_PROPERTY' }
        expect(r3_errors).to be_empty
      end
    end

    context 'when aggregate root is missing bounded_context' do
      before do
        model.add_node(DddDiagramParser::Node.new(
                         id: 'a1',
                         ddd_type: 'aggregate_root',
                         ddd_name: 'Order',
                         props: { 'id_type' => 'uuid' }
                       ))
      end

      it 'reports R3_MISSING_REQUIRED_PROPERTY error for bounded_context' do
        report = described_class.validate(model)

        expect(report.valid?).to be false
        error = report.errors.find do |e|
          e.code == 'R3_MISSING_REQUIRED_PROPERTY' && e.message.include?('bounded_context')
        end
        expect(error).not_to be_nil
      end
    end

    context 'when entity has all required properties' do
      before do
        model.add_node(DddDiagramParser::Node.new(
                         id: 'e1',
                         ddd_type: 'entity',
                         ddd_name: 'OrderLine',
                         props: { 'aggregate' => 'Order', 'id_type' => 'uuid' }
                       ))
      end

      it 'passes validation' do
        report = described_class.validate(model)

        r3_errors = report.errors.select { |e| e.code == 'R3_MISSING_REQUIRED_PROPERTY' }
        expect(r3_errors).to be_empty
      end
    end

    context 'when repository is missing aggregate' do
      before do
        model.add_node(DddDiagramParser::Node.new(
                         id: 'r1',
                         ddd_type: 'repository',
                         ddd_name: 'OrderRepository',
                         props: {}
                       ))
      end

      it 'reports R3_MISSING_REQUIRED_PROPERTY error for aggregate' do
        report = described_class.validate(model)

        expect(report.valid?).to be false
        error = report.errors.find do |e|
          e.code == 'R3_MISSING_REQUIRED_PROPERTY' && e.message.include?('aggregate')
        end
        expect(error).not_to be_nil
      end
    end
  end

  describe 'integration with real parser' do
    let(:example_file) do
      File.join(__dir__, '../../examples/sales_example/model.drawio.xml')
    end

    it 'validates the sales example successfully' do
      model = DddDiagramParser::Parser.parse(example_file)
      report = described_class.validate(model)

      # The sales example should pass all basic validation
      expect(report.valid?).to be true
    end
  end
end
