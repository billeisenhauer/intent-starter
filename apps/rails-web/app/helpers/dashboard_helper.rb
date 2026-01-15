# frozen_string_literal: true

module DashboardHelper
  # VHS-style avatar gradient colors based on member index
  AVATAR_GRADIENTS = [
    "background: linear-gradient(135deg, var(--neon-magenta), var(--neon-cyan));",
    "background: linear-gradient(135deg, var(--neon-cyan), var(--neon-green));",
    "background: linear-gradient(135deg, var(--neon-amber), var(--neon-magenta));",
    "background: linear-gradient(135deg, var(--neon-green), var(--neon-amber));",
    "background: linear-gradient(135deg, var(--neon-magenta), var(--neon-amber));"
  ].freeze

  def avatar_gradient(index)
    AVATAR_GRADIENTS[index % AVATAR_GRADIENTS.length]
  end

  # Format confidence value for display
  def confidence_percentage(confidence)
    (confidence.value * 100).round
  end

  # VHS-style date formatting
  def vhs_date(date)
    date.strftime("%m.%d.%Y")
  end

  # VHS-style time formatting
  def vhs_time(time)
    time.strftime("%H:%M:%S")
  end
end
