# frozen_string_literal: true

# Title represents a movie or TV series that can be watched.
# Titles are identified by an external_id (e.g., TMDB, IMDB).
class Title < ApplicationRecord
  TITLE_TYPES = %w[movie series].freeze

  has_many :viewing_records, dependent: :destroy
  has_many :availability_observations, dependent: :destroy

  validates :external_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :title_type, presence: true, inclusion: { in: TITLE_TYPES }

  scope :movies, -> { where(title_type: "movie") }
  scope :series, -> { where(title_type: "series") }

  def movie?
    title_type == "movie"
  end

  def series?
    title_type == "series"
  end
end
