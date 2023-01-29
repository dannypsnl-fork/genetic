defmodule Speller do
  @behaviour Problem
  alias Types.Chromosome

  def genotype() do
    genes =
      Stream.repeatedly(fn -> Enum.random(?a..?z) end)
      |> Enum.take(34)

    %Chromosome{genes: genes, size: 34}
  end

  def fitness_function(chromosome) do
    target = "supercalifragilisticexpialidocious"
    guess = List.to_string(chromosome.genes)
    String.jaro_distance(target, guess)
  end

  def terminate?(population, generation, _temperature) do
    best = Enum.max_by(population, &fitness_function/1)
    best.fitness >= 1 or generation == 10000
  end
end

soln = Genetic.run(Speller, crossover_type: &Toolbox.Crossover.single_point/2)
IO.write("\n")
IO.inspect(soln)
