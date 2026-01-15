package postgres

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/domain"
)

// SubscriptionRepository implements repository.SubscriptionRepository using PostgreSQL.
type SubscriptionRepository struct {
	db *DB
}

// NewSubscriptionRepository creates a new PostgreSQL subscription repository.
func NewSubscriptionRepository(db *DB) *SubscriptionRepository {
	return &SubscriptionRepository{db: db}
}

// FindByID retrieves a subscription by its ID.
func (r *SubscriptionRepository) FindByID(ctx context.Context, id uuid.UUID) (*domain.Subscription, error) {
	query := `
		SELECT id, household_id, platform, monthly_cost, active, last_watched_at, created_at, updated_at
		FROM subscriptions
		WHERE id = $1
	`

	var s domain.Subscription
	err := r.db.Pool.QueryRow(ctx, query, id).Scan(
		&s.ID, &s.HouseholdID, &s.Platform, &s.MonthlyCost, &s.Active, &s.LastWatchedAt, &s.CreatedAt, &s.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return &s, nil
}

// FindByHousehold retrieves all subscriptions for a household.
func (r *SubscriptionRepository) FindByHousehold(ctx context.Context, householdID uuid.UUID) ([]domain.Subscription, error) {
	query := `
		SELECT id, household_id, platform, monthly_cost, active, last_watched_at, created_at, updated_at
		FROM subscriptions
		WHERE household_id = $1
		ORDER BY platform ASC
	`

	rows, err := r.db.Pool.Query(ctx, query, householdID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var subscriptions []domain.Subscription
	for rows.Next() {
		var s domain.Subscription
		if err := rows.Scan(
			&s.ID, &s.HouseholdID, &s.Platform, &s.MonthlyCost, &s.Active, &s.LastWatchedAt, &s.CreatedAt, &s.UpdatedAt,
		); err != nil {
			return nil, err
		}
		subscriptions = append(subscriptions, s)
	}

	return subscriptions, rows.Err()
}

// FindActiveByHousehold retrieves active subscriptions for a household.
func (r *SubscriptionRepository) FindActiveByHousehold(ctx context.Context, householdID uuid.UUID) ([]domain.Subscription, error) {
	query := `
		SELECT id, household_id, platform, monthly_cost, active, last_watched_at, created_at, updated_at
		FROM subscriptions
		WHERE household_id = $1 AND active = true
		ORDER BY platform ASC
	`

	rows, err := r.db.Pool.Query(ctx, query, householdID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var subscriptions []domain.Subscription
	for rows.Next() {
		var s domain.Subscription
		if err := rows.Scan(
			&s.ID, &s.HouseholdID, &s.Platform, &s.MonthlyCost, &s.Active, &s.LastWatchedAt, &s.CreatedAt, &s.UpdatedAt,
		); err != nil {
			return nil, err
		}
		subscriptions = append(subscriptions, s)
	}

	return subscriptions, rows.Err()
}

// Save creates or updates a subscription.
func (r *SubscriptionRepository) Save(ctx context.Context, s *domain.Subscription) error {
	query := `
		INSERT INTO subscriptions (id, household_id, platform, monthly_cost, active, last_watched_at, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		ON CONFLICT (household_id, platform) DO UPDATE SET
			monthly_cost = EXCLUDED.monthly_cost,
			active = EXCLUDED.active,
			last_watched_at = EXCLUDED.last_watched_at,
			updated_at = NOW()
	`

	_, err := r.db.Pool.Exec(ctx, query,
		s.ID, s.HouseholdID, s.Platform, s.MonthlyCost, s.Active, s.LastWatchedAt, s.CreatedAt, s.UpdatedAt,
	)
	return err
}

// Delete removes a subscription.
func (r *SubscriptionRepository) Delete(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM subscriptions WHERE id = $1`
	_, err := r.db.Pool.Exec(ctx, query, id)
	return err
}
