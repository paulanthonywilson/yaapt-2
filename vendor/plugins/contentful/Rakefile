require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the contentful plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the contentful plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Contentful'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Generate source for contentful.rubyforge.org site from README.'
Rake::RDocTask.new(:prepare_temp_site_doc) do |rdoc|
  rdoc.rdoc_dir = 'temp_site_doc'
  rdoc.options << '--quiet'
  rdoc.rdoc_files.include('README')
end

desc 'Update contentful.rubyforge.org site page.'
task :site => :prepare_temp_site_doc do
  require 'rexml/document'
  require 'rubygems'
  require 'markaby'
  File.open('temp_site_doc/index.html', 'w') do |site_index|
    rdoc_xml = REXML::Document.new(File.new('temp_site_doc/files/README.html'))
    site_index.write Markaby::Builder.new.xhtml_transitional {
      head { title "Contentful: a content testing plug-in for Rails" }
      body { 
        div.logo! { img :src=>'bear.jpg', :alt=>'Contentful Bear' }
        text REXML::XPath.first(rdoc_xml, "//div[@id='description']")
      }
    }
  end
  system('scp temp_site_doc/index.html ' +
         'anthonybailey@rubyforge.org:/var/www/gforge-projects/contentful/')
  FileUtils.rm_rf('temp_site_doc')
end
