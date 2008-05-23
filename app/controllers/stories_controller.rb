class StoriesController < ApplicationController 
  def new 
    @story = Story.new
  end 

  def edit 
    @story = Story.find(params[:id])
  end 

  def index 
    @stories = Story.find(:all)
  end 

  def update
    @story = Story.find(params[:id]) 
    if @story.update_attributes(params[:story])  
      flash[:notice]="Story updated"
      redirect_to :action=>:index 
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
    @story = Story.new(params[:story])
    if @story.save
      flash[:notice]="Story added"
      redirect_to :action=>:index  
    else 
      render :action=>:new
    end
  end 

  def destroy  
    Story.find(params[:id]).destroy
    flash[:notice]="Story removed"
    redirect_to :action=>:index
  end

end
