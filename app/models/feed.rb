require 'feedzirra'
class Feed < ActiveRecord::Base
  attr_accessible :title, :url, :updated_at
  has_many :posts
end
