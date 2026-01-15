# Current Focus

**Feature:** Binge Watching
**Intent:** truth/intent/binge-watching.md
**Evaluations:** truth/evaluations/invariants/binge-watching/
**Started:** 2026-01-14

## Next Actions

1. [x] Review and refine intent
2. [x] Write first evaluation spec
3. [x] Begin implementation

## Implementation Progress

### Phase 1: Foundation (Slow Layer) - Complete
- [x] Rails 7.2 app generated
- [x] PostgreSQL configured
- [x] Database migrations created and run
- [x] Core models implemented:
  - Household
  - Member
  - Title
  - ViewingRecord
  - Subscription
  - AvailabilityObservation

### Phase 2: Services (Medium Layer) - Complete
- [x] RecommendationEngine
- [x] AvailabilityService
- [x] SubscriptionIntelligence
- [x] DataExportService
- [x] AccountDeletionService

### Phase 2: Policies (Medium Layer) - Complete
- [x] DataSourceRegistry
- [x] BrandingPolicy
- [x] AssetRegistry
- [x] WebFetcherRegistry
- [x] DataPolicy
- [x] ExternalIntegrationRegistry
- [x] TrackingRegistry
- [x] DataExportPolicy
- [x] RevenuePolicy
- [x] DisplayPolicy
- [x] UserProfilePolicy

### Phase 3: Controllers & Views (Fast Layer) - Pending
- [ ] API endpoints
- [ ] Basic UI
