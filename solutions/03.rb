class FibonacciSequence
  include Enumerable
  def initialize(size, first: 1, second: 1)
    return @sequence = [] if size == 0
    return @sequence = [first] if size == 1
    @sequence = [first, second]
    (size - 2).times do
      @sequence << @sequence.last(2).reduce(:+)
    end
  end

  def size
    @sequence.size
  end

  def each(&block)
    @sequence.each(&block)
  end
end

class PrimeSequence
  include Enumerable

  def initialize(size)
    @sequence = []
    counter = 2
    while @sequence.size < size
      @sequence << counter if PrimeSequence.prime?(counter)
      counter += 1
    end
  end

  def size
   @sequence.size
  end

  def each(&block)
    @sequence.each(&block)
  end

  def self.prime?(number)
    return false if number <= 1
    (2..(number**0.5)).none? { |divider| number % divider == 0 }
  end

  def make_size_even
    @sequence << 1 if @sequence.size.odd?
    self
  end
end

class RationalSequence
  include Enumerable

  def initialize(size)
    if size == 0
      @sequence = []
    elsif size == 1
      @sequence = [1.to_r]
    else
      @sequence = generate_sequence(size)
    end
  end

  def size
    @sequence.size
  end

  def each(&block)
    @sequence.each(&block)
  end

  private

  def generate_sequence(size)
    sequence = [1.to_r]
    (1..size).each do |row|
      method_for_row = row.even? ? :reverse_each : :each
      ((1..row).to_a.zip (1..row).to_a.reverse).send(method_for_row) do |rational_array|
        rational_number = Rational(rational_array.first, rational_array.last)
        sequence << rational_number
      end
    end
    sequence.uniq.first(size)
  end
end

module DrunkenMathematician

  module_function

  def aimless(number)
    return 0 if number == 0
    prime_sequence = PrimeSequence.new(number).make_size_even.to_a
    sequence = []
    sequence << prime_sequence.shift(2) until prime_sequence.empty?
    sequence.map { |sub_array| Rational(sub_array.first, sub_array.last) }.reduce(:+)
  end

  def meaningless(number)
    return 1 if number == 0
    rational_sequence_array = RationalSequence.new(number).to_a
    first_group = rational_sequence_array.select do |number|
      PrimeSequence.prime?(number.denominator) or PrimeSequence.prime?(number.numerator)
    end
    second_group = rational_sequence_array.select do |number|
      not PrimeSequence.prime?(number.denominator) and not PrimeSequence.prime?(number.numerator)
    end
    (first_group.reduce(:*) or 1) / (second_group.reduce(:*) or 1)
  end

  def worthless(number)
    return [] if number <= 0
    result_combination = []
    fibonacci_number = FibonacciSequence.new(number).to_a.last
    (1..Float::INFINITY).lazy.each do |current_number|
      # combination = combination_check(fibonacci_number, current_number)
      # break if combination.empty?
      # p combination
      # result_combination = combination
      combinations = RationalSequence.new(current_number).to_a.combination(current_number).to_a
      selected_combination = combinations.select do |combination|
        combination.reduce(:+) <= fibonacci_number
      end.max_by(&:size)
      break unless selected_combination
      result_combination = selected_combination
    end
    result_combination
  end
end
