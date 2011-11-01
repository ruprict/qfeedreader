require 'feed_fetcher/feed_fetcher'
class FeedsController < ApplicationController
  def index
    @feeds = Feed.all(:include=>:posts)
  end

  def show
    @feed = Feed.find(params[:id])
    ::FeedFetcher.new(@feed).fetch()
    if stale?(:last_modified => @feed.feed_updated_at)
      render :partial => 'feed', :locals => { :feed => @feed }
    else
      response['Cache-Control'] = 'public, max-age=1'
    end
  end

  def new
    @feed = Feed.new
  end

  def create
    @feed = Feed.new(:url => params[:url])
    @feed.feed_updated_at = Time.now.months_ago(2)
      notice = "Failed"
    if @feed.save
      notice = "Successfully created feed."
    end
    redirect_to :action => :index, :notice => notice
  end

  def edit
    @feed = Feed.find(params[:id])
  end

  def update
    @feed = Feed.find(params[:id])
    if @feed.update_attributes(params[:feed])
      redirect_to @feed, :notice  => "Successfully updated feed."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @feed = Feed.find(params[:id])
    @feed.destroy
    redirect_to feeds_url, :notice => "Successfully destroyed feed."
  end

  def refresh
    ::FeedFetcher.new(Feed.find(params[:id])).fetch()
    head :ok
  end

  def refresh_all
    ::FeedFetcher.fetch_all
    head :ok
  end
end
