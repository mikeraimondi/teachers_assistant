require 'csv'
class Student

  attr_accessor :scores, :first_name, :last_name

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
    @scores = []
  end

  def full_name
    first_name + " " + last_name
  end

  def total_score
    total = 0
    @scores.each do |score|
      total += score
    end
    total
  end

  def accumulate_grade(score)
    @scores << score.to_i
  end

  def average_score
    total_score.to_f / scores.length
  end

  def average_grade
    average = average_score
    case 
    when average >= 90
      'A'
    when average >= 80
      'B'
    when average >= 70
      'C'
    when average >= 60
      'D'
    else
      'F'
    end
  end

end

class Cohort

  attr_accessor :name, :students

  def initialize(name)
    @name = name
    @students = []
  end

  def add_student(student)
    @students << student
  end

  def students_by_last_name
    @students.sort { |a,b| a.last_name.downcase <=> b.last_name.downcase }
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

  def stringify(options = {})
    str = "Class: #{name}\n\n"
    students_by_last_name.each do |student|
      str += "Name: #{student.full_name}\n"
      if options[:grades]
        str += 'Grades: | ' 
        student.scores.each do |score|
          str += "#{score} | "
        end
        str += "\n"
      end
      str += "Average score: #{student.average_score.round(1)}\n" if options[:averages]
      str += "Average grade: #{student.average_grade}\n" if options[:average_grades]
      str += "\n"
    end
    str += "Cohort-wide total score: #{total_score}\n" if options[:agg_total_scores]
    str += "Cohort-wide average score: #{average_score.round(1)}\n" if options[:agg_average_score]
    str += "Cohort-wide minimum score: #{all_scores.min}\n" if options[:agg_min_score]
    str += "Cohort-wide maximum score: #{all_scores.max}\n" if options[:agg_max_score]
    str += "Cohort-wide standard deviation: #{standard_deviation.round(2)}\n" if options[:agg_standard_deviation]
    str
  end

  def to_stdout(options = {})
    print stringify(options)
  end

  def to_txt_file(options = {})
    path = "#{@name}.txt" 
    File.open(path, 'w') do |file|
      file.puts stringify(options)
    end
  end

end

class Parser

  PATH = "sample_data.csv"

  def self.parse_csv
    begin
      cohort = Cohort.new( File.basename(PATH, ".csv") )
      CSV.foreach(PATH) do |row|
        student_name = row[0].split()
        student = Student.new(student_name[0], student_name[1])
        row.delete_at(0)
        row.each do |grade|
          student.accumulate_grade(grade)
        end
        cohort.add_student(student)
      end
      cohort
    rescue
      puts "Error reading file"
    end
  end

end

c = Parser.parse_csv()
c.to_txt_file ( {grades: true, averages: true, average_grades: :true, agg_average_score: :true, 
                  agg_min_score: true, agg_max_score: true, agg_standard_deviation: true} )
