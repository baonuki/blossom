# ==========================================
# HELPER: Blacklist Guard for Interactions
# DESCRIPTION: discordrb's `ignore_user` only blocks message events, so slash
# commands and component clicks slip through. This patches the interaction
# handlers to short-circuit blacklisted users with an ephemeral notice
# instead of running the command.
# ==========================================

BLACKLIST_NOTICE = "🚫 *Yeah, no. You're on my blacklist, chat \u2014 the arcade's closed for you. " \
                   "Take it up with the dev if you think it's a mistake.*".freeze

def respond_blacklisted(event)
  event.respond(content: BLACKLIST_NOTICE, ephemeral: true)
rescue StandardError => e
  puts "[BLACKLIST GUARD] failed to respond: #{e.class}: #{e.message}"
end

# --- Slash commands ---
module Discordrb
  module Events
    class ApplicationCommandEventHandler
      alias_method :__original_blossom_call, :call unless method_defined?(:__original_blossom_call)

      def call(event)
        return unless matches?(event)

        if event.respond_to?(:user) && event.user && event.bot.ignored?(event.user.id)
          return respond_blacklisted(event)
        end

        __original_blossom_call(event)
      end
    end

    # --- Buttons, selects, modals: any interaction component event ---
    class ComponentEventHandler
      alias_method :__original_blossom_call, :call unless method_defined?(:__original_blossom_call)

      def call(event)
        return unless matches?(event)

        if event.respond_to?(:user) && event.user && event.bot.ignored?(event.user.id)
          return respond_blacklisted(event)
        end

        __original_blossom_call(event)
      end
    end
  end
end
