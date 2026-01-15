package postgres

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/domain"
)

// TitleRepository implements repository.TitleRepository using PostgreSQL.
type TitleRepository struct {
	db *DB
}

// NewTitleRepository creates a new PostgreSQL title repository.
func NewTitleRepository(db *DB) *TitleRepository {
	return &TitleRepository{db: db}
}

// FindByID retrieves a title by its ID.
func (r *TitleRepository) FindByID(ctx context.Context, id uuid.UUID) (*domain.Title, error) {
	query := `
		SELECT id, external_id, name, title_type, created_at, updated_at
		FROM titles
		WHERE id = $1
	`

	var t domain.Title
	err := r.db.Pool.QueryRow(ctx, query, id).Scan(
		&t.ID, &t.ExternalID, &t.Name, &t.TitleType, &t.CreatedAt, &t.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return &t, nil
}

// FindByExternalID retrieves a title by its external identifier.
func (r *TitleRepository) FindByExternalID(ctx context.Context, externalID string) (*domain.Title, error) {
	query := `
		SELECT id, external_id, name, title_type, created_at, updated_at
		FROM titles
		WHERE external_id = $1
	`

	var t domain.Title
	err := r.db.Pool.QueryRow(ctx, query, externalID).Scan(
		&t.ID, &t.ExternalID, &t.Name, &t.TitleType, &t.CreatedAt, &t.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return &t, nil
}

// FindAll retrieves all titles up to a limit.
func (r *TitleRepository) FindAll(ctx context.Context, limit int) ([]domain.Title, error) {
	query := `
		SELECT id, external_id, name, title_type, created_at, updated_at
		FROM titles
		ORDER BY name ASC
		LIMIT $1
	`

	rows, err := r.db.Pool.Query(ctx, query, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var titles []domain.Title
	for rows.Next() {
		var t domain.Title
		if err := rows.Scan(
			&t.ID, &t.ExternalID, &t.Name, &t.TitleType, &t.CreatedAt, &t.UpdatedAt,
		); err != nil {
			return nil, err
		}
		titles = append(titles, t)
	}

	return titles, rows.Err()
}

// FindUnwatchedByHousehold returns titles not fully watched by anyone in the household.
// Implements invariant #4: System must not re-recommend fully watched titles.
func (r *TitleRepository) FindUnwatchedByHousehold(ctx context.Context, householdID uuid.UUID) ([]domain.Title, error) {
	query := `
		SELECT t.id, t.external_id, t.name, t.title_type, t.created_at, t.updated_at
		FROM titles t
		WHERE t.id NOT IN (
			SELECT DISTINCT vr.title_id
			FROM viewing_records vr
			JOIN members m ON vr.member_id = m.id
			WHERE m.household_id = $1 AND vr.fully_watched = true
		)
		ORDER BY t.name ASC
	`

	rows, err := r.db.Pool.Query(ctx, query, householdID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var titles []domain.Title
	for rows.Next() {
		var t domain.Title
		if err := rows.Scan(
			&t.ID, &t.ExternalID, &t.Name, &t.TitleType, &t.CreatedAt, &t.UpdatedAt,
		); err != nil {
			return nil, err
		}
		titles = append(titles, t)
	}

	return titles, rows.Err()
}

// FindWatchedByHousehold returns titles watched by any household member.
func (r *TitleRepository) FindWatchedByHousehold(ctx context.Context, householdID uuid.UUID, fullyWatched bool) ([]domain.Title, error) {
	query := `
		SELECT DISTINCT t.id, t.external_id, t.name, t.title_type, t.created_at, t.updated_at
		FROM titles t
		JOIN viewing_records vr ON t.id = vr.title_id
		JOIN members m ON vr.member_id = m.id
		WHERE m.household_id = $1 AND vr.fully_watched = $2
		ORDER BY t.name ASC
	`

	rows, err := r.db.Pool.Query(ctx, query, householdID, fullyWatched)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var titles []domain.Title
	for rows.Next() {
		var t domain.Title
		if err := rows.Scan(
			&t.ID, &t.ExternalID, &t.Name, &t.TitleType, &t.CreatedAt, &t.UpdatedAt,
		); err != nil {
			return nil, err
		}
		titles = append(titles, t)
	}

	return titles, rows.Err()
}

// Save creates or updates a title.
func (r *TitleRepository) Save(ctx context.Context, t *domain.Title) error {
	query := `
		INSERT INTO titles (id, external_id, name, title_type, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6)
		ON CONFLICT (id) DO UPDATE SET
			name = EXCLUDED.name,
			title_type = EXCLUDED.title_type,
			updated_at = NOW()
	`

	_, err := r.db.Pool.Exec(ctx, query,
		t.ID, t.ExternalID, t.Name, t.TitleType, t.CreatedAt, t.UpdatedAt,
	)
	return err
}
