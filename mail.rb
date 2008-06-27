require File.dirname(__FILE__) + "/config/environment"

ReleaseMailer.deliver_summary_for Release.find_by_name('Tea and biscuits')

