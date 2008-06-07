class ReleasesController < ApplicationController
  def new
    @release = Release.new
  end

  def edit
    @release = Release.find(params[:id])
  end

  def update
    @release = Release.find(params[:id])
    if @release.update_attributes(params[:release])
      flash[:notice] = "Release updated"
      redirect_to release_stories_path(@release)
    else
      render :action=>:edit
    end
  end
  
  def drop_release
    @story = Story.find(params[:story_id])
    @previous_release = @story.release
    @release = Release.find(params[:id])
    @story.update_attributes(:release=>@release)
  end
  
  def drop_unassign_release
    @story = Story.find(params[:story_id])
    @previous_release = @story.release
    @story.update_attributes(:release=>nil) 
    render :action=>:drop_release
  end

  def create
    @release = Release.new(params[:release])
    if @release.save
      flash[:notice]='Release created'
      redirect_to release_stories_path(@release)
    else
      render :action=>:new
    end
  end
end
