class DailyTodoGroupsController < ApplicationController
  before_filter :require_admin

  before_filter :load_all_groups, :only => [:show, :edit]

  def load_all_groups
    @daily_todo_groups = DailyTodoGroup.all(:order => "group_name")
  end

  def show
    @daily_todo_group = DailyTodoGroup.new
  end

  def create
    if request.post?
      @daily_todo_group = DailyTodoGroup.new(params[:daily_todo_group])
      if not_exist_group_name?(@daily_todo_group.group_name)
        if @daily_todo_group.save
          flash[:notice] = @daily_todo_group.group_name.to_s + " " + l(:'daily_todos.group.added')
          redirect_to :action => "show", :id => @daily_todo_group.id
        else
          redirect_to :action => :show
        end
      else
        flash[:error] = l(:'daily_todos.group.exist_group')
        redirect_to :action => :show
      end
    end
  end

  def edit
    @daily_todo_group = DailyTodoGroup.find(params[:id])
  end

  def update
    if request.put?
      @daily_todo_group = DailyTodoGroup.find(params[:id])
      if not_exist_group_name?(params[:daily_todo_group]['group_name'])
        @daily_todo_group.update_attributes(params[:daily_todo_group])
        if @daily_todo_group.save
          flash[:notice] = l(:'daily_todos.group.updated')
          redirect_to(:action => 'show')
        else
          render(:action => 'edit', :id => @daily_todo_group.id)
        end
      else
        flash[:error] = l(:'daily_todos.group.exist_group')
        redirect_to(:action => :edit,
          :id => @daily_todo_group.id)
      end
    end
  end

  def destroy
    if request.delete?
      daily_todo_group = DailyTodoGroup.find(params[:id])
      daily_todo_group.destroy
      flash[:notice] = daily_todo_group.group_name.to_s + " " + l(:'daily_todos.group.deleted')
      redirect_to(:controller => 'daily_todo_groups', :action => 'show')
    end
  end

  def not_exist_group_name?(group_name)
    return DailyTodoGroup.find_by_group_name(group_name).nil?
  end
end
