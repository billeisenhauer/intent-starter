-- 001_initial_schema.sql
-- Initial database schema for Binge Watching Go application
-- Derived from truth/intent/binge-watching.md invariants

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Households: Primary unit per invariant #5
CREATE TABLE households (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Members: First-class entities per invariant #5
CREATE TABLE members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    avatar_color VARCHAR(20) DEFAULT '#5B8A72',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_members_household ON members(household_id);

-- Titles: Content references
CREATE TABLE titles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    external_id VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(500) NOT NULL,
    title_type VARCHAR(20) NOT NULL CHECK (title_type IN ('movie', 'series')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_titles_external_id ON titles(external_id);

-- Viewing Records: Per-member tracking per invariant #5
CREATE TABLE viewing_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    member_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    title_id UUID NOT NULL REFERENCES titles(id) ON DELETE CASCADE,
    fully_watched BOOLEAN DEFAULT FALSE,
    progress DECIMAL(3,2) DEFAULT 0.0 CHECK (progress >= 0 AND progress <= 1),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(member_id, title_id)
);

CREATE INDEX idx_viewing_records_member ON viewing_records(member_id);
CREATE INDEX idx_viewing_records_title ON viewing_records(title_id);
CREATE INDEX idx_viewing_records_fully_watched ON viewing_records(fully_watched);

-- Subscriptions: For value guidance per invariant #9
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
    platform VARCHAR(100) NOT NULL,
    monthly_cost DECIMAL(10,2) NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    last_watched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(household_id, platform)
);

CREATE INDEX idx_subscriptions_household ON subscriptions(household_id);
CREATE INDEX idx_subscriptions_active ON subscriptions(active);

-- Availability Observations: Crowd-sourced per invariant #6
-- Never scraped from auth walls per invariant #7
CREATE TABLE availability_observations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title_id UUID NOT NULL REFERENCES titles(id) ON DELETE CASCADE,
    platform VARCHAR(100) NOT NULL,
    available BOOLEAN NOT NULL,
    reported_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reporter_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_availability_title ON availability_observations(title_id);
CREATE INDEX idx_availability_platform ON availability_observations(platform);
CREATE INDEX idx_availability_reported ON availability_observations(reported_at);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers
CREATE TRIGGER update_households_updated_at BEFORE UPDATE ON households
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_members_updated_at BEFORE UPDATE ON members
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_titles_updated_at BEFORE UPDATE ON titles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_viewing_records_updated_at BEFORE UPDATE ON viewing_records
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
