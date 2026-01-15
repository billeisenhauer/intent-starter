package repository

import (
	"context"

	"github.com/google/uuid"
	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/domain"
)

// HouseholdRepository provides access to household data.
type HouseholdRepository interface {
	FindByID(ctx context.Context, id uuid.UUID) (*domain.Household, error)
	FindFirst(ctx context.Context) (*domain.Household, error)
	Save(ctx context.Context, h *domain.Household) error
	Delete(ctx context.Context, id uuid.UUID) error // Per invariant #11
}

// MemberRepository provides access to member data.
type MemberRepository interface {
	FindByID(ctx context.Context, id uuid.UUID) (*domain.Member, error)
	FindByHousehold(ctx context.Context, householdID uuid.UUID) ([]domain.Member, error)
	Save(ctx context.Context, m *domain.Member) error
	Delete(ctx context.Context, id uuid.UUID) error
}

// TitleRepository provides access to title data.
type TitleRepository interface {
	FindByID(ctx context.Context, id uuid.UUID) (*domain.Title, error)
	FindByExternalID(ctx context.Context, externalID string) (*domain.Title, error)
	FindAll(ctx context.Context, limit int) ([]domain.Title, error)
	FindUnwatchedByHousehold(ctx context.Context, householdID uuid.UUID) ([]domain.Title, error)
	FindWatchedByHousehold(ctx context.Context, householdID uuid.UUID, fullyWatched bool) ([]domain.Title, error)
	Save(ctx context.Context, t *domain.Title) error
}

// ViewingRecordRepository provides access to viewing record data.
type ViewingRecordRepository interface {
	FindByMemberAndTitle(ctx context.Context, memberID, titleID uuid.UUID) (*domain.ViewingRecord, error)
	FindByHousehold(ctx context.Context, householdID uuid.UUID, limit int) ([]domain.ViewingRecord, error)
	FindRecentByHousehold(ctx context.Context, householdID uuid.UUID, limit int) ([]domain.ViewingRecord, error)
	CountByHouseholdAndPlatform(ctx context.Context, householdID uuid.UUID, platform string) (int, error)
	Save(ctx context.Context, v *domain.ViewingRecord) error
	MarkWatched(ctx context.Context, memberID, titleID uuid.UUID, progress float64, fullyWatched bool) error
}

// SubscriptionRepository provides access to subscription data.
type SubscriptionRepository interface {
	FindByID(ctx context.Context, id uuid.UUID) (*domain.Subscription, error)
	FindByHousehold(ctx context.Context, householdID uuid.UUID) ([]domain.Subscription, error)
	FindActiveByHousehold(ctx context.Context, householdID uuid.UUID) ([]domain.Subscription, error)
	Save(ctx context.Context, s *domain.Subscription) error
	Delete(ctx context.Context, id uuid.UUID) error
}

// AvailabilityRepository provides access to availability observation data.
type AvailabilityRepository interface {
	FindByTitle(ctx context.Context, titleID uuid.UUID) ([]domain.AvailabilityObservation, error)
	FindByTitleAndPlatform(ctx context.Context, titleID uuid.UUID, platform string) ([]domain.AvailabilityObservation, error)
	Save(ctx context.Context, a *domain.AvailabilityObservation) error
}
