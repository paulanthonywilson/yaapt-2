require File.dirname(__FILE__) + '/../test_helper'

class StoriesControllerTest < ActionController::TestCase

  def test_displaying_the_new_form
    get :new
    assert_response :success  
    assert_select "form#new_story" do  
      assert_select "#story_title"
      assert_select "#story_body"
      assert_select "#story_estimate"
    end
  end  

  def test_new_form_contains_no_errors
    get :new   
    assert_select '#errorExplanation', :count=>0
  end  

  def test_displaying_the_edit_form
    get :edit, :id=>stories(:boil_water)
    assert_response :success  
    assert_select "form#edit_story_#{stories(:boil_water).id}" do  
      assert_select "#story_title"                                                   
      assert_select "#story_body"
      assert_select "#story_estimate"
    end
  end

  def test_a_new_story_is_saved
    assert_difference("Story.count") do
      post :create, :story=>{:title=>'A new story', :body=>'as a developer I want this test to pass', :estimate=>1}
    end
    assert_redirect_with_flash({:action=>:index } , 'Story added')
  end  

  def test_updating_a_story_contents    
    story = stories(:boil_water)
    put :update, :id=>story, :story=>{:title=>'Get in hot water'}
    assert_redirect_with_flash({:action=>:index } , 'Story updated')
    assert_equal "Get in hot water", story.reload.title
  end


  def test_destroying_a_story   
    assert_difference("Story.count", -1) do
      put :destroy, :id=>stories(:boil_water)
    end
    assert_redirect_with_flash({:action=>:index } , 'Story removed')
  end  

  def test_failing_to_add_a_story_redisplays_new_story_form_with_error
    assert_difference("Story.count", 0) do 
      post :create, :story=>{:title=>''}
    end
    assert_response :success
    assert_select "form#new_story"
    assert_select "#errorExplanation li", :text=>/Title/      
  end  

  def test_failing_to_edit_a_story_redisplayes_the_edit_form_with_error
    put :update, :id=>stories(:boil_water), :story=>{:title=>''}
    assert_equal 'Boil water', stories(:boil_water).reload.title  
    assert_response :success
    assert_select "form#edit_story_#{stories(:boil_water).id}"

  end


  def test_redirected_to_index_after_save
    post :create, :story=>{:title=>'A new story', :body=>'as a developer I want this test to pass', :estimate=>1}
    assert_redirect_with_flash({:action=>:index } , 'Story added')
  end 

  def test_all_stories_displayed_by_index
    get :index
    assert_response :success
    assert_select '.story', :count=>Story.count
  end  

  def test_there_is_a_link_to_a_new_story_on_the_index_page
    get :index  
    assert_link new_story_path
  end  

  def test_index_stories_have_a_delete_link   
    get :index
    assert_select "a[href='#{story_path(stories(:boil_water))}'] img[alt='destroy']" , nil, "Destroy link for story 'add story'"
  end

  def test_index_stories_have_an_edit_link   
    get :index
    assert_select "a[href='#{edit_story_path(stories(:boil_water))}']" , nil, "Edit link for story 'add story'"
  end 
  
  def test_stories_have_advance_button
    get :index
    assert_select "a img[alt='advance']" , nil, "Advance link for story"
  end

  def test_edit_form_has_status_dropdown
    get :edit, :id=>stories(:boil_water)
    assert_status_dropdown
  end
  
  def test_new_form_has_status_dropdown
    get :new
    assert_status_dropdown
  end
  
  def test_advancing_a_story
    put :advance, :id=>stories(:boil_water)
    assert_redirect_with_flash ({:action=>:index}), 'Story advanced'
    assert_equal 'in_progress', stories(:boil_water).reload.status
  end
  
  def test_failing_to_advance_a_story
    stories(:boil_water).update_attributes(:status=>'done')
    put :advance, :id=>stories(:boil_water)
    assert_redirect_with_flash ({:action=>:index}), 'Story not advanced'
    assert_equal 'done', stories(:boil_water).reload.status
  end

  def assert_status_dropdown
    assert_select 'select#story_status' do
      assert_select 'option[value="unstarted"]'
      assert_select 'option[value="in_progress"]'
      assert_select 'option[value="done"]'
    end
  end
  
end
