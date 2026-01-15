package domain

// Recommendation represents a title recommendation for a household.
// Must include confidence (invariant #2) and explainable reasons (invariant #3).
type Recommendation struct {
	Title      Title
	Confidence Confidence
	Reasons    []string // Explainable per invariant #3
	Score      float64
}

// Confidence represents how confident the system is in a recommendation.
// Must be displayed to users per invariant #2.
type Confidence struct {
	Value float64 // 0.0 to 1.0
	Label string  // Human-readable label
}

// NewConfidence creates a confidence with appropriate label.
func NewConfidence(value float64) Confidence {
	var label string
	switch {
	case value >= 0.8:
		label = "High"
	case value >= 0.5:
		label = "Medium"
	case value > 0:
		label = "Low"
	default:
		label = "Unknown"
	}

	return Confidence{
		Value: value,
		Label: label,
	}
}

// ConfidencePercent returns confidence as a percentage (0-100).
func (c Confidence) Percent() int {
	return int(c.Value * 100)
}

// Assessment represents a value assessment of a subscription.
// Used for value-based guidance per invariant #9.
type Assessment struct {
	Subscription    Subscription
	PlatformWatches int
	UsagePercentage float64
	DaysSinceUse    int
	Pros            []string
	Cons            []string
}

// ShouldCancel returns true if the subscription provides low value.
func (a *Assessment) ShouldCancel() bool {
	return a.DaysSinceUse > 60 && a.UsagePercentage < 0.1
}

// Underutilized returns true if the subscription could be used more.
func (a *Assessment) Underutilized() bool {
	return a.DaysSinceUse > 30 || a.UsagePercentage < 0.3
}

// ValueRating returns a simple value assessment.
func (a *Assessment) ValueRating() string {
	if a.ShouldCancel() {
		return "low"
	}
	if a.Underutilized() {
		return "medium"
	}
	return "high"
}

// Intelligence represents aggregated subscription intelligence for a household.
type Intelligence struct {
	Assessments       []Assessment
	PotentialSavings  float64
	Recommendations   []SubscriptionRecommendation
	OptimizationTarget string
	SuccessMetrics    []string
}

// SubscriptionRecommendation represents a recommended action for a subscription.
type SubscriptionRecommendation struct {
	Subscription       Subscription
	Action             string // "cancel", "keep", "subscribe"
	ValueAssessment    string
	Cost               float64
	Benefit            string
	UserBenefitReason  string
}

// ReasonIsEngagementOnly returns true if this recommendation is solely engagement-based.
// Per invariant #9, we must not recommend subscriptions solely for engagement.
func (r *SubscriptionRecommendation) ReasonIsEngagementOnly() bool {
	return false // We never do engagement-only recommendations
}

// CancelRecommendations returns subscriptions that should be cancelled.
func (i *Intelligence) CancelRecommendations() []SubscriptionRecommendation {
	var cancels []SubscriptionRecommendation
	for _, rec := range i.Recommendations {
		if rec.Action == "cancel" {
			cancels = append(cancels, rec)
		}
	}
	return cancels
}
