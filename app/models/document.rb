require "quizzes/quizzes"

class Document
  extend ActiveModel::Naming

  attr_reader :source, :result, :output_hash

  def initialize(attributes = {})
    @source = attributes[:source]
    @result = "none"
  end

  def self.create(attributes)
    doc = new(attributes)
    doc.convert!
    doc
  end

  def convert!
    @output_hash = Quizzes::Import.process(@source, format: :dkt)
    @result = JSON.pretty_generate(output_hash)
  end
end
