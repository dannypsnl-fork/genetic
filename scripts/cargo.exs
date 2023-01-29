defmodule Cargo do
  @moduledoc """
  optimizing cargo loads

  1. We have ten products: A, B, C, D, E, F, G, H, I, J
  2. cargo weight limit: 40
  3. associated weight of each product: [10, 6, 8, 7, 10, 9, 7, 11, 6, 8]
  4. associated profit of each product: [6, 5, 8, 9, 6, 7, 3, 1, 2, 6]
  """
  @behaviour Problem
  alias Types.Chromosome

  @impl Problem
  def genotype() do
    # use a binary string to represent 10 product
    # 1010001100 means picking product A, C, G, H
    genes = for _ <- 1..10 , do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 10}
  end

  @impl Problem
  def fitness_function(chromosome) do
    profits = [6, 5, 8, 9, 6, 7, 3, 1, 2, 6]
    weights = [10, 6, 8, 7, 10, 9, 7, 11, 6, 8]
    weight_limit = 40

    potential_profits =
      chromosome.genes
      |> Enum.zip(profits)
      |> Enum.map(fn {g, profit} -> profit * g end)
      |> Enum.sum()
    over_limit? =
      chromosome.genes
      |> Enum.zip(weights)
      |> Enum.map(fn {g, w} -> g * w end)
      |> Enum.sum()
      |> Kernel.>(weight_limit)

    profits = if over_limit?, do: 0, else: potential_profits
    profits
  end

  @impl Problem
  def terminate?(population, generation, temperature) do
    best = Enum.max_by(population, &Cargo.fitness_function/1)
    generation == 1000
  end
end

soln = Genetic.run(Cargo)
IO.write("\n")
IO.inspect(soln)

weight = soln.genes
  |> Enum.zip([10, 6, 8, 7, 10, 9, 7, 11, 6, 8])
  |> Enum.map(fn {g, weight} -> weight * g end)
  |> Enum.sum()
IO.write("\nWeight is: #{weight}")
