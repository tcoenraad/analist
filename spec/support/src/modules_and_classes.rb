class User
  def full_name
    'Random Stranger'
  end
end

module Blaat
  class BlaatUser < User
    def method
      'it exists'
    end
  end
end

class Blaat::SuperBlaatUser < User
end

class CreateUser < Mutations::Command
  required do
    integer :id
    string :name
  end
end

class UpdateUser < Mutations::Command
  required do
    integer :id
  end
end
