-- 002_seed_data.sql
-- Sample data for development

-- Insert a sample household
INSERT INTO households (id, name) VALUES
    ('11111111-1111-1111-1111-111111111111', 'The Smiths');

-- Insert household members
INSERT INTO members (id, household_id, name, avatar_color) VALUES
    ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Alice', '#5B8A72'),
    ('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'Bob', '#D4A574'),
    ('44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'Charlie', '#8B6914');

-- Insert sample titles
INSERT INTO titles (id, external_id, name, title_type) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'tt0111161', 'The Shawshank Redemption', 'movie'),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'tt0068646', 'The Godfather', 'movie'),
    ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'tt0944947', 'Game of Thrones', 'series'),
    ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'tt0903747', 'Breaking Bad', 'series'),
    ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'tt0816692', 'Interstellar', 'movie'),
    ('ffffffff-ffff-ffff-ffff-ffffffffffff', 'tt0468569', 'The Dark Knight', 'movie'),
    ('11111111-aaaa-bbbb-cccc-dddddddddddd', 'tt1375666', 'Inception', 'movie'),
    ('22222222-aaaa-bbbb-cccc-dddddddddddd', 'tt0110912', 'Pulp Fiction', 'movie'),
    ('33333333-aaaa-bbbb-cccc-dddddddddddd', 'tt1856101', 'Blade Runner 2049', 'movie'),
    ('44444444-aaaa-bbbb-cccc-dddddddddddd', 'tt4574334', 'Stranger Things', 'series');

-- Insert viewing records (some watched, some in progress)
INSERT INTO viewing_records (member_id, title_id, fully_watched, progress) VALUES
    ('22222222-2222-2222-2222-222222222222', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', true, 1.0),
    ('22222222-2222-2222-2222-222222222222', 'cccccccc-cccc-cccc-cccc-cccccccccccc', true, 1.0),
    ('22222222-2222-2222-2222-222222222222', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', false, 0.65),
    ('33333333-3333-3333-3333-333333333333', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', true, 1.0),
    ('33333333-3333-3333-3333-333333333333', 'dddddddd-dddd-dddd-dddd-dddddddddddd', false, 0.40),
    ('44444444-4444-4444-4444-444444444444', 'ffffffff-ffff-ffff-ffff-ffffffffffff', true, 1.0);

-- Insert subscriptions
INSERT INTO subscriptions (household_id, platform, monthly_cost, active, last_watched_at) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Netflix', 15.99, true, NOW() - INTERVAL '2 days'),
    ('11111111-1111-1111-1111-111111111111', 'Hulu', 12.99, true, NOW() - INTERVAL '15 days'),
    ('11111111-1111-1111-1111-111111111111', 'Disney+', 10.99, true, NOW() - INTERVAL '45 days'),
    ('11111111-1111-1111-1111-111111111111', 'HBO Max', 15.99, true, NOW() - INTERVAL '60 days');

-- Insert availability observations
INSERT INTO availability_observations (title_id, platform, available, reported_at, reporter_id) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Netflix', true, NOW() - INTERVAL '5 days', '22222222-2222-2222-2222-222222222222'),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Netflix', true, NOW() - INTERVAL '10 days', '33333333-3333-3333-3333-333333333333'),
    ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'HBO Max', true, NOW() - INTERVAL '3 days', '22222222-2222-2222-2222-222222222222'),
    ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Netflix', true, NOW() - INTERVAL '7 days', '33333333-3333-3333-3333-333333333333'),
    ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Netflix', false, NOW() - INTERVAL '2 days', '22222222-2222-2222-2222-222222222222'),
    ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'HBO Max', true, NOW() - INTERVAL '1 day', '44444444-4444-4444-4444-444444444444');
