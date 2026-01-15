package domain

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

// Subscription tracks a household's streaming platform subscription.
// Used for value-based guidance per invariant #9.
type Subscription struct {
	ID            uuid.UUID
	HouseholdID   uuid.UUID
	Platform      string
	MonthlyCost   decimal.Decimal
	Active        bool
	LastWatchedAt time.Time
	CreatedAt     time.Time
	UpdatedAt     time.Time
}

// NewSubscription creates a new subscription record.
func NewSubscription(householdID uuid.UUID, platform string, monthlyCost decimal.Decimal) *Subscription {
	now := time.Now()
	return &Subscription{
		ID:            uuid.New(),
		HouseholdID:   householdID,
		Platform:      platform,
		MonthlyCost:   monthlyCost,
		Active:        true,
		LastWatchedAt: now,
		CreatedAt:     now,
		UpdatedAt:     now,
	}
}

// DaysSinceLastWatch returns the number of days since this subscription was used.
func (s *Subscription) DaysSinceLastWatch() int {
	return int(time.Since(s.LastWatchedAt).Hours() / 24)
}

// Cancel marks the subscription as inactive.
func (s *Subscription) Cancel() {
	s.Active = false
	s.UpdatedAt = time.Now()
}

// Reactivate marks the subscription as active again.
func (s *Subscription) Reactivate() {
	s.Active = true
	s.UpdatedAt = time.Now()
}

// RecordUsage updates the last watched timestamp.
func (s *Subscription) RecordUsage() {
	s.LastWatchedAt = time.Now()
	s.UpdatedAt = time.Now()
}

// PlatformAbbreviation returns first 2 characters uppercase for logo display.
func (s *Subscription) PlatformAbbreviation() string {
	if len(s.Platform) < 2 {
		return s.Platform
	}
	return s.Platform[:2]
}
