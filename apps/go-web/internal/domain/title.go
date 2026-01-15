package domain

import (
	"time"

	"github.com/google/uuid"
)

// TitleType distinguishes movies from series.
type TitleType string

const (
	TitleTypeMovie  TitleType = "movie"
	TitleTypeSeries TitleType = "series"
)

// Title represents a movie or series that can be watched.
type Title struct {
	ID         uuid.UUID
	ExternalID string    // External identifier from content source
	Name       string
	TitleType  TitleType
	CreatedAt  time.Time
	UpdatedAt  time.Time
}

// NewTitle creates a new title record.
func NewTitle(externalID, name string, titleType TitleType) *Title {
	now := time.Now()
	return &Title{
		ID:         uuid.New(),
		ExternalID: externalID,
		Name:       name,
		TitleType:  titleType,
		CreatedAt:  now,
		UpdatedAt:  now,
	}
}

// IsMovie returns true if this title is a movie.
func (t *Title) IsMovie() bool {
	return t.TitleType == TitleTypeMovie
}

// IsSeries returns true if this title is a series.
func (t *Title) IsSeries() bool {
	return t.TitleType == TitleTypeSeries
}
