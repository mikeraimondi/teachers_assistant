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
      parsed_row = { grades: [] }

      row.each do |entry|
        entry = entry.strip

        if entry[0] =~ /\d/
          parsed_row[:grades] << entry.to_i
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
  attr_accessor :first_name,:last_name, :grades

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
    @grades = []
  end

  def full_name
    "#{@first_name} #{@last_name}"
  end

  def accumulate_grades(additional_grades)
    @grades.concat [additional_grades].flatten
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
      student.accumulate_grades student_hash[:grades]
      @students << student
    end
  end

  def stringify
    str = "      Name           |     Grades\n"
    students.each do |student|
      str << "#{student.full_name}"
      (20 - student.full_name.length).times { str << " "}
      str << "|"
      student.grades.each do |grade|
        if grade.to_s.length == 2
          str << " "
        elsif grade.to_s.length == 1
          str << "  "
        end
        str << "#{grade}"
        str << "|"
      end
      str << "\n"
    end
    str
  end
end
