class Klass
  def random_number
    4 # See https://xkcd.com/221/
  end

  def self.qotd
    'The problem with UDP jokes: I do not get half of them'
  end

  def instance_random_number_alias
    random_number
  end

  def self.class_random_number_alias
    random_number
  end

  def instance_qotd_alias
    qotd
  end

  def self.class_qotd_alias
    qotd
  end

  def recursive_method
    recursive_method
  end
end
