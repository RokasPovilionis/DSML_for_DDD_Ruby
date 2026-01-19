# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DddDiagramParser::ValidationReport do
  let(:report) { described_class.new }

  describe '#add_error' do
    it 'adds an error to the report' do
      report.add_error(
        code: 'TEST_ERROR',
        message: 'Test error message',
        node_id: 'n1',
        node_name: 'TestNode'
      )

      expect(report.errors.count).to eq(1)
      expect(report.count).to eq(1)
    end
  end

  describe '#add_warning' do
    it 'adds a warning to the report' do
      report.add_warning(
        code: 'TEST_WARNING',
        message: 'Test warning message',
        node_id: 'n1'
      )

      expect(report.warnings.count).to eq(1)
      expect(report.count).to eq(1)
    end
  end

  describe '#valid?' do
    context 'with no issues' do
      it 'returns true' do
        expect(report.valid?).to be true
      end
    end

    context 'with only warnings' do
      before do
        report.add_warning(code: 'W1', message: 'Warning')
      end

      it 'returns true (warnings do not block)' do
        expect(report.valid?).to be true
      end
    end

    context 'with errors' do
      before do
        report.add_error(code: 'E1', message: 'Error')
      end

      it 'returns false' do
        expect(report.valid?).to be false
      end
    end
  end

  describe '#summary' do
    before do
      report.add_error(code: 'E1', message: 'Error 1')
      report.add_error(code: 'E2', message: 'Error 2')
      report.add_warning(code: 'W1', message: 'Warning 1')
    end

    it 'returns summary statistics' do
      summary = report.summary
      expect(summary[:total]).to eq(3)
      expect(summary[:errors]).to eq(2)
      expect(summary[:warnings]).to eq(1)
      expect(summary[:valid]).to be false
    end
  end
end
