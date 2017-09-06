class Coercion
  def self.check?(op:, type:, other_type:)
    map[op][type].include?(other_type)
  end

  def self.map
    {
      :+ => {
        int: [:int],
        str: [:str]
      }
    }
  end
end
