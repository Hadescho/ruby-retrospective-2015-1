class Card
  attr_reader :rank, :suit, :custom_suits, :custom_ranks
  include Comparable

  SUITS = [:clubs, :diamonds, :hearts, :spades].freeze
  RANKS = [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace].freeze

  def initialize(rank, suit, custom_ranks_array = nil, custom_suits_array = nil)
    @custom_ranks = custom_ranks_array || RANKS
    @custom_suits = custom_suits_array || SUITS
    unless @custom_suits.include?(suit) and @custom_ranks.include?(rank)
      raise ArgumentError.new("Invaliad arguments to create a card")
    end
    @rank = rank
    @suit = suit
  end

  def to_s
    "#{@rank.to_s.capitalize} of #{@suit.to_s.capitalize}"
  end

  def <=>(other)
    comparison = @custom_suits.find_index(suit) <=>
      @custom_suits.find_index(other.suit)
    if comparison == 0
      comparison = @custom_ranks.find_index(rank) <=>
        @custom_ranks.find_index(other.rank)
    end
    comparison
  end
end

# The first card in the array is the card on the top
# The last card in the array is the card on the bottom
module DeckModule
  include Enumerable

  def each(&block)
    cards_collection.each(&block)
  end

  def size
    cards_collection.size
  end

  def draw_top_card
    cards_collection.shift
  end

  def draw_bottom_card
    cards_collection.pop
  end

  def top_card
    cards_collection.first
  end

  def bottom_card
    cards_collection.last
  end

  def shuffle
    cards_collection.shuffle!
  end

  def sort
    cards_collection.sort!.reverse!
    self
  end

  def to_s
    cards_collection.map(&:to_s).join("\n")
  end
end

class Deck
  include DeckModule

  def initialize(deck = nil)
    deck = Array(deck) if deck
    @deck = deck || self.class.generate_deck
  end

  def self.generate_deck
    Card::RANKS.product(Card::SUITS).each_with_object([]) do |pair, deck|
      deck << Card.new(pair.first, pair.last)
    end
  end

  private

  def cards_collection
    @deck
  end
end

class WarDeck < Deck
  HAND_SIZE = 26
  def deal
    card_array = []
    HAND_SIZE.times do
      card_array << draw_top_card
    end
    WarHand.new(card_array)
  end
end

class WarHand
  include DeckModule

  def initialize(card_array)
    @hand = card_array
  end

  def allow_face_up?
    cards_collection.size <= 3
  end

  alias_method :play_card, :draw_top_card

  private

  def cards_collection
    @hand
  end
end

class SixtySixDeck < Deck
  RANKS = [9, :jack, :queen, :king, 10, :ace].freeze
  HAND_SIZE = 6
  def deal
    hand_array = []
    6.times do
      hand_array << draw_top_card
    end
    SixtySixHand.new(hand_array)
  end

  def self.generate_deck
    RANKS.product(Card::SUITS).each_with_object([]) do |pair, deck|
      deck << Card.new(pair.first, pair.last, RANKS)
    end
  end
end

class SixtySixHand
  include DeckModule

  def initialize(hand_array)
    @hand = hand_array
  end

  def twenty?(trump_suit)
    valid_suits = Card::SUITS.dup
    valid_suits.delete(trump_suit)
    valid_suits.any? do |suit|
      @hand.include? Card.new(:queen, suit) and
        @hand.include? Card.new(:king, suit)
    end
  end

  def forty?(trump_suit)
    @hand.include? Card.new(:queen, trump_suit) and
      @hand.include? Card.new(:king, trump_suit)
  end

  private

  def cards_collection
    @hand
  end
end

class BeloteDeck < Deck
  RANKS = [7, 8, 9, :jack, :queen, :king, 10, :ace].freeze
  HAND_SIZE = 8

  def deal
    hand = []
    HAND_SIZE.times{ hand << draw_top_card }
    BeloteHand.new(hand)
  end

  private

  def self.generate_deck
    RANKS.product(Card::SUITS).each_with_object([]) do |suit_and_rank, deck|
      deck << Card.new(suit_and_rank.first, suit_and_rank.last, RANKS)
    end
  end
end

class BeloteHand
  include DeckModule
  def initialize(hand)
    @hand = hand
  end

  def highest_of_suit(suit)
    suit_collection = @hand.select{ |card| card.suit == suit }
    BeloteHand.new(suit_collection).sort.draw_top_card
  end

  def belote?
    Card::SUITS.any? do |suit|
      @hand.include? Card.new(:queen, suit) and
        @hand.include? Card.new(:king, suit)
    end
  end

  def carre_of_jacks?
    carre_of?(:jack)
  end

  def carre_of_nines?
    carre_of?(9)
  end

  def carre_of_aces?
    carre_of?(:ace)
  end

  def tierce?
    consecutive(3)
  end

  def quarte?
    consecutive(4)
  end

  def quint?
    consecutive(5)
  end

  private

  def carre_of?(rank)
    @hand.select{ |card| card.rank == rank}.size == 4
  end

  def consecutive(count)
    sort
    ranks = @hand.first.custom_ranks
    @hand.each_cons(count).any? do |consecutive_cards|
      (consecutive_cards.map(&:suit).uniq.size == 1) and
        consecutive_cards.each_cons(2).all? do |first, second|
          ranks.find_index(first.rank) == ranks.find_index(second.rank) + 1
        end
    end

  end

  def cards_collection
    @hand
  end
end
