class Post < ActiveRecord::Base
  attr_accessible :title, :url
  belongs_to :feed
end
