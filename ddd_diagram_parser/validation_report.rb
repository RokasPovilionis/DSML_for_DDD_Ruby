# frozen_string_literal: true

module DddDiagramParser
  # Represents a single validation issue (error or warning)
  class ValidationIssue
    attr_reader :code, :severity, :message, :node_id, :node_name, :edge_id

    SEVERITIES = %w[error warning].freeze

    # @param code [String] stable identifier for the issue type (e.g., 'R1_MISSING_DDD_TYPE')
    # @param severity [String] 'error' or 'warning'
    # @param message [String] human-readable description
    # @param node_id [String, nil] ID of the node with the issue
    # @param node_name [String, nil] name of the node for readability
    # @param edge_id [String, nil] ID of the edge with the issue
    def initialize(code:, severity:, message:, node_id: nil, node_name: nil, edge_id: nil)
      raise ArgumentError, "Invalid severity: #{severity}" unless SEVERITIES.include?(severity)

      @code = code
      @severity = severity
      @message = message
      @node_id = node_id
      @node_name = node_name
      @edge_id = edge_id
    end

    # @return [Boolean] true if this is an error
    def error?
      @severity == 'error'
    end

    # @return [Boolean] true if this is a warning
    def warning?
      @severity == 'warning'
    end

    # String representation for display
    # @return [String]
    def to_s
      prefix = error? ? 'ERROR' : 'WARNING'
      location = if @node_id && @node_name
                   "Node: #{@node_name} (#{@node_id})"
                 elsif @node_id
                   "Node: #{@node_id}"
                 elsif @edge_id
                   "Edge: #{@edge_id}"
                 else
                   'Global'
                 end

      "#{prefix} #{@code}: #{@message}\n  #{location}"
    end

    # Hash representation
    # @return [Hash]
    def to_h
      {
        code: @code,
        severity: @severity,
        message: @message,
        node_id: @node_id,
        node_name: @node_name,
        edge_id: @edge_id
      }.compact
    end
  end

  # Container for validation results
  class ValidationReport
    attr_reader :issues

    def initialize
      @issues = []
    end

    # Add an issue to the report
    # @param issue [ValidationIssue]
    def add_issue(issue)
      @issues << issue
    end

    # Add an error
    # @param code [String] error code
    # @param message [String] error message
    # @param node_id [String, nil] node ID
    # @param node_name [String, nil] node name
    # @param edge_id [String, nil] edge ID
    def add_error(code:, message:, node_id: nil, node_name: nil, edge_id: nil)
      add_issue(ValidationIssue.new(
                  code: code,
                  severity: 'error',
                  message: message,
                  node_id: node_id,
                  node_name: node_name,
                  edge_id: edge_id
                ))
    end

    # Add a warning
    # @param code [String] warning code
    # @param message [String] warning message
    # @param node_id [String, nil] node ID
    # @param node_name [String, nil] node name
    # @param edge_id [String, nil] edge ID
    def add_warning(code:, message:, node_id: nil, node_name: nil, edge_id: nil)
      add_issue(ValidationIssue.new(
                  code: code,
                  severity: 'warning',
                  message: message,
                  node_id: node_id,
                  node_name: node_name,
                  edge_id: edge_id
                ))
    end

    # @return [Array<ValidationIssue>] all errors
    def errors
      @issues.select(&:error?)
    end

    # @return [Array<ValidationIssue>] all warnings
    def warnings
      @issues.select(&:warning?)
    end

    # @return [Boolean] true if there are any errors
    def has_errors?
      errors.any?
    end

    # @return [Boolean] true if there are any warnings
    def has_warnings?
      warnings.any?
    end

    # @return [Boolean] true if validation passed (no errors)
    def valid?
      !has_errors?
    end

    # @return [Integer] total number of issues
    def count
      @issues.count
    end

    # Summary statistics
    # @return [Hash]
    def summary
      {
        total: count,
        errors: errors.count,
        warnings: warnings.count,
        valid: valid?
      }
    end

    # String representation
    # @return [String]
    def to_s
      if @issues.empty?
        '✓ Validation passed: No issues found'
      else
        lines = ['Validation Report:', '=' * 60]
        lines << "Errors: #{errors.count}, Warnings: #{warnings.count}"
        lines << ('=' * 60)
        lines += @issues.map(&:to_s)
        lines << ('=' * 60)
        lines << (valid? ? '✓ No errors (warnings present)' : '✗ Validation failed')
        lines.join("\n")
      end
    end
  end
end
