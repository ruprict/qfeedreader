require 'delayed_job'
class FeedFetcher
  class << self
    attr_accessor :use_transactions
    @use_transactions ||= false
  end
  def initialize(feed)
    @feed = feed
  end
  def fetch()
    puts ("****** Fetch")
    puts "enqueuing"
    unless Delayed::Job.exists?(:handler => Delayed::Job.new(:payload_object => self).handler, :locked_at => nil)
      puts "****** adding job"
      Delayed::Job::enqueue self  
    else
      puts "***** job exists"
    end
  end
  
  def self.fetch_all
    Feed.all.each do |feed|
      self.new(feed).fetch()
    end
  end

  def perform
    puts ("**** perform")
    rss = ::Feedzirra::Feed.fetch_and_parse(@feed.url)
    update_feed(rss)
    if FeedFetcher.use_transactions
      puts "*** USING TRANSACTION ***"
      ActiveRecord::Base::transaction do
        update_feed(rss)
      end
    else
        update_feed(rss)
    end
  end

  private

  def update_feed(rss)
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
