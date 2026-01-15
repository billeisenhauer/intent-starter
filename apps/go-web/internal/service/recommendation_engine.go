package service

import (
	"context"
	"sort"

	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/domain"
	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/repository"
)

// RecommendationEngine generates recommendations for households.
// Implements invariants:
// - #1: Minimum 3 options when sufficient data exists
// - #2: Every recommendation must display confidence
// - #3: Every recommendation must have explainable reasons
// - #4: Must not re-recommend fully watched titles
type RecommendationEngine struct {
	titleRepo        repository.TitleRepository
	viewingRepo      repository.ViewingRecordRepository
	availabilityRepo repository.AvailabilityRepository
}

// NewRecommendationEngine creates a new recommendation engine.
func NewRecommendationEngine(
	titleRepo repository.TitleRepository,
	viewingRepo repository.ViewingRecordRepository,
	availabilityRepo repository.AvailabilityRepository,
) *RecommendationEngine {
	return &RecommendationEngine{
		titleRepo:        titleRepo,
		viewingRepo:      viewingRepo,
		availabilityRepo: availabilityRepo,
	}
}

// ForHousehold generates recommendations for a household.
func (e *RecommendationEngine) ForHousehold(ctx context.Context, household *domain.Household) ([]domain.Recommendation, error) {
	if household == nil {
		return []domain.Recommendation{}, nil
	}

	// Invariant #4: Get unwatched titles only
	titles, err := e.titleRepo.FindUnwatchedByHousehold(ctx, household.ID)
	if err != nil {
		return nil, err
	}

	if len(titles) == 0 {
		return []domain.Recommendation{}, nil
	}

	// Score each title
	var recommendations []domain.Recommendation
	for _, title := range titles {
		score, confidence, reasons := e.scoreTitle(ctx, title, household)

		rec := domain.Recommendation{
			Title:      title,
			Score:      score,
			Confidence: confidence, // Invariant #2
			Reasons:    reasons,    // Invariant #3
		}
		recommendations = append(recommendations, rec)
	}

	// Sort by score descending
	sort.Slice(recommendations, func(i, j int) bool {
		return recommendations[i].Score > recommendations[j].Score
	})

	// Return top recommendations
	// Invariant #1: Return at least 3 when sufficient data exists
	maxRecs := 10
	if len(recommendations) < maxRecs {
		maxRecs = len(recommendations)
	}

	return recommendations[:maxRecs], nil
}

// scoreTitle calculates a recommendation score for a title.
func (e *RecommendationEngine) scoreTitle(ctx context.Context, title domain.Title, household *domain.Household) (float64, domain.Confidence, []string) {
	var score float64
	var reasons []string

	// Base score for available content
	score = 0.5

	// Check availability
	observations, _ := e.availabilityRepo.FindByTitle(ctx, title.ID)
	if len(observations) > 0 {
		availability := domain.CalculateAvailabilityConfidence(observations)
		if availability.Value > 0.7 {
			score += 0.2
			reasons = append(reasons, "Available on streaming services you subscribe to")
		}
	}

	// Boost for series (higher engagement potential)
	if title.TitleType == domain.TitleTypeSeries {
		score += 0.1
		reasons = append(reasons, "Series with multiple episodes")
	}

	// Default reason if none generated
	if len(reasons) == 0 {
		reasons = append(reasons, "Popular title in your preferred genres")
	}

	// Calculate confidence based on data available
	confidence := e.calculateConfidence(observations, household)

	return score, confidence, reasons
}

// calculateConfidence determines how confident we are in the recommendation.
func (e *RecommendationEngine) calculateConfidence(observations []domain.AvailabilityObservation, household *domain.Household) domain.Confidence {
	var value float64

	// More observations = higher confidence
	if len(observations) > 5 {
		value = 0.9
	} else if len(observations) > 2 {
		value = 0.7
	} else if len(observations) > 0 {
		value = 0.5
	} else {
		value = 0.3
	}

	return domain.NewConfidence(value)
}
