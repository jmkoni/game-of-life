class Cell
  attr_accessor :alive
  LIVE_STATES = [:dying, :alive]
  DEAD_STATES = [:dead, :zombie]
  ALL_STATES = DEAD_STATES + LIVE_STATES
  def initialize(alive=:alive)
    @alive = alive
  end

  def transition(value)
    if value == -20
      @alive = :zombie
    elsif value < 0
      if @alive == :alive
        @alive = :dying
      elsif @alive == :dying
        @alive = :dead
      elsif @alive == :dead
        @alive = :zombie
      end
    elsif value > 0
      if @alive == :dead
        @alive = :dying
      elsif @alive == :dying
        @alive = :alive
      end
    end
  end
end

class Grid
  attr_accessor :cells
  attr_reader :not_all_dead
  # size determines nxn size of array
  def initialize(size)
    @cells = Array.new(size) { Array.new(size, Cell.new()) }
    @not_all_dead = true
  end

  def step
    new_grid = self.dup
    @cells.each_with_index do | row, i |
      row.each_with_index do | col, j |
        count, zombie_count = count_neighbors(i, j)
        cell_transition_value = set_cell_next_state(count, zombie_count)
        new_grid.cells[i,j].transition(cell_transition_value)
      end
    end
    new_grid
  end

  private

  def set_cell_next_state(alive_neighbors_count, zombie_neighbors_count)
    alive_additive = 0
    if zombie_neighbors_count > 0
      alive_additive = -20
    if (alive_neighbors_count < 2) or (alive_neighbors_count > 3)
      alive_additive = -1
    elsif alive_neighbors_count == 3
      alive_additive = 1
    end
    alive_additive
  end

  def count_neighbors(i, j)
    count_live = 0
    count_zombie = 0
    (-1..1).each do | num1 |
      (-1..1).each do | num2 |
        unless num1 == 0 and num2 == 0
          if Cell::LIVE_STATES.include?(@cells[i + num1][j + num2].alive)
            count_live += 1
          elsif @cells[i + num1][j + num2].alive == :zombie
            count_zombie += 1
          end
        end
      end
    end
    count_live, count_zombie
  end
end

class Game
  def initialize(size)
    @grid = Grid.new(size)
  end

  def play
    while @grid.not_all_dead
      @grid = @grid.step
      play
    end
  end
end