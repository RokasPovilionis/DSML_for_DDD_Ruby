# frozen_string_literal: true

require_relative 'node'
require_relative 'edge'

module DddDiagramParser
  # Represents the complete parsed DSML model graph
  # Provides indexed access to nodes and edges for efficient validation
  class Model
    attr_reader :nodes_by_id, :edges, :diagram_name

    # @param diagram_name [String] name of the diagram
    def initialize(diagram_name: 'Untitled')
      @diagram_name = diagram_name
      @nodes_by_id = {}
      @edges = []
    end

    # Add a node to the model
    # @param node [Node] node to add
    def add_node(node)
      @nodes_by_id[node.id] = node
    end

    # Add an edge to the model
    # @param edge [Edge] edge to add
    def add_edge(edge)
      @edges << edge
    end

    # Get all nodes
    # @return [Array<Node>]
    def nodes
      @nodes_by_id.values
    end

    # Get node by id
    # @param id [String] node id
    # @return [Node, nil]
    def node(id)
      @nodes_by_id[id]
    end

    # Get nodes by DDD type
    # @param type [String] ddd_type to filter by
    # @return [Array<Node>]
    def nodes_by_type(type)
      nodes.select { |n| n.ddd_type == type }
    end

    # Get nodes by name
    # @param name [String] ddd_name to search for
    # @return [Array<Node>]
    def nodes_by_name(name)
      nodes.select { |n| n.ddd_name == name }
    end

    # Get edges by relation type
    # @param type [String] relation_type to filter by
    # @return [Array<Edge>]
    def edges_by_type(type)
      @edges.select { |e| e.relation_type == type }
    end

    # Get edges originating from a node
    # @param node_id [String] source node id
    # @return [Array<Edge>]
    def edges_from(node_id)
      @edges.select { |e| e.source_id == node_id }
    end

    # Get edges pointing to a node
    # @param node_id [String] target node id
    # @return [Array<Edge>]
    def edges_to(node_id)
      @edges.select { |e| e.target_id == node_id }
    end

    # Get all edges connected to a node (incoming or outgoing)
    # @param node_id [String] node id
    # @return [Array<Edge>]
    def edges_for(node_id)
      @edges.select { |e| e.source_id == node_id || e.target_id == node_id }
    end

    # Statistics for debugging
    # @return [Hash]
    def stats
      {
        nodes_count: nodes.count,
        edges_count: @edges.count,
        nodes_by_type: nodes.group_by(&:ddd_type).transform_values(&:count),
        edges_by_type: @edges.group_by(&:relation_type).transform_values(&:count)
      }
    end

    # String representation
    # @return [String]
    def to_s
      "<Model '#{@diagram_name}': #{nodes.count} nodes, #{@edges.count} edges>"
    end
  end
end
