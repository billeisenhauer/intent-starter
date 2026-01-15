package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/config"
	httpHandler "github.com/plentyofsaas/bingewatching/apps/go-web/internal/http"
	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/http/handlers"
	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/repository/postgres"
	"github.com/plentyofsaas/bingewatching/apps/go-web/internal/service"
)

func main() {
	// Load configuration
	cfg := config.Load()

	log.Printf("Starting Binge Watching (Go) on port %d", cfg.Port)
	log.Printf("Environment: %s", cfg.Environment)

	// Connect to database
	ctx := context.Background()
	db, err := postgres.NewDB(ctx, cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	log.Println("Connected to database")

	// Initialize repositories
	householdRepo := postgres.NewHouseholdRepository(db)
	memberRepo := postgres.NewMemberRepository(db)
	titleRepo := postgres.NewTitleRepository(db)
	viewingRecordRepo := postgres.NewViewingRecordRepository(db)
	subscriptionRepo := postgres.NewSubscriptionRepository(db)
	availabilityRepo := postgres.NewAvailabilityRepository(db)

	// Initialize services
	recommendationSvc := service.NewRecommendationEngine(titleRepo, viewingRecordRepo, availabilityRepo)
	subscriptionSvc := service.NewSubscriptionIntelligence(subscriptionRepo, viewingRecordRepo)

	// Initialize handlers
	dashboardHandler := handlers.NewDashboardHandler(
		householdRepo,
		memberRepo,
		viewingRecordRepo,
		subscriptionRepo,
		titleRepo,
		recommendationSvc,
		subscriptionSvc,
	)

	actionsHandler := handlers.NewActionsHandler(
		householdRepo,
		memberRepo,
		viewingRecordRepo,
	)

	// Create router
	router := httpHandler.NewRouter(httpHandler.Dependencies{
		DashboardHandler: dashboardHandler,
		ActionsHandler:   actionsHandler,
	})

	// Create server
	server := &http.Server{
		Addr:         fmt.Sprintf(":%d", cfg.Port),
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Start server in goroutine
	go func() {
		log.Printf("Server listening on http://localhost:%d", cfg.Port)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server error: %v", err)
		}
	}()

	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("Shutting down server...")

	// Graceful shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

	log.Println("Server stopped")
}
