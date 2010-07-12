class DailyTodosController < ApplicationController
  # Avoid "A copy of ApplicationController has been removed from the module tree but is still active!"
  unloadable

  ONE_WEEK = 7

  before_filter :require_login

  # Show TODOs of all active users.
  def all_users
    @date = (params[:date])? Date.parse(params[:date]) : Date.today
    ungroup_users = User.all(:conditions => {:status => User::STATUS_ACTIVE}, :order => 'login')

    @reported = false
    @daily_todo_groups = DailyTodoGroup.all(:order => "group_name")
    @daily_todo_group_todo = Array.new()
    @daily_todo_group_no_todo = Array.new()
    @daily_todo_group_todo_has_user = false
    @daily_todo_group_no_todo_has_user = false

    @daily_todo_groups.each() { |group|
      list_user_of_group = DailyTodoGroupDetail.all(:conditions => {:daily_todo_group_id => group.id})
      no_todo_group_detail, todo_group_detail = list_user_of_group.partition do |group_detail|
        DailyTodo.first(:conditions => {:user_id => group_detail.user.id, :date => @date}).nil?
      end
      @daily_todo_group_no_todo.push(no_todo_group_detail)
      @daily_todo_group_todo.push(todo_group_detail)
      @daily_todo_group_no_todo_has_user = @daily_todo_group_no_todo_has_user || !no_todo_group_detail.empty?
      @daily_todo_group_todo_has_user = @daily_todo_group_todo_has_user || !todo_group_detail.empty?

      # Check if the current user has written todo for this date
      @reported = @reported || todo_group_detail.any? { |group_detail|
        group_detail.user.id == User.current.id
      }

      list_user_of_group.each() { |group_detail|
        ungroup_users.delete_if { |user|
          user.id == group_detail.user_id
        }
      }
    }

    @no_todo_ungroup_detail, @todo_ungroup_detail = ungroup_users.partition do |user|
      DailyTodo.first(:conditions => {:user_id => user.id, :date => @date}).nil?
    end
    @daily_todo_group_no_todo_has_user = @daily_todo_group_no_todo_has_user || !@no_todo_ungroup_detail.empty?
    @daily_todo_group_todo_has_user = @daily_todo_group_todo_has_user || !@todo_ungroup_detail.empty?

  end

  # Shows TODOs within one week of a specified user.
  #
  # If there is no TODOs for a date:
  # * If the current user is the specified user: display link to create TODOS for that date
  # * Else shows that the user has not created TODOs for that date
  def one_user
    @DATE_WITH_WEEKDAY_FORMAT = "%A %d-%m-%y"
    @user = User.find(params[:user_id])
    @date = (params[:date])? Date.parse(params[:date]) : Date.today
    
    #    todos = DailyTodo.all(
    #      :conditions => ["user_id = ? AND (date <= ? AND date >= ?)", params[:user_id], @date, @date - ONE_WEEK + 1],
    #      :order      => 'date'  # ASC because "range" below is increasing
    #    )
    #    range = (@date - ONE_WEEK + 1)..@date
    next_3_days_date = @date + 3
    todos = DailyTodo.all(
      :conditions => ["user_id = ? AND (date <= ? AND date >= ?)", params[:user_id], next_3_days_date, @date - ONE_WEEK + 1],
      :order      => 'date'  # ASC because "range" below is increasing
    )
    range = (@date - ONE_WEEK + 1)..next_3_days_date
   
    @todos = if todos.empty?
      range.map do |date|
        DailyTodo.new(:user_id => @user.id, :date => date)
      end
    else
      i = 0
      range.map do |date|
        if  i >= todos.size || date < todos[i].date
          DailyTodo.new(:user_id => @user.id, :date => date)
        else
          i += 1
          todos[i - 1]
        end
      end
    end
    
    @todos.reverse!
  end

  def create_todo
    if request.post?
      date = (params[:date])? Date.parse(params[:date]) : Date.today
      time = Time.now
      reported = (DailyTodo.find(:first, :conditions => {:user_id => User.current.id, :date => date}) != nil)
      if reported
        flash[:error] = l(:'daily_todos.todo.create_error')
      else
        todo = DailyTodo.new(:date => date, :lunch => time, :user_id => User.current.id )
        todo.save
      end
      render :js => "window.location = '" + url_for(:action => 'one_user', :user_id => User.current.id, :date => date) + "'"
    end
  end
  
  def update
    if request.put?
      @todo = DailyTodo.find(params[:id])
      pdr = params[:daily_todo]
      @todo.lunch = Time.mktime(@todo.date.year, @todo.date.month,@todo.date.day, pdr['lunch(4i)'], pdr['lunch(5i)'])
      @todo.save
      redirect_to(:action => 'one_user', :user_id => User.current.id)
    end
  end
  
  def destroy
    if request.delete?
      todo = DailyTodo.find(params[:id])
      if todo.user_id != User.current.id
        flash[:error] = l(:'daily_todos.todo.delete_error')
      else
        flash[:notice] = l(:'daily_todos.todo.delete')
        todo.destroy
      end
      render :js => "window.location = '" + url_for(:action => 'one_user', :user_id => User.current.id) + "'"
    end
  end
end
