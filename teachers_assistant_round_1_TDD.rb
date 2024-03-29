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

  def total_score
    @scores.inject(0){|sum,x| sum + x }
  end

  def average_score
    total_score / score_count.to_f
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

  def all_scores
    scores = []
    @students.each do |student|
      student.scores.each do |score|
        scores << score
      end
    end
    scores
  end

  def total_score
    total = 0
    all_scores.each do |score|
      total += score
    end
    total
  end

  def average_score
    total = total_score
    total_score.to_f / all_scores.length
  end

  def standard_deviation
    average = average_score
    diffs = []
    all_scores.each do |score|
      diff = (score - average)
      diff = diff * diff
      diffs << diff
    end
    total_diffs = 0
    diffs.each do |diff|
      total_diffs += diff
    end
    Math.sqrt(total_diffs / diffs.length)
  end

  def students_by_last_name
    @students.sort { |a,b| a.last_name.downcase <=> b.last_name.downcase }
  end

  def format_col(col, width)
    col = col.to_s.center(width)
    col << "|"
  end

  def stringify(options = {student_scores: true})
    str = "      Name          |"
    str << " Avg |" if options[:student_averages]
    str << "Grd|" if options[:student_grades]
    str << "     Scores" if options[:student_scores]
    str << "\n"
    students_by_last_name.each do |student|
      str << "#{student.full_name}"
      (20 - student.full_name.length).times { str << " "}
      str << "|"
      str << format_col(student.average_score, 5) if options[:student_averages]
      str << format_col(student.grade, 3) if options[:student_grades]
      student.scores.each { |score| str << format_col(score, 3) } if options[:student_scores]
      str << "\n"
    end
    str << "\n"
    if options[:aggregate_information]
      str << "---Aggregate information---\n"
      str << "Class-wide average score: #{average_score}\n"
      str << "Class-wide minimum score: #{all_scores.min}\n"
      str << "Class-wide maximum score: #{all_scores.max}\n"
      str << "Class-wide standard deviation: #{standard_deviation.round(2)}\n"
    end
    str
  end

  def file_export
    path = "#{@name}.txt"
    str = stringify({ student_scores: true, student_averages: true,
                      student_grades:true })
    File.open(path, 'w') do |f|
      f.write(str)
    end
  end
end

c = Cohort.new('sample_data.csv')
puts c.stringify({student_scores: true, student_averages: true,
                  student_grades: true, aggregate_information: true})
