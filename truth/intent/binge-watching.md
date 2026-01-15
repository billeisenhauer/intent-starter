# Binge Watching

## Problem

Households with multiple streaming subscriptions experience decision fatigue and regret. Too many platforms, poor memory of watched content, recommendations that ignore household dynamics, and no guidance on subscription value.

## Core Identity

Binge Watching is a household-level viewing intelligence system that reduces decision fatigue by learning taste from viewing behavior, explaining recommendations clearly, tracking watched content, and providing subscription value guidance. It is a decision-support layer above streaming platforms, not a replacement for them.

## Invariants

- [ ] Recommendations must include a minimum of 3 options when sufficient data exists; cold start and new user onboarding may return fewer
- [ ] Every recommendation must display confidence to users; presentation format may evolve beyond numeric scores
- [ ] Every recommendation must have explainable reasons visible to users
- [ ] System must not re-recommend titles fully watched by the household
- [ ] Household members must be first-class entities, not individual-only accounts
- [ ] Availability data must be probabilistic and crowd-sourced, never scraped from behind auth walls
- [ ] System must not scrape protected content or imply platform partnerships
- [ ] System must not sell ads based on personal data
- [ ] Subscription intelligence must provide value-based guidance, not maximize engagement
- [ ] Users must be able to download their data
- [ ] Users must be able to delete their account and all associated data

## Non-Goals

- Replacing streaming apps or playback UX
- Becoming the canonical catalog of record
- Scraping protected content or implying partnerships
- Selling ads based on personal data
- Maximizing clicks or engagement metrics

## Status

- [x] Intent reviewed
- [x] Evaluations written
- [x] Implementation started
