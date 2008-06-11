class StoriesController < ApplicationController 
  before_filter :load_release_and_story

  def new 
    @story = Story.new
    @story.release = @release
  end 

  def index 
    if @release
      @stories = @release.stories
      @stories_container_id = 'story_list' 
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
    if @story.update_attributes(params[:story])  
      flash[:notice]="Story updated"
      redirect_to path_after_save
    else
      render :action=>:edit
    end
  end

  def advance
    unless @story.advance!
      render(:update) {|page| page.alert "Failed to advance story"}
    end
  end

  def create 
    @story =Story.new(params[:story])
    if @story.save
      flash[:notice]="Story created"
      respond_to do |f|
        f.html {redirect_to path_after_save}
        f.js 
      end
    else 
      respond_to do |f|
        f.html {render :action=>:new}
        f.js {render :action=>'create_error'}
      end
    end
  end 

  def destroy  
    @story.destroy
    flash[:notice]="Story removed"
    redirect_to @story.release ? release_stories_path(@story.release) : unassigned_stories_path
  end



  private 
  def load_release_and_story
    @release = Release.find(params[:release_id]) if params[:release_id] 
    @story = Story.find(params[:id]) if params[:id]
  end

  def path_after_save
    return release_stories_path(@story.release) if @story.release
    unassigned_stories_path
  end

end
