# Fabric to get model classes
class ModelFabric

  # Get Class Name
  # Returns a Model Class
  def self.get_class(class_name)
    class_name.classify.safe_constantize
  end
end