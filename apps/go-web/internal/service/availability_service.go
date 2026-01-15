package service

import (
	"context"

	"github.com/google/uuid"
	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/domain"
	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/repository"
)

// AvailabilityService manages availability data.
// Implements invariant #6: Availability data must be probabilistic and crowd-sourced.
// Implements invariant #7: Never scraped from behind auth walls.
type AvailabilityService struct {
	availabilityRepo repository.AvailabilityRepository
}

// NewAvailabilityService creates a new availability service.
func NewAvailabilityService(availabilityRepo repository.AvailabilityRepository) *AvailabilityService {
	return &AvailabilityService{
		availabilityRepo: availabilityRepo,
	}
}

// ForTitle returns availability information for a title across platforms.
func (s *AvailabilityService) ForTitle(ctx context.Context, titleID uuid.UUID) ([]domain.Availability, error) {
	observations, err := s.availabilityRepo.FindByTitle(ctx, titleID)
	if err != nil {
		return nil, err
	}

	// Group observations by platform
	platformObs := make(map[string][]domain.AvailabilityObservation)
	for _, obs := range observations {
		platformObs[obs.Platform] = append(platformObs[obs.Platform], obs)
	}

	// Calculate availability per platform
	var availabilities []domain.Availability
	for platform, obs := range platformObs {
		confidence := domain.CalculateAvailabilityConfidence(obs)

		// Determine if available based on most recent observations
		available := false
		if len(obs) > 0 && obs[0].Available {
			available = true
		}

		availabilities = append(availabilities, domain.Availability{
			Platform:   platform,
			Confidence: confidence,
			Available:  available,
		})
	}

	return availabilities, nil
}

// ReportAvailability records a user's observation about title availability.
// This is crowd-sourced per invariant #6 - never scraped.
func (s *AvailabilityService) ReportAvailability(
	ctx context.Context,
	titleID uuid.UUID,
	platform string,
	available bool,
	reporterID uuid.UUID,
) error {
	observation := domain.NewAvailabilityObservation(titleID, platform, available, reporterID)
	return s.availabilityRepo.Save(ctx, observation)
}

// GetConfidence returns the confidence level for availability on a specific platform.
func (s *AvailabilityService) GetConfidence(ctx context.Context, titleID uuid.UUID, platform string) (domain.Confidence, error) {
	observations, err := s.availabilityRepo.FindByTitleAndPlatform(ctx, titleID, platform)
	if err != nil {
		return domain.Confidence{}, err
	}

	return domain.CalculateAvailabilityConfidence(observations), nil
}
