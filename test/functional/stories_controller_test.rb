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
  
  
end
