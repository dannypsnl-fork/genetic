defmodule Portfolio do
  @behaviour Problem
  alias Types.Chromosome

  @target_fitness 180

  @impl Problem
  def genotype() do
    genes = for _ <- 1..10 , do: {:rand.uniform(10), :rand.uniform(10)}
    %Chromosome{genes: genes, size: 10}
  end

  @impl Problem
  def fitness_function(chromosome) do
    chromosome
    |> Enum.map(fn {roi, risk} -> 2 * roi - risk end)
    |> Enum.sum()
  end

  @impl Problem
  def terminate?(population, _generation, _temperature) do
    max_value = Enum.max_by(population, &fitness_function/1)
    max_value > @target_fitness
  end
end

soln = Genetic.run(Portfolio)
IO.write("\n")
IO.inspect(soln)
