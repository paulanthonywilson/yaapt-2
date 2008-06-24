module StoriesHelper
  def story_status(story)
    "<span class='#{h story.status}'>#{h story.status}</span>"
  end

  def advance_button(story, release=nil)
    return "" if story.status == 'done'
    return "" unless story.release_id
    return "" unless release
    link_to_remote image_tag('advance.png', :alt=>'advance'), {:url=>advance_story_path(story), :method => :put}
  end


  def new_story_link(release)
    link_to "Add story", release ? new_release_story_path(@release) : new_story_path
  end

  def release_description_cell(story, release)
    unless release
      "<div id='#{dom_id(story, 'release')}'>#{release_description_content(story)}</div>"
    end
  end
  
  def release_description_content(story)
    link_to story.release.description, release_stories_path(story.release) if story.release
  end
  
  def stories_container_id
  end
  
  def title
    return @title if @title
    return @release.description if @release
    "Stories"
  end
end
