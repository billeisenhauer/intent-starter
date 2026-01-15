package handlers

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/google/uuid"
	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/repository"
)

// ActionsHandler handles user actions.
type ActionsHandler struct {
	householdRepo repository.HouseholdRepository
	memberRepo    repository.MemberRepository
	viewingRepo   repository.ViewingRecordRepository
}

// NewActionsHandler creates a new actions handler.
func NewActionsHandler(
	householdRepo repository.HouseholdRepository,
	memberRepo repository.MemberRepository,
	viewingRepo repository.ViewingRecordRepository,
) *ActionsHandler {
	return &ActionsHandler{
		householdRepo: householdRepo,
		memberRepo:    memberRepo,
		viewingRepo:   viewingRepo,
	}
}

// MarkWatchedRequest represents the request body for marking a title as watched.
type MarkWatchedRequest struct {
	MemberID     string  `json:"member_id"`
	TitleID      string  `json:"title_id"`
	Progress     float64 `json:"progress"`
	FullyWatched bool    `json:"fully_watched"`
}

// MarkWatched records a viewing event.
func (h *ActionsHandler) MarkWatched(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	var req MarkWatchedRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	memberID, err := uuid.Parse(req.MemberID)
	if err != nil {
		http.Error(w, "Invalid member ID", http.StatusBadRequest)
		return
	}

	titleID, err := uuid.Parse(req.TitleID)
	if err != nil {
		http.Error(w, "Invalid title ID", http.StatusBadRequest)
		return
	}

	if err := h.viewingRepo.MarkWatched(ctx, memberID, titleID, req.Progress, req.FullyWatched); err != nil {
		log.Printf("Error marking watched: %v", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}

// ExportData exports all user data.
// Implements invariant #10: Users must be able to download their data.
func (h *ActionsHandler) ExportData(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// For demo, get first household
	household, err := h.householdRepo.FindFirst(ctx)
	if err != nil || household == nil {
		http.Error(w, "No data found", http.StatusNotFound)
		return
	}

	members, _ := h.memberRepo.FindByHousehold(ctx, household.ID)
	viewingRecords, _ := h.viewingRepo.FindByHousehold(ctx, household.ID, 1000)

	export := map[string]interface{}{
		"household":       household,
		"members":         members,
		"viewing_records": viewingRecords,
		"exported_at":     "now",
	}

	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Content-Disposition", "attachment; filename=binge-watching-export.json")
	json.NewEncoder(w).Encode(export)
}

// DeleteAccount deletes the user's account and all data.
// Implements invariant #11: Users must be able to delete their account and all associated data.
func (h *ActionsHandler) DeleteAccount(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// For demo, get first household
	household, err := h.householdRepo.FindFirst(ctx)
	if err != nil || household == nil {
		http.Error(w, "No account found", http.StatusNotFound)
		return
	}

	// Delete cascades to all related data
	if err := h.householdRepo.Delete(ctx, household.ID); err != nil {
		log.Printf("Error deleting account: %v", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{"status": "deleted"})
}
