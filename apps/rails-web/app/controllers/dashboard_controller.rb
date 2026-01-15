# frozen_string_literal: true

class DashboardController < ActionController::Base
  layout "application"

  def index
    @household = Household.first
    return render_empty_state unless @household

    @members = @household.members
    @current_member = @members.first
    @recommendations = RecommendationEngine.for_household(@household)
    @subscriptions = @household.subscriptions.active
    @intelligence = SubscriptionIntelligence.for_household(@household)
    @recent_history = @household.viewing_records
                                .includes(:title, :member)
                                .order(updated_at: :desc)
                                .limit(5)

    @stats = {
      total_watched: @household.fully_watched_titles.count,
      in_progress: @household.in_progress_titles.count,
      subscriptions: @subscriptions.count,
      potential_savings: @intelligence.potential_savings
    }
  end

  private

  def render_empty_state
    @empty_state = true
    render :index
  end
end
