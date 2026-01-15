# frozen_string_literal: true

# ViewingRecord tracks a member's viewing progress on a title.
# This is used to prevent re-recommending fully watched content.
#
# Invariant: System must not re-recommend titles fully watched by the household
class ViewingRecord < ApplicationRecord
  belongs_to :member
  belongs_to :title

  validates :progress, presence: true,
                       numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :member_id, uniqueness: { scope: :title_id }

  scope :fully_watched, -> { where(fully_watched: true) }
  scope :in_progress, -> { where(fully_watched: false).where("progress > 0") }

  # Mark as fully watched
  def mark_complete!
    update!(fully_watched: true, progress: 1.0)
  end
end
