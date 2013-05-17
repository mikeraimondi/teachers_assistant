require 'rspec'
require 'pry'
require_relative 'teachers_assistant_round_1_TDD'

describe Loader do
  let(:loader) { Loader.new('sample_data.csv') }
  let(:parsed) {
    [
        { first_name: 'Johnny', last_name: 'Smith', scores: [100, 80, 75, 78, 60] },
        { first_name: 'Sally', last_name: 'Strong', scores: [100, 100, 90, 95, 85] },
        { first_name: 'Jimmy', last_name: 'Fallon', scores: [95, 97, 85, 40, 85] },
        { first_name: 'Chris', last_name: 'Botsworth', scores: [98, 86, 85, 82, 80] },
        { first_name: 'Brian', last_name: 'Boyd', scores: [50, 60, 65, 70, 75] }
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

  it 'has scores' do
    student.accumulate_scores([100,50])
    expect(student.scores).to eql([100,50])
  end

  it 'appends new scores to existing scores' do
    student.accumulate_scores([100,50])
    student.accumulate_scores([50,100])
    expect(student.scores).to eql([100,50,50,100])
  end

  it 'appends a single score to existing scores' do
    student.accumulate_scores([100,50])
    student.accumulate_scores(75)
    expect(student.scores).to eql([100,50,75])
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
    expect(sally.scores).to eql([100, 100, 90, 95, 85])
  end

  describe "stringification" do
    let(:cohort_str) { cohort.stringify({}) }

    it 'is 7 lines long' do
      line_count = cohort_str.lines.count
      expect(line_count).to eql(7)
    end

    it 'has a header row' do
      header = "      Name          |\n"
      first_line = cohort_str.lines.first
      expect(first_line).to eql(header)
    end


    it 'has Sally Strong' do
      sally =  "Sally Strong        |\n"
      line_array = cohort_str.lines.to_a
      expect(line_array).to include(sally)
    end

    context "with scores" do
      let(:cohort_str) { cohort.stringify({student_scores: true}) }

      it 'is 7 lines long' do
        line_count = cohort_str.lines.count
        expect(line_count).to eql(7)
      end

      it 'has a header row' do
        header = "      Name          |     Scores\n"
        first_line = cohort_str.lines.first
        expect(first_line).to eql(header)
      end


      it 'has Sally Strong' do
        sally =  "Sally Strong        |100|100|90 |95 |85 |\n"
        line_array = cohort_str.lines.to_a
        expect(line_array).to include(sally)
      end

      context "and with student averages" do
        let(:cohort_str) { cohort.stringify( {student_scores: true, student_averages: true} ) }

        it 'has a header row with an average column' do
          header = "      Name          | Avg |     Scores\n"
          first_line = cohort_str.lines.first
          expect(first_line).to eql(header)
        end

        it 'has Sally with an average' do
          sally =  "Sally Strong        |94.0 |100|100|90 |95 |85 |\n"
          line_array = cohort_str.lines.to_a
          expect(line_array).to include(sally)
        end
      end

      context "and with student grades" do
        let(:cohort_str) { cohort.stringify( {student_scores: true, student_grades: true} ) }

        it 'has a header row with a grade column' do
          header = "      Name          |Grd|     Scores\n"
          first_line = cohort_str.lines.first
          expect(first_line).to eql(header)
        end

        it 'has Sally with a grade' do
          sally =  "Sally Strong        | A |100|100|90 |95 |85 |\n"
          line_array = cohort_str.lines.to_a
          expect(line_array).to include(sally)
        end
      end
    end

    context 'with aggregate information' do
      let(:cohort_str) { cohort.stringify( {aggregate_information: true} ) }

      it 'is 12 lines long' do
        line_count = cohort_str.lines.count
        expect(line_count).to eql(12)
      end

      it 'has the average score on line 9' do
        actual_line = cohort_str.lines.to_a[8].chomp
        expected_line = "Class-wide average score: 80.64"
        expect(actual_line).to eql(expected_line)
      end

      it 'has the minimum score on line 10' do
        actual_line = cohort_str.lines.to_a[9].chomp
        expected_line = "Class-wide minimum score: 40"
        expect(actual_line).to eql(expected_line)
      end

      it 'has the maximum score on line 11' do
        actual_line = cohort_str.lines.to_a[10].chomp
        expected_line = "Class-wide maximum score: 100"
        expect(actual_line).to eql(expected_line)
      end

      it 'has the standard deviation on line 12' do
        actual_line = cohort_str.lines.to_a[11].chomp
        expected_line = "Class-wide standard deviation: 15.71"
        expect(actual_line).to eql(expected_line)
      end

    end

  end

  describe 'writes to a text file' do
    let(:txt_file) { 'sample_data.txt' }
    let(:sally) { "Sally Strong        |94.0 | A |100|100|90 |95 |85 |\n" }

    it 'creates a file' do
      cohort.file_export
      expect(File.exists?(txt_file)).to eql(true)
    end

    it 'has Sally listed' do
      cohort.file_export
      expect(File.readlines(txt_file)).to include(sally)
    end

    it 'has Sally listed in the sixth row' do
      cohort.file_export
      rows = File.readlines(txt_file)
      expect(rows[5]).to eql(sally)
    end

  end
end
