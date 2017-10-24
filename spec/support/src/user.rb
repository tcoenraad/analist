# frozen_string_literal: true

class User < ActiveRecord::Base
  def random_string
    'lorem ipsum'
  end

  def random_number
    4
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end

module Blaat
  class BlaatedUser < User
    def method3
      'it exists'
    end
  end
end
