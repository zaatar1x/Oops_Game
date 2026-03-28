-- Function to increment profile stats (XP, games_played, streak, level)
-- This bypasses RLS policies when called as an RPC function

CREATE OR REPLACE FUNCTION increment_profile_stats(
  user_id_input UUID,
  xp_gain INTEGER
)
RETURNS TABLE (
  new_xp INTEGER,
  new_streak INTEGER,
  new_level INTEGER,
  new_games_played INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  current_xp INTEGER;
  current_games INTEGER;
  current_streak INTEGER;
  calculated_xp INTEGER;
  calculated_games INTEGER;
  calculated_streak INTEGER;
  calculated_level INTEGER;
BEGIN
  -- Get current values
  SELECT xp, games_played, streak
  INTO current_xp, current_games, current_streak
  FROM profiles
  WHERE id = user_id_input;

  -- Calculate new values
  calculated_xp := COALESCE(current_xp, 0) + xp_gain;
  calculated_games := COALESCE(current_games, 0) + 1;
  calculated_streak := COALESCE(current_streak, 0) + 1;
  calculated_level := FLOOR(calculated_xp / 1000.0) + 1;

  -- Update the profile
  UPDATE profiles
  SET 
    xp = calculated_xp,
    games_played = calculated_games,
    streak = calculated_streak,
    level = calculated_level
  WHERE id = user_id_input;

  -- Return the new values
  RETURN QUERY
  SELECT 
    calculated_xp,
    calculated_streak,
    calculated_level,
    calculated_games;
END;
$$;
