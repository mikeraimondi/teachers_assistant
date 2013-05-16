require 'rspec'
require 'pry'
require_relative 'teachers_assistant_round_1_TDD'

describe Loader do
  let(:loader) { Loader.new('sample_data.csv') }
  let(:parsed) {
    [
        { first_name: 'Johnny', last_name: 'Smith', grades: [100, 80, 75, 78, 60] },
        { first_name: 'Sally', last_name: 'Strong', grades: [100, 100, 90, 95, 85] },
        { first_name: 'Jimmy', last_name: 'Fallon', grades: [95, 97, 85, 40, 85] },
        { first_name: 'Chris', last_name: 'Botsworth', grades: [98, 86, 85, 82, 80] },
        { first_name: 'Brian', last_name: 'Boyd', grades: [50, 60, 65, 70, 75] }
    ]
  }

  it 'has a file' do
    expect(loader.file).to eql('sample_data.csv')
  end

  it 'returns an array of hashes of parsed values' do
    expect(loader.parse).to eql(parsed)
  end
end

describe Student do
  let(:student) { Student.new('Tim', 'Foobar') }

  it 'has a first name' do
    expect(student.first_name).to eql('Tim')
  end

  it 'has a last name' do
    expect(student.last_name).to eql('Foobar')
  end

  it 'has a full name' do
    expect(student.full_name).to eql('Tim Foobar')
  end

  it 'has grades' do
    student.accumulate_grades([100,50])
    expect(student.grades).to eql([100,50])
  end

  it 'appends new grades to existing grades' do
    student.accumulate_grades([100,50])
    student.accumulate_grades([50,100])
    expect(student.grades).to eql([100,50,50,100])
  end

  it 'appends a single grade to existing grades' do
    student.accumulate_grades([100,50])
    student.accumulate_grades(75)
    expect(student.grades).to eql([100,50,75])
  end
end

describe Cohort do
  let(:cohort) { Cohort.new('sample_data.csv') }

  it 'has a name' do
    expect(cohort.name).to eql('sample_data')
  end

  it 'has an array of students' do
    expect(cohort.students.length).to eql(5)
  end

  it 'includes a student named Sally Strong' do
    sally = ''
    cohort.students.each { |student| sally = student if student.first_name == 'Sally' && student.last_name == 'Strong' }
    expect(sally.grades).to eql([100, 100, 90, 95, 85])
  end

  describe "Cohort stringification" do
    let(:cohort_str) { cohort.stringify }

    it 'is 6 lines long' do
      line_count = cohort_str.lines.count
      expect(line_count).to eql(6)
    end

    it 'has a header row' do
      header = "      Name           |     Grades\n"
      first_line = cohort_str.lines.first
      expect(first_line).to eql(header)
    end


    it 'has Sally Strong' do
      sally =  "Sally Strong        |100|100| 90| 95| 85|\n"
      line_array = cohort_str.lines.to_a
      expect(line_array).to include(sally)
    end
  end

end
