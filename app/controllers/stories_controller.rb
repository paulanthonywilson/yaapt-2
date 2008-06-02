class StoriesController < ApplicationController 
  before_filter :load_release

  def new 
    @story = Story.new
    @story.release = @release
  end 

  def edit 
    @story = Story.find(params[:id])
  end 

  def index 
    @stories = 
    if @release
      @release.stories
    else
      Story.find(:all)
    end
  end 

  def update
    @story = Story.find(params[:id]) 
    if @story.update_attributes(params[:story])  
      flash[:notice]="Story updated"
      redirect_to release_stories_path(@story.release)
    else
      render :action=>:edit
    end
  end

  def advance
    @story = Story.find(params[:id]) 
    unless @story.advance!
      render(:update) {|page| page.alert "Failed to advance story"}
    end
  end

  def create 
    @story =Story.new(params[:story])
    if @story.save
      flash[:notice]="Story created"
      redirect_to release_stories_path(@story.release)
    else 
      render :action=>:new
    end
  end 

  def destroy  
    story = Story.find(params[:id])
    story.destroy
    flash[:notice]="Story removed"
    redirect_to release_stories_path(story.release)
  end

  private 
  def load_release
    @release = Release.find(params[:release_id]) if params[:release_id] 
  end
end
