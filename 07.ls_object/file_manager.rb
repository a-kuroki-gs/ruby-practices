class FileManager
  attr_reader :files

  def initialize(files)
    @files = files
  end

  def reject_dot_files
    filtered_files = @files.reject { |file| file.name.start_with?('.') }
    FileManager.new(filtered_files)
  end

  def reverse_files
    reversed_files = @files.reverse
    FileManager.new(reversed_files)
  end

  def calculate_block_counts
    @files.sum(&:blocks) / 2
  end
end
