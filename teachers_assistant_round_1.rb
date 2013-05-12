require 'csv'
class Student

  attr_accessor :scores, :name

  def initialize(name)
    @name = name
    @scores = []
  end

  def accumulate_grade(score)
    @scores << score
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

  def print_all
    @students.each do |student|
      puts "Name: #{student.name}"
      print 'Grades: | ' 
      student.scores.each do |score|
        print "#{score} | "
      end
      puts "\n\n"
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
c.print_all
