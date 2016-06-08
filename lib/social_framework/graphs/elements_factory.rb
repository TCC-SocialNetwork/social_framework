# Abstract class to provide methods to create elements to graph
class ElementsFactory

  # Create a vertex, must be implemented in concrete class
  # ====== Params:
  # +id+:: +Integer+ vertex id
  # +type+:: +Class+ of vertex
  # +attributes+:: +Hash+ aditional attributes of vertex
  # Returns NotImplementedError
  def create_vertex id, type, attributes
    raise 'Must implement method in subclass'
  end

  # Create a edge, must be implemented in concrete class
  # ====== Params:
  # +origin+:: +Vertex+ relationship origin
  # +destiny+:: +Vertex+ relationship destiny
  # Returns NotImplementedError
  def create_edge origin, destiny
    raise 'Must implement method in subclass'
  end
end
