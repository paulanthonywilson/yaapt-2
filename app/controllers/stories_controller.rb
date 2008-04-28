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
    @story.update_attributes(params[:story])  
    flash[:notice]="Story updated"
    redirect_to :action=>:index
  end
    
  def create 
    @story = Story.new(params[:story])
    @story.save
    flash[:notice]="Story added"
    redirect_to :action=>:index
  end 
  
  def destroy  
    Story.find(params[:id]).destroy
    flash[:notice]="Story removed"
    redirect_to :action=>:index
  end
    
end
