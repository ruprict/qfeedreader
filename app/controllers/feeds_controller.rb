class FeedsController < ApplicationController
  def index
    @feeds = Feed.all(:include=>:posts)
  end

  def show
    @feed = Feed.find(params[:id])
  end

  def new
    @feed = Feed.new
  end

  def create
    @feed = Feed.new(:url => params[:url])
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
    Feed.find(params[:id]).fetch
    head :ok
  end

  def refresh_all
    Feed.fetch_all
    head :ok
  end
end
