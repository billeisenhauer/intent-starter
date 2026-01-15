package domain

import (
	"time"

	"github.com/google/uuid"
)

// Member represents a household member.
// First-class entity per invariant #5.
type Member struct {
	ID          uuid.UUID
	HouseholdID uuid.UUID
	Name        string
	AvatarColor string
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

// NewMember creates a new member belonging to the given household.
func NewMember(householdID uuid.UUID, name string, avatarColor string) *Member {
	now := time.Now()
	return &Member{
		ID:          uuid.New(),
		HouseholdID: householdID,
		Name:        name,
		AvatarColor: avatarColor,
		CreatedAt:   now,
		UpdatedAt:   now,
	}
}

// DefaultAvatarColors provides a palette for member avatars.
var DefaultAvatarColors = []string{
	"#5B8A72", // teal
	"#D4A574", // mustard
	"#8B6914", // terracotta
	"#4A6741", // sage
	"#7B5544", // walnut
}
