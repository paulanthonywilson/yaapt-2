# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def errors_for(object)  
    error_messages_for object, {:header_message=>nil, :message=>nil}
  end   
end
