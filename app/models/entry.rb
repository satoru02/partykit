class Entry < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_one :notification
  after_create :create_entry_notification

  # fix -> 1postに対して、ユーザーがもつEntryは一つ。何回でもJoinをおせてしまう。

  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  private

    def create_entry_notification
      @target_user_id = self.post.user.id
      Notification.create!(entry_id: self.id, user_id: @target_user_id)
    end
end
