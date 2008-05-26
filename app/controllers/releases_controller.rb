class ReleasesController < ApplicationController
  def new
    @release = Release.new
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
