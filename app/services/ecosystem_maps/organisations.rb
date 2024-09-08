# frozen_string_literal: true

require 'rgl/adjacency'
require 'rgl/traversal'
require 'rgl/dijkstra'
require 'rgl/connected_components'

module EcosystemMaps
  class Organisations

    class Graph
      def initialize
        @graph = RGL::DirectedAdjacencyGraph.new
      end

      def add_edge(source, target)
        @graph.add_edge(source, target)
      end

      def betweenness_centrality
        nodes = @graph.vertices
        centrality = Hash.new(0)

        nodes.each do |s|
          stack = []
          paths = {}
          sigma = Hash.new(0)
          delta = Hash.new(0)
          distance = Hash.new(-1)

          sigma[s] = 1
          distance[s] = 0
          queue = [s]

          while queue.any?
            v = queue.shift
            stack.push(v)
            @graph.adjacent_vertices(v).each do |w|
              if distance[w] < 0
                queue.push(w)
                distance[w] = distance[v] + 1
              end
              if distance[w] == distance[v] + 1
                sigma[w] += sigma[v]
                paths[w] ||= []
                paths[w] << v
              end
            end
          end

          while stack.any?
            w = stack.pop
            if paths[w]
              paths[w].each do |v|
                delta[v] += (sigma[v].to_f / sigma[w]) * (1 + delta[w])
              end
            end
            centrality[w] += delta[w] if w != s
          end
        end

        debugger
        rescale(centrality, @graph.num_vertices, true, directed: !@graph.directed?)
      end

      def rescale(betweenness, n, normalized, directed: false, k: nil, endpoints: false)
        scale = nil

        if normalized
          if endpoints
            if n < 2
              scale = nil  # no normalization
            else
              # Scale factor should include endpoint nodes
              scale = 1.0 / (n * (n - 1))
            end
          elsif n <= 2
            scale = nil  # no normalization b=0 for all nodes
          else
            scale = 1.0 / ((n - 1) * (n - 2))
          end
        else  # rescale by 2 for undirected graphs
          if !directed
            scale = 0.5
          else
            scale = nil
          end
        end

        if scale
          scale *= n / k if k
          betweenness.each do |v, value|
            betweenness[v] *= scale
          end
        end

        betweenness
      end
    end

    attr_reader :transition_card, :unique_organisations

    STRENGTH_BUCKET_SIZE = 4

    STRENGTH_BUCKET_WIDTH = 100.0 / STRENGTH_BUCKET_SIZE

    def initialize(transition_card, unique_organisations: nil)
      @transition_card = transition_card
      @unique_organisations = unique_organisations || transition_card.organisations.includes(:stakeholder_type).uniq
    end

    def links
      @links ||= build_links
    end

    def nodes
      @nodes ||= build_nodes
    end

    def link_data
      @link_data ||= build_link_data
    end

    private

    def build_link_data
      query = <<~SQL
        select org1.id, org2.id
        from initiatives
        inner join scorecards on scorecards.id = initiatives.scorecard_id
        inner join initiatives_organisations io1 on io1.initiative_id = initiatives.id
        inner join organisations org1 on org1.id = io1.organisation_id
        inner join initiatives_organisations io2 on io2.initiative_id = initiatives.id
        inner join organisations org2 on org2.id = io2.organisation_id
        where org1.id <> org2.id and initiatives.scorecard_id = #{transition_card.id}
        and (initiatives.archived_on > now() or initiatives.archived_on is null)
      SQL

      results = ActiveRecord::Base.connection.exec_query(query).rows

      results.map(&:minmax)
    end

    def build_betweenness(link_data)
      links = link_data.uniq

      lambda = Aws::Lambda::Client.new(region: 'us-west-2', http_read_timeout: 300)
      response = lambda.invoke(function_name: 'betweennessCentrality', payload: { 'links' => links }.to_json)

      payload = JSON.parse(response.payload.read)
      # SMELL: This is a temporary fix. Large datasets are taking too long to return and timing out.
      data = JSON.parse(payload['body'].presence || '{}')

      graph = Graph.new
      links.each do |(target, source)|
        graph.add_edge(target, source)
      end
      graph.betweenness_centrality

      debugger

      data.transform_keys(&:to_i)
    rescue Exception => e
      raise(payload.inspect)
      {}
    end


    # Example usage
    # graph = Graph.new
    # graph.add_edge('A', 'B')
    # graph.add_edge('B', 'C')
    # graph.add_edge('C', 'D')
    # graph.add_edge('D', 'E')
    # graph.add_edge('E', 'A')
    # graph.add_edge('A', 'C')
    # graph.add_edge('B', 'D')

    # centrality = graph.betweenness_centrality
    # centrality.each do |node, value|
    #   puts "Node #{node}: Betweenness Centrality = #{value}"
    # end

    def build_links
      grouped_link_data = link_data.group_by(&:itself).transform_values(&:count)

      upper = grouped_link_data.values.max
      lower = grouped_link_data.values.min

      grouped_link_data.map do |(target, source), link_count|
        {
          id: target,
          target:,
          source:,
          strength: calc_strength(upper, lower, link_count)
        }
      end
    end

    def build_nodes
      betweenness = build_betweenness(link_data)

      unique_organisations.map do |node|
        {
          id: node.id,
          label: node.name,
          color: node.stakeholder_type&.color || '#808080',
          betweenness: betweenness[node.id]
        }
      end
    end

    def calc_strength(upper, lower, value)
      return 1 if upper == lower

      range = upper - lower
      value_in_range = value - lower

      base_strength = (
        ((value_in_range.to_f / range.to_f) * 100) / STRENGTH_BUCKET_WIDTH
      ).round

      base_strength.zero? ? 1 : base_strength
    end
  end
end
