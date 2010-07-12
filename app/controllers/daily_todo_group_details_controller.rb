class DailyTodoGroupDetailsController < ApplicationController
  before_filter :require_admin

  before_filter :load_all_group_details, :only => [:show, :edit]

  def load_all_group_details
    @daily_todo_groups = DailyTodoGroup.all(:order => "group_name")
    @daily_todo_group_details = Array.new()
    @daily_todo_groups.each() { |group|
      list_user_of_group = DailyTodoGroupDetail.all(:conditions => {:daily_todo_group_id => group.id})
      @daily_todo_group_details.push(list_user_of_group)
    }

    users = User.all(:conditions => {:status => User::STATUS_ACTIVE})
    @daily_todo_user_no_group, @daily_todo_user_group = users.partition do |user|
      DailyTodoGroupDetail.first(:conditions => {:user_id => user.id}).nil?
    end

    @daily_todo_user_no_group_for_select = Array.new()
    @daily_todo_user_no_group.each() { |user|
      @daily_todo_user_no_group_for_select.push(user)
    }
    @daily_todo_group_for_select = Array.new()
    @daily_todo_groups.each() { |group|
      @daily_todo_group_for_select.push([group.group_name, group.id])
    }

  end

  def show
    @daily_todo_group_detail = DailyTodoGroupDetail.new
  end

  def create
    if request.post?
      user_select = params["user_select"]
      group_select = params["group_select"]
      save_status = true
      list_new_user =  Array.new()
      str_users = ""
      user_select.each() { |user_id|
        daily_todo_group_detail = DailyTodoGroupDetail.new
        daily_todo_group_detail.daily_todo_group_id = group_select
        daily_todo_group_detail.user_id = user_id
        save_status = save_status && daily_todo_group_detail.save
        user = User.find_by_id(user_id)
        list_new_user.push(user)
        str_users += user.name + ", "
      }
      str_users = str_users[0, str_users.length - 2]
      if(save_status)
        group = DailyTodoGroup.find_by_id(group_select)
        flash[:notice] = str_users + " " +
          l(:'daily_todos.group_detail.joined') + " " + group.group_name
      else
        flash[:notice] = l(:'daily_todos.group_detail.added_error')
      end
      redirect_to :action => "show"
    end
  end

  def destroy
    if request.delete?
      daily_todo_group_detail = DailyTodoGroupDetail.find(params[:id])
      daily_todo_group_detail.destroy
      flash[:notice] = daily_todo_group_detail.user.name + " " +
        l(:'daily_todos.group_detail.left') + " " + daily_todo_group_detail.daily_todo_group.group_name
      redirect_to :action => 'show'
    end
  end
end
