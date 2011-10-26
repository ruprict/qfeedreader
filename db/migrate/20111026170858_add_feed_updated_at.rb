class AddFeedUpdatedAt < ActiveRecord::Migration
  def up
    change_table :feeds do |t|
      t.datetime :feed_updated_at
    end
    Feed.all.each do |f|
      f.feed_updated_at = f.updated_at
      f.save
    end
  end

  def down
    remove_column :feeds, :feed_updated_at
  end
end
