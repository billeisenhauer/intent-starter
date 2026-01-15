package service

import (
	"context"

	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/domain"
	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/repository"
)

// SubscriptionIntelligence analyzes subscription value for households.
// Implements invariant #9: Subscription intelligence must provide value-based guidance,
// not maximize engagement.
type SubscriptionIntelligence struct {
	subscriptionRepo repository.SubscriptionRepository
	viewingRepo      repository.ViewingRecordRepository
}

// NewSubscriptionIntelligence creates a new subscription intelligence service.
func NewSubscriptionIntelligence(
	subscriptionRepo repository.SubscriptionRepository,
	viewingRepo repository.ViewingRecordRepository,
) *SubscriptionIntelligence {
	return &SubscriptionIntelligence{
		subscriptionRepo: subscriptionRepo,
		viewingRepo:      viewingRepo,
	}
}

// ForHousehold generates subscription intelligence for a household.
func (s *SubscriptionIntelligence) ForHousehold(ctx context.Context, household *domain.Household) (*domain.Intelligence, error) {
	if household == nil {
		return &domain.Intelligence{
			OptimizationTarget: "user_value",
			SuccessMetrics:     []string{"potential_savings", "content_match"},
		}, nil
	}

	subscriptions, err := s.subscriptionRepo.FindActiveByHousehold(ctx, household.ID)
	if err != nil {
		return nil, err
	}

	var assessments []domain.Assessment
	var totalPotentialSavings float64

	for _, sub := range subscriptions {
		assessment := s.assessSubscription(ctx, sub, household)
		assessments = append(assessments, assessment)

		if assessment.ShouldCancel() {
			cost, _ := sub.MonthlyCost.Float64()
			totalPotentialSavings += cost
		}
	}

	recommendations := s.generateRecommendations(assessments)

	return &domain.Intelligence{
		Assessments:        assessments,
		PotentialSavings:   totalPotentialSavings,
		Recommendations:    recommendations,
		OptimizationTarget: "user_value", // Invariant #9
		SuccessMetrics:     []string{"potential_savings", "content_match"},
	}, nil
}

// assessSubscription evaluates the value of a subscription.
func (s *SubscriptionIntelligence) assessSubscription(ctx context.Context, sub domain.Subscription, household *domain.Household) domain.Assessment {
	// Count platform watches
	platformWatches, _ := s.viewingRepo.CountByHouseholdAndPlatform(ctx, household.ID, sub.Platform)

	// Calculate usage percentage (simplified)
	usagePercentage := float64(platformWatches) / 30.0 // Assume 30 as "full usage"
	if usagePercentage > 1.0 {
		usagePercentage = 1.0
	}

	// Days since last use
	daysSinceUse := sub.DaysSinceLastWatch()

	// Generate pros and cons
	var pros, cons []string

	// Analyze pros
	if daysSinceUse < 7 {
		pros = append(pros, "Recently used")
	}
	if usagePercentage > 0.5 {
		pros = append(pros, "Good content consumption")
	}
	if platformWatches > 10 {
		pros = append(pros, "High engagement with platform content")
	}

	// Analyze cons
	if daysSinceUse > 30 {
		cons = append(cons, "Not used in over a month")
	}
	if daysSinceUse > 60 {
		cons = append(cons, "Consider canceling - inactive for 60+ days")
	}
	if usagePercentage < 0.1 {
		cons = append(cons, "Very low utilization of subscription")
	}

	return domain.Assessment{
		Subscription:    sub,
		PlatformWatches: platformWatches,
		UsagePercentage: usagePercentage,
		DaysSinceUse:    daysSinceUse,
		Pros:            pros,
		Cons:            cons,
	}
}

// generateRecommendations creates action recommendations from assessments.
func (s *SubscriptionIntelligence) generateRecommendations(assessments []domain.Assessment) []domain.SubscriptionRecommendation {
	var recs []domain.SubscriptionRecommendation

	for _, a := range assessments {
		var action, valueAssessment, benefit, userBenefitReason string
		cost, _ := a.Subscription.MonthlyCost.Float64()

		if a.ShouldCancel() {
			action = "cancel"
			valueAssessment = "low"
			benefit = "Save money on unused service"
			userBenefitReason = "You haven't used this service in a while"
		} else if a.Underutilized() {
			action = "keep"
			valueAssessment = "medium"
			benefit = "Some content available"
			userBenefitReason = "Could be used more frequently"
		} else {
			action = "keep"
			valueAssessment = "high"
			benefit = "Good value for content consumed"
			userBenefitReason = "Active usage of platform content"
		}

		recs = append(recs, domain.SubscriptionRecommendation{
			Subscription:      a.Subscription,
			Action:            action,
			ValueAssessment:   valueAssessment,
			Cost:              cost,
			Benefit:           benefit,
			UserBenefitReason: userBenefitReason,
		})
	}

	return recs
}

// PotentialSavings returns the total potential monthly savings.
func (s *SubscriptionIntelligence) PotentialSavings(ctx context.Context, household *domain.Household) (float64, error) {
	intel, err := s.ForHousehold(ctx, household)
	if err != nil {
		return 0, err
	}
	return intel.PotentialSavings, nil
}
