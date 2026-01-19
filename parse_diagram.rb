#!/usr/bin/env ruby
# frozen_string_literal: true

# Simple CLI to test the parser
require_relative 'ddd_diagram_parser/parser'
require_relative 'ddd_diagram_parser/validator'
require 'json'

def main
  if ARGV.empty?
    puts 'Usage: ruby parse_diagram.rb <path-to-drawio-file> [--validate]'
    puts 'Example: ruby parse_diagram.rb examples/sales_example/model.drawio.xml --validate'
    exit 1
  end

  file_path = ARGV[0]
  should_validate = ARGV.include?('--validate')

  unless File.exist?(file_path)
    puts "Error: File not found: #{file_path}"
    exit 1
  end

  puts "Parsing: #{file_path}"
  puts '-' * 60

  begin
    # Parse the diagram
    model = DddDiagramParser::Parser.parse(file_path)

    # Display summary
    puts "\n#{model}"
    puts "\nStatistics:"
    puts JSON.pretty_generate(model.stats)

    # Validate if requested
    if should_validate
      puts "\n" + '=' * 60
      puts 'VALIDATION:'
      puts '=' * 60

      report = DddDiagramParser::Validator.validate(model)
      puts report

      # Exit with error code if validation failed
      exit 1 unless report.valid?
    else
      # Display nodes
      puts "\n" + '=' * 60
      puts "NODES (#{model.nodes.count}):"
      puts '=' * 60

      model.nodes.each do |node|
        puts "\n#{node}"
        puts "  Label: #{node.raw_label}"
        next unless node.property_keys.any?

        puts '  Properties:'
        node.property_keys.sort.each do |key|
          next if key == 'raw_label'

          puts "    #{key}: #{node[key]}"
        end
      end

      # Display edges
      puts "\n" + '=' * 60
      puts "EDGES (#{model.edges.count}):"
      puts '=' * 60

      model.edges.each do |edge|
        source = model.node(edge.source_id)
        target = model.node(edge.target_id)

        puts "\n#{edge}"
        puts "  #{source&.ddd_name || edge.source_id} -> #{target&.ddd_name || edge.target_id}"
        puts "  Label: #{edge.raw_label}" if edge.raw_label && !edge.raw_label.empty?
      end

      puts "\n" + '=' * 60
      puts 'Parsing completed successfully!'
      puts 'Tip: Add --validate flag to run validation rules'
    end
  rescue StandardError => e
    puts "Error parsing file: #{e.message}"
    puts e.backtrace.join("\n")
    exit 1
  end
end

main if __FILE__ == $PROGRAM_NAME
