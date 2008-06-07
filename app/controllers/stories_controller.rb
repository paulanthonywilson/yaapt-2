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
    if @release
      @stories_container_id = 'story_list'
      @stories = @release.stories
    else
      @stories_container_id = 'all_story_list'
      @listing_all_stories = true
      @stories = Story.find(:all)
    end
  end 
  
  def unassigned
    @stories_container_id = 'story_list'
    @stories = Story.unassigned
    @title = "Unassigned stories"
    @listing_unassigned_stories = true
    render :action=>:index
  end

  def update
    @story = Story.find(params[:id]) 
    if @story.update_attributes(params[:story])  
      flash[:notice]="Story updated"
      redirect_to path_after_save
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
      redirect_to path_after_save
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
  
  def path_after_save
    return release_stories_path(@story.release) if @story.release
    unassigned_stories_path
  end
  
end
