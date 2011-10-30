require 'delayed_job'
class FeedFetcher

  def initialize(feed)
    @feed = feed
  end
  def fetch()
    puts ("****** Fetch")
    puts "enqueuing"
    Delayed::Job::enqueue self
  end
  
  def self.fetch_all
    Feed.all.each do |feed|
      self.new(feed).fetch()
    end
  end

  def perform
    puts ("**** perform")
    rss = ::Feedzirra::Feed.fetch_and_parse(@feed.url)

    ActiveRecord::Base::transaction do
      @feed.title = rss.title
      @feed.feed_updated_at = rss.last_modified
      @feed.save!
      rss.entries.slice(0,3).each do |item|
        unless @feed.posts.find_by_url(item.url)
          @feed.posts.create! :title => item.title, :url => item.url
        end
      end
    end
  end
end