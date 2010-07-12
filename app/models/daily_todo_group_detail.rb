class DailyTodoGroupDetail < ActiveRecord::Base
  belongs_to :user
  belongs_to :daily_todo_group
end
