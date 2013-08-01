require_relative 'array_source'

class SampledSource < ArraySource
  @@default_n = 10

  def initialize(source, opts={})
    @source = source
    @n = opts[:n] || nil

    if @p.nil? and @n.nil?
      @n = @@default_n
    end

    # data needed to keep top @n
    @reservoir = Array.new(size=@n)
    @count = 1
    @n_f = @n.to_f

    sample

    # TODO sample stored twice, nuke reservoir after sampling
    super(Utilities.deep_copy(@reservoir), opts)
  end

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