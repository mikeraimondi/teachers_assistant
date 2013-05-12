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
    str += "Cohort-wide total score: #{total_score}\n" if options[:agg_total_score]
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

class Interface

  def self.dispatch(args)
    stdout = false
    if args.length == 0
      Interface.print_help
      return
    elsif args.length == 1
      begin
        if (args[0] =~ /^-h/) || (args[0] =~ /^--h/)
          Interface.print_help
          return
        end
        cohort = Interface.parse_csv(args[0])
        cohort.to_txt_file()
      rescue
        Interface.print_help
        return
      end
    else
      if (args[0] == "-stdout") || (args[0] == "-s")
        stdout = true
        args.shift()
      end
      file = args.shift()
      options = {}
      args.each do |arg|
        key = arg.to_sym
        options.merge!( {key => true})
      end
      begin
        cohort = Interface.parse_csv(file)
        stdout ? cohort.to_stdout(options) : cohort.to_txt_file(options) 
      rescue
        Interface.print_help
      end
    end
  end

  def self.print_help
    help = <<-DELIMIT
      usage: ruby teachers_assistant_round_1.rb [-h|--help]
             [-s|--stdout]<filename> <options>

      Valid options are:
        grades
        averages
        average_grades
        agg_total_score
        agg_average_score
        agg_min_score
        agg_max_score
        agg_standard_deviation
        DELIMIT
    puts help
  end

  def self.parse_csv(path)
    if !File.exists?(path)
      puts "Please enter a valid file name"
      print_help
      return
    elsif File.extname(path) != ".csv"
      puts "Please enter a valid .csv file"
      print_help
      return
    end
    begin
      cohort = Cohort.new( File.basename(path, ".csv") )
      prev_num_grades = false
      CSV.foreach(path) do |row|
        student_name = row[0].split()
        student = Student.new(student_name[0], student_name[1])
        row.delete_at(0)
        num_grades = 0
        row.each do |grade|
          num_grades += 1
          student.accumulate_grade(grade)
        end
        prev_num_grades ||= num_grades
        if prev_num_grades != num_grades
          puts "Error: entry #{student.full_name} has an unequal number of grades."
          break
        end
        prev_num_grades = num_grades
        cohort.add_student(student)
      end
      cohort
    rescue Exception => e
      puts e.message
      puts "Error reading file"
      return
    end
  end

end

Interface.dispatch(ARGV)
