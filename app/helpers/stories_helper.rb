module StoriesHelper
  def story_status(story)
    "<span class='#{h story.status}'>#{h story.status}</span>"
  end
  
  def advance_button(story)
    return "" if story.status == 'done'
    link_to_remote image_tag('advance.png', :alt=>'advance'), {:url=>advance_story_path(story), :method => :put}
  end
  
  def submit_text(story)
    return "Add story" if story.new_record?
    "Update story"
  end
  
end
