defmodule OneMax do
  @behaviour Problem
  alias Types.Chromosome

  @impl Problem
  def genotype() do
    genes = for _ <- 1..1000, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 1000}
  end

  @impl Problem
  def fitness_function(chromosome) do
    Enum.sum(chromosome.genes)
  end

  @impl Problem
  def terminate?(population, _generation, _temperature) do
    best = Enum.max_by(population, &fitness_function/1)
    best.fitness == 1000
  end
end

soln = Genetic.run(OneMax, crossover_type: &Toolbox.Crossover.single_point/2)
IO.write("\n")
IO.inspect(soln)
