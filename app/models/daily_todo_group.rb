class DailyTodoGroup < ActiveRecord::Base
  belongs_to :user
  has_many :daily_todo_group_detail,  :dependent => :destroy
end
