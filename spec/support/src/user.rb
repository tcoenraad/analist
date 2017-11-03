# frozen_string_literal: true

class User < ActiveRecord::Base
  def full_name
    "#{first_name} #{last_name}"
  end

  def self.anonymous_name
    'Anonymous User'
  end
end
