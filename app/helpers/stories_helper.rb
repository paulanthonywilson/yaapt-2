module StoriesHelper
  def story_status(story)
    "<span class='#{h story.status}'>#{h story.status}</span>"
  end

  def advance_button(story)
    return "" if story.status == 'done'
    return "" unless story.release_id
    link_to_remote image_tag('advance.png', :alt=>'advance'), {:url=>advance_story_path(story), :method => :put}
  end

  def submit_text(story)
    return "Add story" if story.new_record?
    "Update story"
  end

  def new_story_link(release)
    link_to "New story", release ? new_release_story_path(@release) : new_story_path
  end

  def release_description_cell(story, release)
    unless release
      "<td id='#{dom_id(story, 'release')}'>#{link_to story.release.description, release_stories_path(story.release) if story.release}</td>"
    end
  end
  def title
    return @title if @title
    return @release.description if @release
    "Stories"
  end
end
