defmodule Types.Chromosome do
  @type t :: %__MODULE__{
          genes: Enum.t(),
          size: integer(),
          fitness: number(),
          age: integer()
        }

  @enforce_keys :genes
  defstruct [:genes, size: 0, fitness: 0, age: 0]
end

defimpl Enumerable, for: Types.Chromosome do
  def count(t) do
    Enumerable.count(t.genes)
  end

  def member?(t, term) do
    Enumerable.member?(t.genes, term)
  end

  def reduce(t, acc, reducer) do
    Enumerable.reduce(t.genes, acc, reducer)
  end

  def slice(t) do
    Enumerable.slice(t.genes)
  end
end
