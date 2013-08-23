require 'stringio'

# Describes a pipeline artifact. Usually a set of generated files
class Artifact

  attr_reader :num_folds, :id

  # @option opts [Integer, NilClass] :num_folds (nil) Number of folds. nil specifies no folds.
  # @option opts [String, NilClass] :basename (nil) Base filename and path for files in this artifact.
  # @option opts [Symbol] :id (:unknown_artifact) External artifact identifier.
  # @option opts [Symbol, Enumerable, Hash] :files (nil) File specification. A Symbol or Enumarble containing
  #   symbols specifies that StringIO or File objects (using the :basename) will be created for each Symbol
  #   with the Symbol name appended to the file name. A fully constructed Hash with keys and IO instances may
  #   be passed instead.
  def initialize(opts={})
    @num_folds = opts[:num_folds] || nil
    @basename = opts[:basename] || nil
    @id = opts[:id] || :unknown_artifact
    @files = opts[:files] || nil
    @file_type

    if has_folds?
      @files = *@files
      @files += [:true, :pred]
    end

    unless @files.is_a? Hash
      if has_folds?
        @files = @num_folds.times.collect { |i| init_files @files, i }
      else
        @files = init_files @files
      end
    end
  end

  # Creates artifact paths and IO instances where needed
  # @private
  # @param files [Hash, Enumerable, Symbol] A fully or partially initialized set of file artifacts.
  # @param fold_id [Integer, NilClass] Fold index
  # @return [Hash] A fully initialized set of file artifacts.
  def init_files(files, fold_id=nil)
    if files.is_a? Symbol
      file_id = files
      files = {}
      files[file_id] = init_file(file_id, fold_id)
    elsif files.is_a? Enumerable
      file_ids = files
      files = {}

      file_ids.each { |file_id| files[file_id] = init_file(file_id, fold_id) }
    end

    return files
  end

  # Creates IO instance for a given file artifact using basename and file_id.
  # If no basename is given a StringIO instance is created instead of a File instance.
  # @private
  # @param file_id [String, Symbol] An id for this particular file used to create the filename.
  # @param fold_id [Integer, nil] Fold index if applicable.
  # @return [IO]
  def init_file(file_id, fold_id=nil)
    if @basename
      return File.open(create_path(file_id, fold_id), 'w')
    else
      return StringIO.new
    end
  end

  # Creates a pathname for an artifact file
  # @private
  # @param file_id [String, Symbol] Id which will be part of the path.
  # @param fold_id [Integer, nil] Fold id which will be part of the path of provided.
  # @return [String] Path for the given artifact file and fold.
  def create_path(file_id, fold_id=nil)
    return "#{basename(fold_id)}_#{file_id.to_s}"
  end

  # Close all open files for this Artifact instance.
  def close
    if has_folds?
      @files.each { |f| f.each_value { |v| v.close if not v.closed? } }
    else
      @files.each_value { |v| v.close if not v.closed? }
    end
  end

  # Indicates if the artifact is a set of dataset folds.
  # @return [TrueClass, FalseClass, NilClass]
  def has_folds?
    return (@num_folds and (@num_folds >= 2))
  end

  # @return [Range, NilClass] The range of fold indexes or nil if the artifact does not have folds
  def fold_ids
    if has_folds?
      return (0...@num_folds)
    else
      return nil
    end
  end

  ##
  # @return [Enumerable] The id's (Symbol) for the resources in this Artifact instance.
  def file_ids
    @files.keys
  end

  # Accessor for IO instances of the various files in the artifact
  # @param file_id [Symbol] Identifier key for the file
  # @param fold_id [Integer, NilClass] Fold index, obligatory if artifact contains folds
  # @return [IO]
  # @raise [ArgumentError] If fold_id is passed on a non-folded artifact and vice-versa
  def file(file_id, fold_id=nil)
    if has_folds? and not fold_id.nil?
      return @files[fold_id][file_id]
    elsif fold_id.nil? and not has_folds?
      return @files[file_id]
    else
      raise ArgumentError
    end
  end

  # Accessor for file system paths of the artifact files. Only applicable if such files exists, ie. the artifact
  # is initialized with the :basename option or appropriate :files Hash.
  # @param file_id [Symbol] Identifier key for the file
  # @param fold_id [Integer, NilClass] Fold index, obligatory if artifact contains folds
  # @return [String]
  # @raise [ArgumentError] If fold_id is passed on a non-folded artifact and vice-versa
  def path(file_id, fold_id=nil)
    file = file(file_id, fold_id)

    if file.is_a? File
      return file.path
    elsif file.is_a? String
      return file
    else
      return nil
    end
  end

  ##
  # Retrieves an open IO/StringIO instance to the indicated artifact file.
  # @param file_id [Symbol] Identifier key for the file
  # @param perms [String] Permission string for File instances.
  # @param fold_id [Integer, NilClass] Fold index, obligatory if artifact contains folds
  # @yieldparam file [IO, StringIO] A block is passed the open IO/StringIO instance which is automatically closed.
  # @return [IO, StringIO]
  def open(file_id, perms=nil, fold_id=nil)
    file = file(file_id, fold_id)

    if file.kind_of?(File)
      file = File.open(file.path, perms)
    elsif file.kind_of?(StringIO)
      file = StringIO.new(file.string)
    else
      raise RuntimeError
    end

    if block_given?
      yield file
      file.close
    else
      file
    end
  end

  # Accessor for the base path/filename optionally including the fold index
  # @param fold_id [Integer, NilClass] Fold index, obligatory if artifact contains folds
  # @return [String]
  # @raise [ArgumentError] If fold_id is passed on a non-folded artifact and vice-versa
  def basename(fold_id=nil)
    if has_folds? and not fold_id.nil?
      return "#{@basename}_#{fold_id}"
    elsif fold_id.nil? and not has_folds?
      return @basename
    else
      raise ArgumentError
    end
  end

  ##
  # Creates an artifact from a Hash with file id (Symbol) and String pairs.
  # @note Creates StringIO instances for the strings internally.
  # @param file_ids_and_strings [Hash] File id (Symbol) and String pairs as keys and values respectively in a Hash.
  # @return [Artifact]
  def self.from_strings(file_ids_and_strings)
    file_ids_and_stringio = {}

    file_ids_and_strings.each do |file_id, string|
      file_ids_and_stringio[file_id] = StringIO.new(string)
    end

    Artifact.new(files: file_ids_and_stringio)
  end

  def file_type
    return @file_type if @file_type

    @file_type = nil

    file_ids.each do |file_id|
      if @file_type.nil?
        @file_type = file(file_id).class
      elsif @file_type != file(file_id).class
        return :mixed
      end
    end

    @file_type
  end
end
