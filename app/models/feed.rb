require 'feedzirra'
class Feed < ActiveRecord::Base
  attr_accessible :title, :url, :updated_at
  has_many :posts

  def fetch
    ## Will fire #perform

    Delayed::Job.enqueue self
  end

  def perform
    logger.info("** feed#perform")
    feed = ::Feedzirra::Feed.fetch_and_parse(url)

    transaction do
      logger.info("** Feed found")
      self.title = feed.title
      self.feed_updated_at = feed.last_modified
      save!
      logger.info("** Feed saved: #{feed.title}") 
      feed.entries.slice(0,3).each do |item|
        unless posts.find_by_url(item.url)
          posts.create! :title => item.title, :url => item.url
        end
      end
    end
  end

  def self.fetch_all
    all.each do |feed|
      feed.fetch
    end
  end
end
