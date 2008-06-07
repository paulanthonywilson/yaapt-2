# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def errors_for(object)  
    error_messages_for object, {:header_message=>nil, :message=>nil}
  end  
  
  def rjs_update_estimate_total(page, release)
    page.select('#' + dom_id(release, 'estimate_total')).each {|item| item.update(release.estimate_total)}
  end 
end
