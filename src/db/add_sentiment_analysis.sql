-- SQL Script to add sentiment analysis capabilities to the database

-- 1. Add a sentiment column to the group_messages table
ALTER TABLE group_messages ADD COLUMN sentiment VARCHAR(20);
ALTER TABLE group_messages ADD COLUMN sentiment_score NUMERIC(5,2);

-- 2. Create a sentiment_stats table to store aggregate sentiment data
CREATE TABLE IF NOT EXISTS sentiment_stats (
    id SERIAL PRIMARY KEY,
    group_id INTEGER NOT NULL,
    day_date DATE NOT NULL,
    positive_count INTEGER DEFAULT 0,
    neutral_count INTEGER DEFAULT 0,
    negative_count INTEGER DEFAULT 0,
    CONSTRAINT fk_group FOREIGN KEY (group_id) REFERENCES groups(group_id) ON DELETE CASCADE,
    CONSTRAINT unique_group_day UNIQUE (group_id, day_date)
);

-- 3. Create an index for faster sentiment queries
CREATE INDEX idx_sentiment ON group_messages(group_id, sentiment);
CREATE INDEX idx_sentiment_stats_date ON sentiment_stats(day_date);

-- 4. Add a function to update sentiment stats
CREATE OR REPLACE FUNCTION update_sentiment_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- Update or insert sentiment stats for the day
    INSERT INTO sentiment_stats (group_id, day_date, 
        CASE WHEN NEW.sentiment = 'POSITIVE' THEN 1 ELSE 0 END,
        CASE WHEN NEW.sentiment = 'NEUTRAL' THEN 1 ELSE 0 END,
        CASE WHEN NEW.sentiment = 'NEGATIVE' THEN 1 ELSE 0 END)
    VALUES (NEW.group_id, CURRENT_DATE, 
        CASE WHEN NEW.sentiment = 'POSITIVE' THEN 1 ELSE 0 END,
        CASE WHEN NEW.sentiment = 'NEUTRAL' THEN 1 ELSE 0 END,
        CASE WHEN NEW.sentiment = 'NEGATIVE' THEN 1 ELSE 0 END)
    ON CONFLICT (group_id, day_date) DO UPDATE SET
        positive_count = sentiment_stats.positive_count + CASE WHEN NEW.sentiment = 'POSITIVE' THEN 1 ELSE 0 END,
        neutral_count = sentiment_stats.neutral_count + CASE WHEN NEW.sentiment = 'NEUTRAL' THEN 1 ELSE 0 END,
        negative_count = sentiment_stats.negative_count + CASE WHEN NEW.sentiment = 'NEGATIVE' THEN 1 ELSE 0 END;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5. Create a trigger to automatically update sentiment stats
CREATE TRIGGER trigger_update_sentiment_stats
AFTER INSERT ON group_messages
FOR EACH ROW
WHEN (NEW.sentiment IS NOT NULL)
EXECUTE FUNCTION update_sentiment_stats();

-- 6. Create a view for sentiment analytics
CREATE OR REPLACE VIEW group_sentiment_view AS
SELECT 
    g.group_id,
    g.group_name,
    ss.day_date,
    ss.positive_count,
    ss.neutral_count,
    ss.negative_count,
    (ss.positive_count + ss.neutral_count + ss.negative_count) AS total_messages,
    CASE 
        WHEN (ss.positive_count > ss.negative_count AND ss.positive_count > ss.neutral_count) THEN 'POSITIVE'
        WHEN (ss.negative_count > ss.positive_count AND ss.negative_count > ss.neutral_count) THEN 'NEGATIVE'
        ELSE 'NEUTRAL'
    END AS daily_sentiment
FROM 
    sentiment_stats ss
JOIN 
    groups g ON ss.group_id = g.group_id;

-- 7. Create a function to get sentiment trend for a group
CREATE OR REPLACE FUNCTION get_group_sentiment_trend(p_group_id INTEGER, p_days INTEGER)
RETURNS TABLE (
    day_date DATE,
    positive_count INTEGER,
    negative_count INTEGER,
    neutral_count INTEGER,
    daily_sentiment VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ss.day_date,
        ss.positive_count,
        ss.negative_count,
        ss.neutral_count,
        CASE 
            WHEN (ss.positive_count > ss.negative_count AND ss.positive_count > ss.neutral_count) THEN 'POSITIVE'
            WHEN (ss.negative_count > ss.positive_count AND ss.negative_count > ss.neutral_count) THEN 'NEGATIVE'
            ELSE 'NEUTRAL'
        END AS daily_sentiment
    FROM 
        sentiment_stats ss
    WHERE 
        ss.group_id = p_group_id
        AND ss.day_date >= (CURRENT_DATE - p_days)
    ORDER BY 
        ss.day_date DESC;
END;
$$ LANGUAGE plpgsql; 