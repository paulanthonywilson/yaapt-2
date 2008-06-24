# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def errors_for(object)  
    error_messages_for object, {:header_message=>nil, :message=>nil}
  end  
  
  def rjs_update_left_todo(page, release)
    page.select('#' + dom_id(release, 'left_todo')).each {|item| item.update(release.left_todo)} if release
  end 
  
  def selected_link(text)
    content_tag 'span', text, :class=>'selected_link'
  end
  
  def submit_text(model)
    return "Add #{model.class.to_s.downcase}" if model.new_record?
    "Update #{model.class.to_s.downcase}"
  end
  
end
