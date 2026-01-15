package handlers

import (
	"fmt"
	"html/template"
	"log"
	"net/http"
	"path/filepath"
	"time"

	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/domain"
	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/repository"
	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/service"
)

// DashboardHandler handles the main dashboard page.
type DashboardHandler struct {
	householdRepo     repository.HouseholdRepository
	memberRepo        repository.MemberRepository
	viewingRepo       repository.ViewingRecordRepository
	subscriptionRepo  repository.SubscriptionRepository
	titleRepo         repository.TitleRepository
	recommendationSvc *service.RecommendationEngine
	subscriptionSvc   *service.SubscriptionIntelligence
	templates         *template.Template
}

// NewDashboardHandler creates a new dashboard handler.
func NewDashboardHandler(
	householdRepo repository.HouseholdRepository,
	memberRepo repository.MemberRepository,
	viewingRepo repository.ViewingRecordRepository,
	subscriptionRepo repository.SubscriptionRepository,
	titleRepo repository.TitleRepository,
	recommendationSvc *service.RecommendationEngine,
	subscriptionSvc *service.SubscriptionIntelligence,
) *DashboardHandler {
	// Parse templates
	tmpl := template.New("").Funcs(templateFuncs())
	tmpl = template.Must(tmpl.ParseGlob(filepath.Join("templates", "layouts", "*.html")))
	tmpl = template.Must(tmpl.ParseGlob(filepath.Join("templates", "dashboard", "*.html")))
	tmpl = template.Must(tmpl.ParseGlob(filepath.Join("templates", "dashboard", "partials", "*.html")))
	tmpl = template.Must(tmpl.ParseGlob(filepath.Join("templates", "shared", "*.html")))

	return &DashboardHandler{
		householdRepo:     householdRepo,
		memberRepo:        memberRepo,
		viewingRepo:       viewingRepo,
		subscriptionRepo:  subscriptionRepo,
		titleRepo:         titleRepo,
		recommendationSvc: recommendationSvc,
		subscriptionSvc:   subscriptionSvc,
		templates:         tmpl,
	}
}

// DashboardData holds all data for the dashboard template.
type DashboardData struct {
	Household       *domain.Household
	Members         []domain.Member
	CurrentMember   *domain.Member
	Recommendations []domain.Recommendation
	Subscriptions   []domain.Subscription
	Intelligence    *domain.Intelligence
	RecentHistory   []domain.ViewingRecord
	Stats           DashboardStats
	EmptyState      bool
}

// DashboardStats holds dashboard statistics.
type DashboardStats struct {
	TotalWatched     int
	InProgress       int
	Subscriptions    int
	PotentialSavings float64
}

// Index renders the main dashboard.
func (h *DashboardHandler) Index(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// Get first household (demo mode)
	household, err := h.householdRepo.FindFirst(ctx)
	if err != nil {
		log.Printf("Error finding household: %v", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}

	// Handle empty state
	if household == nil {
		data := DashboardData{EmptyState: true}
		h.render(w, "index.html", data)
		return
	}

	// Get members
	members, err := h.memberRepo.FindByHousehold(ctx, household.ID)
	if err != nil {
		log.Printf("Error finding members: %v", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}
	household.Members = members

	var currentMember *domain.Member
	if len(members) > 0 {
		currentMember = &members[0]
	}

	// Get recommendations
	recommendations, err := h.recommendationSvc.ForHousehold(ctx, household)
	if err != nil {
		log.Printf("Error getting recommendations: %v", err)
		recommendations = []domain.Recommendation{}
	}

	// Get subscriptions
	subscriptions, err := h.subscriptionRepo.FindActiveByHousehold(ctx, household.ID)
	if err != nil {
		log.Printf("Error finding subscriptions: %v", err)
		subscriptions = []domain.Subscription{}
	}

	// Get subscription intelligence
	intelligence, err := h.subscriptionSvc.ForHousehold(ctx, household)
	if err != nil {
		log.Printf("Error getting intelligence: %v", err)
		intelligence = &domain.Intelligence{}
	}

	// Get recent history
	recentHistory, err := h.viewingRepo.FindRecentByHousehold(ctx, household.ID, 5)
	if err != nil {
		log.Printf("Error finding history: %v", err)
		recentHistory = []domain.ViewingRecord{}
	}

	// Calculate stats
	fullyWatched, _ := h.titleRepo.FindWatchedByHousehold(ctx, household.ID, true)
	inProgress, _ := h.titleRepo.FindWatchedByHousehold(ctx, household.ID, false)

	stats := DashboardStats{
		TotalWatched:     len(fullyWatched),
		InProgress:       len(inProgress),
		Subscriptions:    len(subscriptions),
		PotentialSavings: intelligence.PotentialSavings,
	}

	data := DashboardData{
		Household:       household,
		Members:         members,
		CurrentMember:   currentMember,
		Recommendations: recommendations,
		Subscriptions:   subscriptions,
		Intelligence:    intelligence,
		RecentHistory:   recentHistory,
		Stats:           stats,
		EmptyState:      false,
	}

	h.render(w, "index.html", data)
}

func (h *DashboardHandler) render(w http.ResponseWriter, name string, data interface{}) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := h.templates.ExecuteTemplate(w, name, data); err != nil {
		log.Printf("Template error: %v", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
	}
}

// templateFuncs returns custom template functions.
func templateFuncs() template.FuncMap {
	return template.FuncMap{
		"timeAgo": func(t time.Time) string {
			duration := time.Since(t)
			switch {
			case duration < time.Minute:
				return "just now"
			case duration < time.Hour:
				mins := int(duration.Minutes())
				if mins == 1 {
					return "1 minute"
				}
				return fmt.Sprintf("%d minutes", mins)
			case duration < 24*time.Hour:
				hours := int(duration.Hours())
				if hours == 1 {
					return "1 hour"
				}
				return fmt.Sprintf("%d hours", hours)
			default:
				days := int(duration.Hours() / 24)
				if days == 1 {
					return "1 day"
				}
				return fmt.Sprintf("%d days", days)
			}
		},
		"formatCurrency": func(amount float64) string {
			return fmt.Sprintf("$%.2f", amount)
		},
		"formatPercent": func(value float64) string {
			return fmt.Sprintf("%.0f%%", value*100)
		},
		"mul": func(a, b float64) float64 {
			return a * b
		},
		"slice": func(s string, start, end int) string {
			if start >= len(s) {
				return ""
			}
			if end > len(s) {
				end = len(s)
			}
			return s[start:end]
		},
	}
}
