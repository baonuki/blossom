require 'json'

module DatabaseTrivia
  public

  def get_trivia_session(uid)
    row = @db.exec_params(
      "SELECT correct_label, correct_text, options_json, reward, answered,
              EXTRACT(EPOCH FROM asked_at)::bigint AS asked_epoch
       FROM trivia_sessions WHERE user_id = $1",
      [uid.to_i]
    ).first
    return nil unless row

    {
      correct: row['correct_label'],
      correct_text: row['correct_text'],
      options: (JSON.parse(row['options_json']) rescue []),
      reward: row['reward'].to_i,
      answered: row['answered'].to_i == 1,
      asked_at: row['asked_epoch'] ? Time.at(row['asked_epoch'].to_i) : Time.now
    }
  rescue => e
    puts "[TRIVIA DB ERROR] get_trivia_session(#{uid}) failed: #{e.class}: #{e.message}"
    nil
  end

  def save_trivia_session(uid, correct_label, correct_text, options, reward)
    @db.exec_params(
      "INSERT INTO trivia_sessions (user_id, correct_label, correct_text, options_json, reward, answered, asked_at)
       VALUES ($1, $2, $3, $4, $5, 0, NOW())
       ON CONFLICT (user_id) DO UPDATE
       SET correct_label = EXCLUDED.correct_label,
           correct_text  = EXCLUDED.correct_text,
           options_json  = EXCLUDED.options_json,
           reward        = EXCLUDED.reward,
           answered      = 0,
           asked_at      = NOW()",
      [uid.to_i, correct_label.to_s, correct_text.to_s, options.to_json, reward.to_i]
    )
    true
  rescue => e
    puts "[TRIVIA DB ERROR] save_trivia_session(#{uid}) failed: #{e.class}: #{e.message}"
    false
  end

  def mark_trivia_answered(uid)
    @db.exec_params(
      "UPDATE trivia_sessions SET answered = 1, asked_at = NOW() WHERE user_id = $1",
      [uid.to_i]
    )
  rescue => e
    puts "[TRIVIA DB ERROR] mark_trivia_answered(#{uid}) failed: #{e.class}: #{e.message}"
  end

  def clear_trivia_session(uid)
    @db.exec_params("DELETE FROM trivia_sessions WHERE user_id = $1", [uid.to_i])
  rescue => e
    puts "[TRIVIA DB ERROR] clear_trivia_session(#{uid}) failed: #{e.class}: #{e.message}"
  end
end
