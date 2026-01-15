package domain

import (
	"errors"
	"time"

	"github.com/google/uuid"
)

// Household is the primary unit per invariant #5:
// "Household members must be first-class entities"
type Household struct {
	ID        uuid.UUID
	Name      string
	CreatedAt time.Time
	UpdatedAt time.Time
	Members   []Member
}

// MembershipError is returned when household membership constraints are violated.
var ErrMembershipConstraint = errors.New("household must have at least one member")

// NewHousehold creates a new household with the given name.
func NewHousehold(name string) *Household {
	now := time.Now()
	return &Household{
		ID:        uuid.New(),
		Name:      name,
		CreatedAt: now,
		UpdatedAt: now,
		Members:   []Member{},
	}
}

// AddMember creates and adds a new member to the household.
func (h *Household) AddMember(name string, avatarColor string) *Member {
	member := NewMember(h.ID, name, avatarColor)
	h.Members = append(h.Members, *member)
	return member
}

// RemoveMember removes a member from the household.
// Returns ErrMembershipConstraint if this would leave the household with no members.
func (h *Household) RemoveMember(memberID uuid.UUID) error {
	if len(h.Members) <= 1 {
		return ErrMembershipConstraint
	}

	newMembers := make([]Member, 0, len(h.Members)-1)
	for _, m := range h.Members {
		if m.ID != memberID {
			newMembers = append(newMembers, m)
		}
	}
	h.Members = newMembers
	return nil
}

// MemberIDs returns a slice of all member IDs in this household.
func (h *Household) MemberIDs() []uuid.UUID {
	ids := make([]uuid.UUID, len(h.Members))
	for i, m := range h.Members {
		ids[i] = m.ID
	}
	return ids
}
