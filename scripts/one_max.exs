defmodule OneMax do
  @behaviour Problem
  alias Types.Chromosome

  @impl Problem
  def genotype() do
    genes = for _ <- 1..1000, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 42}
  end

  @impl Problem
  def fitness_function(chromosome) do
    Enum.sum(chromosome.genes)
  end

  @impl Problem
  def terminate?([best | _]) do
    best.fitness == 1000
  end
end

soln = Genetic.run(OneMax)
IO.write("\n")
IO.inspect(soln)
