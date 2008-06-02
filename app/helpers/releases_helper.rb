module ReleasesHelper
  def submit_text(release)
    return "Add release" if release.new_record?
    "Update release"
  end
  
  def release_cell(story)
    "<td id='#{dom_id(story, "release")}'>#{story.release.description if story.release}</td>"
  end
end
