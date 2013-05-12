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

  def accumulate_grade(score)
    @scores << score.to_i
  end

  def average_score
    total = 0
    @scores.each do |score|
      total += score
    end
    total.to_f / scores.length
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
      str += "Average score: #{student.average_score}\n" if options[:averages]
      str += "Average grade: #{student.average_grade}\n" if options[:average_grades]
      str += "\n"
    end
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
c.to_txt_file ( {grades: true, averages: true, average_grades: :true} )
