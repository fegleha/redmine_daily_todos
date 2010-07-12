class DailyTodosSchema < ActiveRecord::Migration
  def self.up
   create_table :daily_todo_groups do |t|
    t.string    :group_name
   end
   
   create_table :daily_todo_group_details do |t|
    t.integer   :daily_todo_group_id
    t.integer   :user_id
   end
  end
  
  def self.down
    drop_table :daily_todo_groups
    drop_table :daily_todo_group_details
  end
end
