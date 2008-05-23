class ReleasesController < ApplicationController
  def new
    @release = Release.new
  end
end
