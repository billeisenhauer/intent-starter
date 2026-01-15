package domain

import (
	"time"

	"github.com/google/uuid"
)

// ViewingRecord tracks what a member has watched.
// Per-member tracking supports invariant #5.
type ViewingRecord struct {
	ID           uuid.UUID
	MemberID     uuid.UUID
	TitleID      uuid.UUID
	FullyWatched bool
	Progress     float64 // 0.0 to 1.0
	CreatedAt    time.Time
	UpdatedAt    time.Time

	// Populated by joins
	Title  *Title
	Member *Member
}

// NewViewingRecord creates a new viewing record.
func NewViewingRecord(memberID, titleID uuid.UUID, progress float64, fullyWatched bool) *ViewingRecord {
	now := time.Now()
	return &ViewingRecord{
		ID:           uuid.New(),
		MemberID:     memberID,
		TitleID:      titleID,
		FullyWatched: fullyWatched,
		Progress:     progress,
		CreatedAt:    now,
		UpdatedAt:    now,
	}
}

// MarkFullyWatched updates the record to indicate completion.
func (v *ViewingRecord) MarkFullyWatched() {
	v.FullyWatched = true
	v.Progress = 1.0
	v.UpdatedAt = time.Now()
}

// UpdateProgress sets the viewing progress.
func (v *ViewingRecord) UpdateProgress(progress float64) {
	if progress < 0 {
		progress = 0
	}
	if progress > 1 {
		progress = 1
	}
	v.Progress = progress
	v.UpdatedAt = time.Now()

	if progress >= 1.0 {
		v.FullyWatched = true
	}
}

// ProgressPercent returns progress as a percentage (0-100).
func (v *ViewingRecord) ProgressPercent() int {
	return int(v.Progress * 100)
}

// IsInProgress returns true if watching has started but not completed.
func (v *ViewingRecord) IsInProgress() bool {
	return v.Progress > 0 && !v.FullyWatched
}
