package postgres

import (
	"context"

	"github.com/google/uuid"
	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/domain"
)

// AvailabilityRepository implements repository.AvailabilityRepository using PostgreSQL.
type AvailabilityRepository struct {
	db *DB
}

// NewAvailabilityRepository creates a new PostgreSQL availability repository.
func NewAvailabilityRepository(db *DB) *AvailabilityRepository {
	return &AvailabilityRepository{db: db}
}

// FindByTitle retrieves all availability observations for a title.
func (r *AvailabilityRepository) FindByTitle(ctx context.Context, titleID uuid.UUID) ([]domain.AvailabilityObservation, error) {
	query := `
		SELECT id, title_id, platform, available, reported_at, reporter_id, created_at
		FROM availability_observations
		WHERE title_id = $1
		ORDER BY reported_at DESC
	`

	rows, err := r.db.Pool.Query(ctx, query, titleID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var observations []domain.AvailabilityObservation
	for rows.Next() {
		var ao domain.AvailabilityObservation
		if err := rows.Scan(
			&ao.ID, &ao.TitleID, &ao.Platform, &ao.Available, &ao.ReportedAt, &ao.ReporterID, &ao.CreatedAt,
		); err != nil {
			return nil, err
		}
		observations = append(observations, ao)
	}

	return observations, rows.Err()
}

// FindByTitleAndPlatform retrieves availability observations for a title on a specific platform.
func (r *AvailabilityRepository) FindByTitleAndPlatform(ctx context.Context, titleID uuid.UUID, platform string) ([]domain.AvailabilityObservation, error) {
	query := `
		SELECT id, title_id, platform, available, reported_at, reporter_id, created_at
		FROM availability_observations
		WHERE title_id = $1 AND platform = $2
		ORDER BY reported_at DESC
	`

	rows, err := r.db.Pool.Query(ctx, query, titleID, platform)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var observations []domain.AvailabilityObservation
	for rows.Next() {
		var ao domain.AvailabilityObservation
		if err := rows.Scan(
			&ao.ID, &ao.TitleID, &ao.Platform, &ao.Available, &ao.ReportedAt, &ao.ReporterID, &ao.CreatedAt,
		); err != nil {
			return nil, err
		}
		observations = append(observations, ao)
	}

	return observations, rows.Err()
}

// Save creates a new availability observation.
// Observations are immutable - no updates.
func (r *AvailabilityRepository) Save(ctx context.Context, ao *domain.AvailabilityObservation) error {
	query := `
		INSERT INTO availability_observations (id, title_id, platform, available, reported_at, reporter_id, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`

	_, err := r.db.Pool.Exec(ctx, query,
		ao.ID, ao.TitleID, ao.Platform, ao.Available, ao.ReportedAt, ao.ReporterID, ao.CreatedAt,
	)
	return err
}
