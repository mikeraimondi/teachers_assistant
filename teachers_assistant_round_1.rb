require 'csv'
class Student

  attr_accessor :scores, :name

  def initialize(name)
    @name = name
    @scores = []
  end

  def accumulate_grade(score)
    @scores << score.to_i
  end

  def average_score
    total = 0
    @scores.each do |score|
      total += score
    end
    total / scores.length
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

  attr_accessor :students

  def initialize
    @students = []
  end

  def add_student(student)
    @students << student
  end

  def print_students(options = {})
    @students.each do |student|
      puts "Name: #{student.name}"
      if options[:grades]
        print 'Grades: | ' 
        student.scores.each do |score|
          print "#{score} | "
        end
        puts "\n"
      end
      print "Average score: #{student.average_score}\n" if options[:averages]
      print "Average grade: #{student.average_grade}\n" if options[:average_grades]
      puts "\n"
    end
  end

end

class Parser

  def self.parse_csv
    cohort = Cohort.new
    CSV.foreach("sample_data.csv") do |row|
      student = Student.new(row[0])
      row.delete_at(0)
      row.each do |grade|
        student.accumulate_grade(grade)
      end
      cohort.add_student(student)
    end
    cohort
  end

end

c = Parser.parse_csv()
c.print_students( {grades: true, averages: true, average_grades: :true} )
