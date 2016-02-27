module SocialFramework
  # Validates to edge class
  module EdgeValidatorHelper
    # Validate to verify if edge already exist
    # Returns erros if edge invalid or nil if not
    def destiny_must_be_unique_to_same_origin
      unless Edge.where(origin: self.origin, destiny: self.destiny).empty?
        errors.add(:destiny, "Must be unique to same origin")
      end
    end
  end
end
