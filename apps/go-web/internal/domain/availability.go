package domain

import (
	"math"
	"time"

	"github.com/google/uuid"
)

// AvailabilityObservation is a crowd-sourced report of title availability.
// Implements invariant #6: availability must be probabilistic and crowd-sourced.
type AvailabilityObservation struct {
	ID         uuid.UUID
	TitleID    uuid.UUID
	Platform   string
	Available  bool
	ReportedAt time.Time
	ReporterID uuid.UUID // Member who reported this
	CreatedAt  time.Time
}

// NewAvailabilityObservation creates a new observation.
func NewAvailabilityObservation(titleID uuid.UUID, platform string, available bool, reporterID uuid.UUID) *AvailabilityObservation {
	now := time.Now()
	return &AvailabilityObservation{
		ID:         uuid.New(),
		TitleID:    titleID,
		Platform:   platform,
		Available:  available,
		ReportedAt: now,
		ReporterID: reporterID,
		CreatedAt:  now,
	}
}

// Availability represents aggregated availability for a title on a platform.
type Availability struct {
	Platform   string
	Confidence Confidence
	Available  bool
}

// CalculateAvailabilityConfidence computes time-decay confidence from observations.
// More recent observations have higher weight.
func CalculateAvailabilityConfidence(observations []AvailabilityObservation) Confidence {
	if len(observations) == 0 {
		return Confidence{Value: 0, Label: "Unknown"}
	}

	var totalWeight float64
	var positiveWeight float64
	now := time.Now()

	for _, obs := range observations {
		// Time decay: half-life of 30 days
		daysSince := now.Sub(obs.ReportedAt).Hours() / 24
		weight := math.Exp(-daysSince / 30)

		totalWeight += weight
		if obs.Available {
			positiveWeight += weight
		}
	}

	if totalWeight == 0 {
		return Confidence{Value: 0, Label: "Unknown"}
	}

	value := positiveWeight / totalWeight
	return NewConfidence(value)
}
