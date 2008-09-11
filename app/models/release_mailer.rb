
class ReleaseMailer < ActionMailer::Base

  File.open(File.dirname(__FILE__) + "/../../config/emailees_#{ENV['RAILS_ENV'] || 'development'}.yml") do |f|
    @@recipients = YAML::load(f.read)
  end

  def summary_for(release)
    subject    "Status summary for release #{release.description}"
    recipients @@recipients
    from       'yaapt'
    sent_on    Time::now

    part(:content_type=>'image/jpeg') do |p|
      p.body = release.to_burndown_graph(450, 'jpeg')   
      p.transfer_encoding = "base64"
      p.content_disposition = "inline; filename ='burndown.jpg'"
    end


    part :content_type=> 'text/html' do |p|    
      p.body=%(<html><body>
      <h1>#{release.name} - status summary</h1>
      <p>Status summary for release <span id='release_name'>#{release.name}</span> due on 
      <span id='release_date'>#{release.release_date.strftime('%d %B %Y')}</span>.</p>
      <p>Todo: <span id='todo'>#{release.total_todo}</span>
      <br/>
      Done: <span id='done'>#{release.total_done}</span></p>
      <br/>
      <h2>Done</h2>
      #{table_for(release, 'done')}
      <h2>In progress</h2>
      #{table_for(release, 'in_progress')}
      <h2>Unstarted</h2>
      #{table_for(release, 'unstarted')}
      </body></html>)
    end




  end
  
  private
  
  def table_for(release, status)
    stories = release.send "#{status}_stories"
    %(
    <table id='#{status}' width='450px' border='1' cellpadding='5'>
    <tr><th>Story</th><th>Points</th></tr>
    #{story_rows(stories)}
    </table>
    
    )
  end
  
  def story_rows(stories)
    stories.inject("") do |memo, story|
      memo << "<tr id='story_#{story.id}'><td align='right' width='70px'>#{story.estimate}</td><td>#{story.body}</td></tr>"
    end
  end


end
