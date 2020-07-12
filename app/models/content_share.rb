#
# Copyright (C) 2019 - present Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

class ContentShare < ActiveRecord::Base

  belongs_to :user
  belongs_to :content_export

  validates :read_state, inclusion: { in: %w(read unread) }

  before_create :set_root_account_id

  scope :by_date, -> { order(created_at: :desc) }
  scope :with_content, -> { joins(:content_export) }

  def clone_for(receiver)
    receiver.received_content_shares.create!(sender_id: self.user_id,
                                             content_export_id: self.content_export_id,
                                             name: self.name,
                                             read_state: 'unread')
  end

  def set_root_account_id
    self.root_account_id = self.content_export&.context&.root_account_id if self.content_export&.context.respond_to?(:root_account_id)
  end
end
