# frozen_string_literal: true

require_relative 'validation_report'
require_relative 'validators/required_fields_validator'
require_relative 'validators/uniqueness_validator'
require_relative 'validators/required_properties_validator'
require_relative 'validators/relation_type_validator'
require_relative 'validators/composition_validator'
require_relative 'validators/publishes_event_validator'
require_relative 'validators/consumes_event_validator'
require_relative 'validators/repository_access_validator'
require_relative 'validators/integration_validator'
require_relative 'validators/uses_validator'
require_relative 'validators/aggregate_ownership_validator'
require_relative 'validators/bounded_context_membership_validator'
require_relative 'validators/event_ownership_validator'
require_relative 'validators/cross_context_validator'

module DddDiagramParser
  # Main validator that runs all validation rules
  class Validator
    # Validate a parsed model
    # @param model [Model] the parsed model to validate
    # @return [ValidationReport] validation results
    def self.validate(model)
      new.validate(model)
    end

    # Initialize validator with all rule validators
    def initialize
      @validators = [
        # Phase A - Basic correctness
        Validators::RequiredFieldsValidator.new,        # R1
        Validators::UniquenessValidator.new,            # R2
        Validators::RequiredPropertiesValidator.new,    # R3

        # Phase B - Relationship typing
        Validators::RelationTypeValidator.new,          # R4
        Validators::CompositionValidator.new,           # R5
        Validators::PublishesEventValidator.new,        # R6
        Validators::ConsumesEventValidator.new,         # R7
        Validators::RepositoryAccessValidator.new,      # R8
        Validators::IntegrationValidator.new,           # R9
        Validators::UsesValidator.new,                  # R10

        # Phase C - DDD semantic constraints
        Validators::AggregateOwnershipValidator.new,          # R11
        Validators::BoundedContextMembershipValidator.new,    # R12
        Validators::EventOwnershipValidator.new,              # R13
        Validators::CrossContextValidator.new                 # R14
      ]
    end

    # Run all validators
    # @param model [Model] the model to validate
    # @return [ValidationReport]
    def validate(model)
      report = ValidationReport.new

      @validators.each do |validator|
        validator.validate(model, report)
      end

      report
    end
  end
end
