# frozen_string_literal: true

class SimpleUser; end

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
  class BlaatUser < User
    def method
      'it exists'
    end
  end
end

class Blaat::SuperBlaatUser < User; end
