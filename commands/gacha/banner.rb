def execute_banner(event)
  active_banner = get_current_banner
  chars = active_banner[:characters]
  week_number = Time.now.to_i / 604_800 
  available_pools = CHARACTER_POOLS.keys
  next_key = available_pools[(week_number + 1) % available_pools.size]
  next_banner = CHARACTER_POOLS[next_key]
  next_rotation_time = (week_number + 1) * 604_800

  fields = [
    { name: '🌟 Legendaries (5%)', value: chars[:legendary].map { |c| c[:name] }.join(', '), inline: false },
    { name: '✨ Rares (25%)', value: chars[:rare].map { |c| c[:name] }.join(', '), inline: false },
    { name: '⭐ Commons (69%)', value: chars[:common].map { |c| c[:name] }.join(', '), inline: false }
  ]

  desc = "Here are the VTubers you can pull this week!\n\n**Next Rotation:** <t:#{next_rotation_time}:R>\n**Up Next:** #{next_banner[:name]}"
  send_embed(event, title: "#{EMOJIS['neonsparkle']} Current Gacha: #{active_banner[:name]}", description: desc, fields: fields)
end

bot.command(:banner, description: 'Check which characters are in the gacha pool this week!', category: 'Gacha') { |e| execute_banner(e); nil }
bot.application_command(:banner) { |e| execute_banner(e) }