require "securerandom"

class Quizzes::Converter::Dkt
  QUIZZ_REGEX = /\A#([^#].*)/.freeze
  QUESTION_REGEX = /\A##([^#].*)/.freeze
  CHOICE_REGEX = /\A-\s*\[(.*?)\]\s*(.*)/.freeze
  COMMENT_REGEX = /\A###([^#].*)/.freeze

  QUIZZ_NAME_INDEX = 1.freeze
  QUESTION_NAME_INDEX = 1.freeze
  CHOICE_NAME_INDEX = 2.freeze
  CHOICE_CORRECT_INDEX = 1.freeze
  QUESTION_COMMENT_INDEX = 1.freeze

  def initialize
    @quizzes = []
  end

  def convert(source)
    ary = parse(source)
    result = transform(ary)
    result.size == 1 ? result[0] : result
  end

  def parse(source)
    source.each_line do |line|
      case true
      when quizz?(line)
        @quizzes << @quizz.dup unless @quizz.nil?
        @quizz = { name: "", questions: []}
        @quizz[:name] = @current_match[QUIZZ_NAME_INDEX].strip
      when question?(line)
        @quizz[:questions] << @question.dup unless @question.nil?
        @question = { name: "", choices: [], comment: "" }
        @question[:name] = @current_match[QUESTION_NAME_INDEX].strip
      when choice?(line)
        choice = { name: "", correct: false }
        choice[:name] = @current_match[CHOICE_NAME_INDEX].strip
        choice[:correct] = true if @current_match[CHOICE_CORRECT_INDEX].downcase.strip == "x"
        @question[:choices] << choice
      when comment?(line)
        @question[:comment] = @current_match[QUESTION_COMMENT_INDEX].strip
      else
      end
    end
    @question[:choices] << @choice.dup unless @choice.nil?
    @quizz[:questions] << @question.dup unless @question.nil?
    @quizzes << @quizz.dup unless @quizz.nil?
    @quizzes
  end

  def transform(ary)
    ary.map do |quizz_hash|
      quizz_hash[:questions] = quizz_hash[:questions].map do |q|
        q.merge!(uuid: SecureRandom.uuid)
        q[:allow_multiple_choices] = q[:choices].count { |q| q[:correct] } > 1

        q[:choices] = q[:choices].map do |ch|
          ch.merge!(uuid: SecureRandom.uuid, question_uuid: q[:uuid])
          ch
        end

        0.upto(q[:choices].size - 1) do |i|
          q[:choices][i][:after_choice] = i == 0 ? nil : q[:choices][i - 1][:uuid]
        end

        q
      end

      hsh = {}
      hsh[:name] = quizz_hash[:name]
      hsh[:questions] = quizz_hash[:questions].map { |q| q.slice(:name, :uuid, :comment, :allow_multiple_choices) }
      hsh[:choices] = quizz_hash[:questions].map { |q| q[:choices] }.reduce(:+).map { |ch| ch.slice(:name, :uuid, :correct, :after_choice, :question_uuid) }
      hsh
    end
  end

  private

  def quizz?(line)
    @current_match = line.match(QUIZZ_REGEX)
    @current_match.present?
  end

  def question?(line)
    @current_match = line.match(QUESTION_REGEX)
    @current_match.present?
  end

  def choice?(line)
    @current_match = line.match(CHOICE_REGEX)
    @current_match.present?
  end

  def comment?(line)
    @current_match = line.match(COMMENT_REGEX)
    @current_match.present?
  end
end
