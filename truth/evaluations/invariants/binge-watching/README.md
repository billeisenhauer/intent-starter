# Binge Watching Invariants

Evaluations for binge-watching feature.

## Planned Specs

- [x] `recommendation_minimum_spec.rb` — Verifies minimum 3 recommendations when sufficient data exists; cold start returns fewer
- [x] `recommendation_confidence_spec.rb` — Verifies confidence is displayed to users
- [x] `recommendation_explainability_spec.rb` — Verifies every recommendation includes visible reasons
- [x] `finished_title_exclusion_spec.rb` — Verifies fully watched titles are not re-recommended
- [x] `household_membership_spec.rb` — Verifies household members are first-class entities
- [x] `availability_sourcing_spec.rb` — Verifies availability data is crowd-sourced, not scraped
- [x] `no_protected_scraping_spec.rb` — Verifies system does not scrape protected content
- [x] `no_ad_sales_spec.rb` — Verifies system does not sell ads based on personal data
- [x] `subscription_guidance_spec.rb` — Verifies subscription intelligence provides value-based guidance
- [x] `data_download_spec.rb` — Verifies users can download their data
- [x] `account_deletion_spec.rb` — Verifies users can delete their account and all associated data

## Observable Outcomes

- Given a household with sufficient viewing history, when requesting recommendations, then at least 3 options are returned
- Given a new user with no history, when requesting recommendations, then fewer than 3 options may be returned gracefully
- Given a recommendation, when displayed to user, then confidence is visible
- Given a recommendation, when displayed to user, then explainable reasons are visible
- Given a title fully watched by household, when requesting recommendations, then that title is excluded
- Given a household account, when adding members, then each member has first-class entity status
- Given availability data, when sourced, then it comes from crowd-sourced signals only
- Given the system, when operating, then no protected content is scraped
- Given the system, when operating, then no ads are sold based on personal data
- Given subscription analysis, when presented, then guidance is value-based not engagement-maximizing
- Given a user request, when downloading data, then all user data is provided
- Given a user request, when deleting account, then account and all associated data are removed
