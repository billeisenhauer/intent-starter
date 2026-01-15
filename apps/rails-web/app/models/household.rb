# frozen_string_literal: true

# Household represents a group of people who share viewing preferences
# and subscription decisions. This is the primary unit of the system.
#
# Invariant: Household members must be first-class entities
class Household < ApplicationRecord
  class MembershipError < StandardError; end

  has_many :members, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :viewing_records, through: :members

  validates :name, presence: true

  # Returns all titles watched by any member of this household
  def all_watched_titles
    Title.joins(:viewing_records)
         .where(viewing_records: { member_id: members.pluck(:id) })
         .distinct
  end

  # Returns all titles fully watched by any member
  def fully_watched_titles
    Title.joins(:viewing_records)
         .where(viewing_records: { member_id: members.pluck(:id), fully_watched: true })
         .distinct
  end

  # Returns all titles in progress (started but not fully watched)
  def in_progress_titles
    Title.joins(:viewing_records)
         .where(viewing_records: { member_id: members.pluck(:id), fully_watched: false })
         .distinct
  end

  # Check if any member has watched a given title
  def watched_by_any?(title)
    viewing_records.where(title: title).exists?
  end

  # Check if any member has fully watched a given title
  def fully_watched_by_any?(title)
    viewing_records.where(title: title, fully_watched: true).exists?
  end

  # Add a member to the household
  def add_member(name:)
    members.create!(name: name)
  end

  # Remove a member from the household
  # Raises MembershipError if this would leave the household with no members
  def remove_member(member)
    if members.count <= 1
      raise MembershipError, "Cannot remove last member from household"
    end

    member.destroy!
  end

  # Check if a member belongs to this household
  def includes_member?(member_id)
    members.exists?(id: member_id)
  end
end
