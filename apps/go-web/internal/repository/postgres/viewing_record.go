package postgres

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/domain"
)

// ViewingRecordRepository implements repository.ViewingRecordRepository using PostgreSQL.
type ViewingRecordRepository struct {
	db *DB
}

// NewViewingRecordRepository creates a new PostgreSQL viewing record repository.
func NewViewingRecordRepository(db *DB) *ViewingRecordRepository {
	return &ViewingRecordRepository{db: db}
}

// FindByMemberAndTitle retrieves a viewing record for a specific member and title.
func (r *ViewingRecordRepository) FindByMemberAndTitle(ctx context.Context, memberID, titleID uuid.UUID) (*domain.ViewingRecord, error) {
	query := `
		SELECT id, member_id, title_id, fully_watched, progress, created_at, updated_at
		FROM viewing_records
		WHERE member_id = $1 AND title_id = $2
	`

	var vr domain.ViewingRecord
	err := r.db.Pool.QueryRow(ctx, query, memberID, titleID).Scan(
		&vr.ID, &vr.MemberID, &vr.TitleID, &vr.FullyWatched, &vr.Progress, &vr.CreatedAt, &vr.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return &vr, nil
}

// FindByHousehold retrieves viewing records for all household members.
func (r *ViewingRecordRepository) FindByHousehold(ctx context.Context, householdID uuid.UUID, limit int) ([]domain.ViewingRecord, error) {
	query := `
		SELECT vr.id, vr.member_id, vr.title_id, vr.fully_watched, vr.progress, vr.created_at, vr.updated_at,
			   t.id, t.external_id, t.name, t.title_type, t.created_at, t.updated_at,
			   m.id, m.household_id, m.name, m.avatar_color, m.created_at, m.updated_at
		FROM viewing_records vr
		JOIN members m ON vr.member_id = m.id
		JOIN titles t ON vr.title_id = t.id
		WHERE m.household_id = $1
		ORDER BY vr.updated_at DESC
		LIMIT $2
	`

	rows, err := r.db.Pool.Query(ctx, query, householdID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var records []domain.ViewingRecord
	for rows.Next() {
		var vr domain.ViewingRecord
		var t domain.Title
		var m domain.Member

		if err := rows.Scan(
			&vr.ID, &vr.MemberID, &vr.TitleID, &vr.FullyWatched, &vr.Progress, &vr.CreatedAt, &vr.UpdatedAt,
			&t.ID, &t.ExternalID, &t.Name, &t.TitleType, &t.CreatedAt, &t.UpdatedAt,
			&m.ID, &m.HouseholdID, &m.Name, &m.AvatarColor, &m.CreatedAt, &m.UpdatedAt,
		); err != nil {
			return nil, err
		}

		vr.Title = &t
		vr.Member = &m
		records = append(records, vr)
	}

	return records, rows.Err()
}

// FindRecentByHousehold retrieves the most recent viewing records.
func (r *ViewingRecordRepository) FindRecentByHousehold(ctx context.Context, householdID uuid.UUID, limit int) ([]domain.ViewingRecord, error) {
	return r.FindByHousehold(ctx, householdID, limit)
}

// CountByHouseholdAndPlatform counts views on a specific platform.
func (r *ViewingRecordRepository) CountByHouseholdAndPlatform(ctx context.Context, householdID uuid.UUID, platform string) (int, error) {
	query := `
		SELECT COUNT(DISTINCT vr.id)
		FROM viewing_records vr
		JOIN members m ON vr.member_id = m.id
		JOIN availability_observations ao ON vr.title_id = ao.title_id
		WHERE m.household_id = $1 AND ao.platform = $2
	`

	var count int
	err := r.db.Pool.QueryRow(ctx, query, householdID, platform).Scan(&count)
	return count, err
}

// Save creates or updates a viewing record.
func (r *ViewingRecordRepository) Save(ctx context.Context, vr *domain.ViewingRecord) error {
	query := `
		INSERT INTO viewing_records (id, member_id, title_id, fully_watched, progress, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		ON CONFLICT (member_id, title_id) DO UPDATE SET
			fully_watched = EXCLUDED.fully_watched,
			progress = EXCLUDED.progress,
			updated_at = NOW()
	`

	_, err := r.db.Pool.Exec(ctx, query,
		vr.ID, vr.MemberID, vr.TitleID, vr.FullyWatched, vr.Progress, vr.CreatedAt, vr.UpdatedAt,
	)
	return err
}

// MarkWatched creates or updates a viewing record with the given progress.
func (r *ViewingRecordRepository) MarkWatched(ctx context.Context, memberID, titleID uuid.UUID, progress float64, fullyWatched bool) error {
	now := time.Now()
	vr := &domain.ViewingRecord{
		ID:           uuid.New(),
		MemberID:     memberID,
		TitleID:      titleID,
		FullyWatched: fullyWatched,
		Progress:     progress,
		CreatedAt:    now,
		UpdatedAt:    now,
	}
	return r.Save(ctx, vr)
}
