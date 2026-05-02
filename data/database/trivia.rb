require 'json'

module DatabaseTrivia
  public

  def get_trivia_session(uid)
    row = @db.exec_params(
      "SELECT correct_label, correct_text, options_json, reward, answered, asked_at FROM trivia_sessions WHERE user_id = $1",
      [uid]
    ).first
    return nil unless row

    {
      correct: row['correct_label'],
      correct_text: row['correct_text'],
      options: (JSON.parse(row['options_json']) rescue []),
      reward: row['reward'].to_i,
      answered: row['answered'].to_i == 1,
      asked_at: row['asked_at'] ? Time.parse(row['asked_at'].to_s) : Time.now
    }
  end

  def save_trivia_session(uid, correct_label, correct_text, options, reward)
    @db.exec_params(
      "INSERT INTO trivia_sessions (user_id, correct_label, correct_text, options_json, reward, answered, asked_at)
       VALUES ($1, $2, $3, $4, $5, 0, NOW())
       ON CONFLICT (user_id) DO UPDATE
       SET correct_label = $2, correct_text = $3, options_json = $4, reward = $5, answered = 0, asked_at = NOW()",
      [uid, correct_label, correct_text, options.to_json, reward]
    )
  end

  def mark_trivia_answered(uid)
    @db.exec_params(
      "UPDATE trivia_sessions SET answered = 1, asked_at = NOW() WHERE user_id = $1",
      [uid]
    )
  end

  def clear_trivia_session(uid)
    @db.exec_params("DELETE FROM trivia_sessions WHERE user_id = $1", [uid])
  end
end
