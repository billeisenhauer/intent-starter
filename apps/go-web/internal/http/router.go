package http

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/http/handlers"
)

// Dependencies holds all handler dependencies.
type Dependencies struct {
	DashboardHandler *handlers.DashboardHandler
	ActionsHandler   *handlers.ActionsHandler
}

// NewRouter creates a new Chi router with all routes configured.
func NewRouter(deps Dependencies) chi.Router {
	r := chi.NewRouter()

	// Middleware
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(middleware.RealIP)
	r.Use(middleware.RequestID)

	// Static files
	fileServer := http.FileServer(http.Dir("static"))
	r.Handle("/static/*", http.StripPrefix("/static/", fileServer))

	// Routes
	r.Get("/", deps.DashboardHandler.Index)

	// Actions
	r.Post("/watched", deps.ActionsHandler.MarkWatched)

	// Data export (invariant #10)
	r.Get("/data/export", deps.ActionsHandler.ExportData)

	// Account deletion (invariant #11)
	r.Delete("/account", deps.ActionsHandler.DeleteAccount)

	return r
}
