# Implements the methods to create vertices and edges
class ElementsFactoryDefault < ElementsFactory

  # Create a default vertex
  # ====== Params:
  # +id+:: +Integer+ vertex id
  # +type+:: +Class+ of vertex
  # +attributes+:: +Hash+ aditional attributes of vertex
  # Returns GraphElements::VertexDefault object
  def create_vertex id, type, attributes = {}
    return GraphElements::VertexDefault.new id, type, attributes
  end

  # Create a default edge
  # ====== Params:
  # +origin+:: +Vertex+ relationship origin
  # +destiny+:: +Vertex+ relationship destiny
  # Returns GraphElements::EdgeDefault object
  def create_edge origin, destiny
    return GraphElements::EdgeDefault.new origin, destiny
  end
end
