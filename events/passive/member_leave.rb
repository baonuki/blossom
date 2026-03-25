# ==========================================
# EVENT: Member Leave Cleanup
# DESCRIPTION: Wipes a user's individual server XP 
# when they leave the server to prevent database bloat.
# ==========================================

bot.member_leave do |event|
  # Completely wipe their footprint for this specific server
  DB.remove_user_xp(event.server.id, event.user.id)
end