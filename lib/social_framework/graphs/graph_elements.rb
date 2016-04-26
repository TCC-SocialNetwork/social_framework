# Module to implements vertices and edges
module GraphElements
  # Represent graph's vertex
  class Vertex
    attr_accessor :id, :type, :edges, :visits, :color, :attributes

    # Constructor to vertex 
    # ====== Params:
    # +id+:: +Integer+ user id
    # Returns Vertex's Instance
    def initialize id, type, attributes = {}
      @id = id
      @type = type
      @edges = Array.new
      @visits = 0
      @color = :white
      @attributes = attributes
    end
    
    # Overriding equal method to compare vertex by id
    # Returns true if id is equal or false if not
    def ==(other)
      self.id == other.id and self.type == other.type
    end
    
    alias :eql? :==
    
    # Overriding hash method to always equals
    # Returns id hash
    def hash
      self.id.hash
    end

    # Add edges to vertex
    # ====== Params:
    # +destiny+:: +Vertex+  destiny to edge
    # +label+:: +String+  label to edge
    # Returns edge created
    def add_edge destiny, label = ""
      edge = @edges.select { |e| e.destiny == destiny }.first

      if edge.nil?
        edge = Edge.new self, destiny
        @edges << edge
      end

      edge.labels << label
    end
  end


  # Represent the conneciont edges between vertices
  class Edge
    attr_accessor :origin, :destiny, :labels
    
    # Constructor to Edge 
    # ====== Params:
    # +origin+:: +Vertex+ relationship origin
    # +destiny+:: +Vertex+ relationship destiny
    # Returns Vertex's Instance
    def initialize origin, destiny
      @origin = origin
      @destiny = destiny
      @labels = Array.new
    end
  end
end
