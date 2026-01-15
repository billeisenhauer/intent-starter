package postgres

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/domain"
)

// HouseholdRepository implements repository.HouseholdRepository using PostgreSQL.
type HouseholdRepository struct {
	db *DB
}

// NewHouseholdRepository creates a new PostgreSQL household repository.
func NewHouseholdRepository(db *DB) *HouseholdRepository {
	return &HouseholdRepository{db: db}
}

// FindByID retrieves a household by its ID.
func (r *HouseholdRepository) FindByID(ctx context.Context, id uuid.UUID) (*domain.Household, error) {
	query := `
		SELECT id, name, created_at, updated_at
		FROM households
		WHERE id = $1
	`

	var h domain.Household
	err := r.db.Pool.QueryRow(ctx, query, id).Scan(
		&h.ID, &h.Name, &h.CreatedAt, &h.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return &h, nil
}

// FindFirst retrieves the first household (for demo purposes).
func (r *HouseholdRepository) FindFirst(ctx context.Context) (*domain.Household, error) {
	query := `
		SELECT id, name, created_at, updated_at
		FROM households
		ORDER BY created_at ASC
		LIMIT 1
	`

	var h domain.Household
	err := r.db.Pool.QueryRow(ctx, query).Scan(
		&h.ID, &h.Name, &h.CreatedAt, &h.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return &h, nil
}

// Save creates or updates a household.
func (r *HouseholdRepository) Save(ctx context.Context, h *domain.Household) error {
	query := `
		INSERT INTO households (id, name, created_at, updated_at)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (id) DO UPDATE SET
			name = EXCLUDED.name,
			updated_at = NOW()
	`

	_, err := r.db.Pool.Exec(ctx, query,
		h.ID, h.Name, h.CreatedAt, h.UpdatedAt,
	)
	return err
}

// Delete removes a household and all associated data.
// Implements invariant #11: Users must be able to delete their account and all associated data.
func (r *HouseholdRepository) Delete(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM households WHERE id = $1`
	_, err := r.db.Pool.Exec(ctx, query, id)
	return err
}
