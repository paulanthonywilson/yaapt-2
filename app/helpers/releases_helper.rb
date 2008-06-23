module ReleasesHelper

  
  def release_cell(story)
    "<td id='#{dom_id(story, "release")}'>#{story.release.description if story.release}</td>"
  end
end
