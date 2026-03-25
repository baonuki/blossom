# ==========================================
# SYSTEM: Module Loader
# DESCRIPTION: Dynamically requires all Ruby files in the project.
# ==========================================

def safe_load(file_path, context_binding)
  begin
    eval(File.read(file_path), context_binding)
    puts "✅ Loaded: #{File.basename(file_path)}"
  rescue StandardError => e
    puts "❌ ERROR in #{File.basename(file_path)}!"
    puts "   Line: #{e.backtrace.first}"
    puts "   Message: #{e.message}"
  rescue SyntaxError => e
    puts "⚠️ SYNTAX ERROR in #{File.basename(file_path)}!"
    puts "   Message: #{e.message}"
  end
end

def load_blossom_modules(bot_binding)
  puts "\n[SYSTEM] Booting Blossom Modules..."

  # 1. Load Helpers first (Foundation)
  Dir.glob(File.join(__dir__, '..', 'helpers', '**', '*.rb')).each do |file|
    safe_load(file, bot_binding)
  end

  # 2. Load logic folders
  ['commands', 'events', 'components'].each do |folder|
    Dir.glob(File.join(__dir__, '..', folder, '**', '*.rb')).each do |file|
      # Skip this loader file itself to avoid infinite loops!
      next if file.include?('loader.rb') 
      safe_load(file, bot_binding)
    end
  end
end