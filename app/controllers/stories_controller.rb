class StoriesController < ApplicationController 
  def new 
    @story = Story.new
  end  
  
  def index 
    @stories = Story.find(:all)
  end
    
  def create 
    @story = Story.new(params[:story])
    @story.save
    redirect_to :action=>:index
  end 
  
  def destroy  
    Story.find(params[:id]).destroy
    redirect_to :action=>:index
  end
    
end
