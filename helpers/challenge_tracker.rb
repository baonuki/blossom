# ==========================================
# HELPER: Weekly Challenge Progress Tracker
# DESCRIPTION: Hook function to increment challenge progress.
# Call from commands when trackable actions occur.
# ==========================================

def track_challenge(uid, type, amount = 1)
  week_start = current_week_start
  challenges = DB.get_weekly_challenges(week_start)
  return unless challenges # No challenges this week yet

  # Check if any active challenge matches this type
  has_matching = challenges.any? { |c| c['type'] == type }
  return unless has_matching

  DB.update_challenge_progress(uid, week_start, type, amount)
rescue => e
  puts "[CHALLENGE TRACKER] #{e.message}"
end
