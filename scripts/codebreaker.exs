defmodule Codebreaker do
  @behaviour Problem
  alias Types.Chromosome

  @impl Problem
  def genotype() do
    genes = for _ <- 1..64, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 64}
  end

  @impl Problem
  def fitness_function(chromosome) do
    target = "ILoveGeneticAlgorithms"
    encrypted = 'LIjs`B`k`qlfDibjwlqmhv'
    cipher = fn word, key -> Enum.map(word, &rem(Bitwise.bxor(&1, key), 32768)) end

    key =
      chromosome.genes
      |> Enum.map(&Integer.to_string(&1))
      |> Enum.join("")
      |> String.to_integer(2)

    guess = List.to_string(cipher.(encrypted, key))
    String.jaro_distance(target, guess)
  end

  @impl Problem
  def terminate?(population, _generation, _temperature) do
    best = Enum.max_by(population, &fitness_function/1)
    best.fitness == 1
  end
end

soln =
  Genetic.run(Codebreaker,
    crossover_type: &Toolbox.Crossover.single_point/2,
    mutation_type: &Toolbox.Mutation.scramble/1
  )

{key, _} =
  soln.genes
  |> Enum.map(&Integer.to_string(&1))
  |> Enum.join("")
  |> Integer.parse(2)

IO.write("\nThe key is #{key}\n")
