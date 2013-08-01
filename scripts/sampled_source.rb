require_relative 'array_source'

##
# Source that samples n instances from another source using one pass reservoir sampling
class SampledSource < ArraySource
  # default n value if passed with no options
  @@default_n = 10

  ##
  # @param source [BaseSource, ConcatenatedSource] :n Source to sample from.
  # @options opts [Integer] Number of samples to collect.
  def initialize(source, opts={})
    @source = source
    @n = opts[:n] || nil

    if @p.nil? and @n.nil?
      @n = @@default_n
    end

    # reservoir, data count and float format n for non-integer divisions
    @reservoir = Array.new(size=@n)
    @count = 1
    @n_f = @n.to_f

    # sample first and then construct an in memory ArraySource of the sample
    sample

    # TODO sample stored twice, nuke reservoir after sampling
    super(Utilities.deep_copy(@reservoir), opts)
  end

  ##
  # @private
  # Performs the sampling from the source. Result is stored in the reservoir
  def sample
    @source.each do |sent|
      if @count <= @n
        @reservoir[@count - 1] = sent
      else
        p = Utilities.random.rand
        if p < (@n_f / @count)
          rem_index = Utilities.random.rand(@n)
          @reservoir[rem_index] = sent
        end
      end

      @count += 1
    end
  end
end