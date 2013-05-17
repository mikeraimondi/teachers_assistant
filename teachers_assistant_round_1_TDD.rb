require 'csv'
require 'pry'

class Loader
  attr_accessor :file

  def initialize(file)
    @file = file
  end

  def parse
    parsed_csv = []

    CSV.foreach(@file) do |row|
      parsed_row = { scores: [] }

      row.each do |entry|
        entry = entry.strip

        if entry[0] =~ /\d/
          parsed_row[:scores] << entry.to_i
        else
          full_name = entry.split
          parsed_row[:first_name] = full_name[0]
          parsed_row[:last_name] = full_name[1]
        end
      end

      parsed_csv << parsed_row
    end

    parsed_csv
  end
end

class Student
  attr_accessor :first_name,:last_name, :scores

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
    @scores = []
  end

  def full_name
    "#{@first_name} #{@last_name}"
  end

  def accumulate_scores(additional_scores)
    @scores.concat [additional_scores].flatten
  end

  def score_count
    @scores.length
  end

  def average_score
    (@scores.inject(0){|sum,x| sum + x }) / score_count
  end

  def grade
    avg = average_score
    case
    when avg >= 90
      'A'
    when avg >= 80
      'B'
    when avg >= 70
      'C'
    when avg >= 60
      'D'
    else
      'F'
    end
  end

end

class Cohort
  attr_accessor :name, :students

  def initialize(file)
    @name = File.basename(file, File.extname(file))
    @students = []
    loader = Loader.new(file)
    loader.parse.each do |student_hash|
      student = Student.new(student_hash[:first_name], student_hash[:last_name])
      student.accumulate_scores student_hash[:scores]
      @students << student
    end
  end

  def format_col(col)
    str = ""
    if col.class == String
      str << " "
      str << "#{col}"
      str << " "
    else
      if col.to_s.length == 2
        str << " "
      elsif col.to_s.length == 1
        str << "  "
      end
      str << "#{col}"
    end
    str << "|"
  end

  def stringify(options = {student_scores: true})
    str = "      Name           |"
    str << "Avg|" if options[:student_averages]
    str << "Grd|" if options[:student_grades]
    str << "     Scores" if options[:student_scores]
    str << "\n"
    students.each do |student|
      str << "#{student.full_name}"
      (20 - student.full_name.length).times { str << " "}
      str << "|"
      str << format_col(student.average_score) if options[:student_averages]
      str << format_col(student.grade) if options[:student_grades]
      student.scores.each { |score| str << format_col(score) } if options[:student_scores]
      str << "\n"
    end
    str
  end
end
