# Module to implements vertices and edges
module GraphElements

  # Define abstract methods to Vertex
  class Vertex
    # The attributes of vertex
    attr_accessor :id, :type, :edges, :visits, :color, :attributes

    # Constructor to vertex 
    # ====== Params:
    # +id+:: +Integer+ vertex id
    # +type+:: +Class+ of vertex
    # +attributes+:: +Hash+ aditional attributes of vertex
    # Returns NotImplementedError
    def initialize id, type, attributes
      raise 'Must implement method in subclass'
    end

    # Overriding equal method
    # Returns NotImplementedError
    def ==(other)
      raise 'Must implement method in subclass'
    end
    
    alias :eql? :==

    # Overriding hash method
    # Returns NotImplementedError
    def hash
      raise 'Must implement method in subclass'
    end

    # Method to add edges to vertex
    # ====== Params:
    # +destiny+:: +Vertex+  destiny to edge
    # +label+:: +String+  label to edge
    # Returns NotImplementedError
    def add_edge destiny, label = ""
      raise 'Must implement method in subclass'
    end
  end

  # Represent graph's vertex
  class VertexDefault < Vertex
    # Constructor to vertex 
    # ====== Params:
    # +id+:: +Integer+ user id
    # +type+:: +Class+ of vertex
    # +attributes+:: +Hash+ aditional attributes of vertex
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
        edge = EdgeDefault.new self, destiny
        @edges << edge
      end

      edge.labels << label
    end
  end

  # Define abstract methods to Vertex
  class Edge
    attr_accessor :origin, :destiny, :labels

    # Constructor to Edge
    # ====== Params:
    # +origin+:: +Vertex+ relationship origin
    # +destiny+:: +Vertex+ relationship destiny
    # Returns NotImplementedError
    def initialize origin, destiny
      raise 'Must implement method in subclass'
    end
  end

  # Represent the conneciont edges between vertices
  class EdgeDefault < Edge
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
