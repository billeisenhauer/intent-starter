package postgres

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/domain"
)

// MemberRepository implements repository.MemberRepository using PostgreSQL.
type MemberRepository struct {
	db *DB
}

// NewMemberRepository creates a new PostgreSQL member repository.
func NewMemberRepository(db *DB) *MemberRepository {
	return &MemberRepository{db: db}
}

// FindByID retrieves a member by its ID.
func (r *MemberRepository) FindByID(ctx context.Context, id uuid.UUID) (*domain.Member, error) {
	query := `
		SELECT id, household_id, name, avatar_color, created_at, updated_at
		FROM members
		WHERE id = $1
	`

	var m domain.Member
	err := r.db.Pool.QueryRow(ctx, query, id).Scan(
		&m.ID, &m.HouseholdID, &m.Name, &m.AvatarColor, &m.CreatedAt, &m.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return &m, nil
}

// FindByHousehold retrieves all members of a household.
func (r *MemberRepository) FindByHousehold(ctx context.Context, householdID uuid.UUID) ([]domain.Member, error) {
	query := `
		SELECT id, household_id, name, avatar_color, created_at, updated_at
		FROM members
		WHERE household_id = $1
		ORDER BY created_at ASC
	`

	rows, err := r.db.Pool.Query(ctx, query, householdID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var members []domain.Member
	for rows.Next() {
		var m domain.Member
		if err := rows.Scan(
			&m.ID, &m.HouseholdID, &m.Name, &m.AvatarColor, &m.CreatedAt, &m.UpdatedAt,
		); err != nil {
			return nil, err
		}
		members = append(members, m)
	}

	return members, rows.Err()
}

// Save creates or updates a member.
func (r *MemberRepository) Save(ctx context.Context, m *domain.Member) error {
	query := `
		INSERT INTO members (id, household_id, name, avatar_color, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6)
		ON CONFLICT (id) DO UPDATE SET
			name = EXCLUDED.name,
			avatar_color = EXCLUDED.avatar_color,
			updated_at = NOW()
	`

	_, err := r.db.Pool.Exec(ctx, query,
		m.ID, m.HouseholdID, m.Name, m.AvatarColor, m.CreatedAt, m.UpdatedAt,
	)
	return err
}

// Delete removes a member.
func (r *MemberRepository) Delete(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM members WHERE id = $1`
	_, err := r.db.Pool.Exec(ctx, query, id)
	return err
}
