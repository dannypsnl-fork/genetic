defmodule Genetic do
  @moduledoc """
  Documentation for `Genetic`.
  """

  @doc """
  entry to run a genetic algorithm

  ## Examples

      iex> genotype = fn -> for _ <- 1..1000, do: Enum.random(0..1) end
      iex> fitness_function = fn chromosome -> Enum.sum(chromosome) end
      iex> max_fitness = 1000
      iex> Genetic.run(fitness_function, genotype, max_fitness)
  """
  def run(fitness_function, genotype, max_fitness, opts \\ []) do
    population = initialize(genotype)

    population
    |> evolve(fitness_function, genotype, max_fitness, opts)
  end

  # improve
  defp evolve(population, fitness_function, genotype, max_fitness, opts \\ []) do
    population = evaluate(population, fitness_function, opts)
    best = hd(population)
    IO.write("\rCurrent Best: #{fitness_function.(best)}")
    if fitness_function.(best) == max_fitness do
      best
    else
      population
      |> select(opts)
      |> crossover(opts)
      |> mutation(opts)
      |> evolve(fitness_function, genotype, max_fitness, opts)
    end
  end

  defp evaluate(population, fitness_function, opts \\ []) do
    population
    |> Enum.sort_by(fitness_function, &>=/2)
  end

  defp select(population, opts \\ []) do
    population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple(&1))
  end

  defp crossover(population, opts \\ []) do
    population
    |> Enum.reduce(
      [],
      fn {p1, p2}, acc ->
        cx_point = :rand.uniform(length(p1))
        {{h1, t1}, {h2, t2}} = {Enum.split(p1, cx_point), Enum.split(p2, cx_point)}
        [h1 ++ t2, h2 ++ t1 | acc]
      end
    )
  end

  defp mutation(population, opts \\ []) do
    drop_possibility = Keyword.get(opts, :drop_possibility, 0.05)
    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < drop_possibility do
        Enum.shuffle(chromosome)
      else
        chromosome
      end
    end)
  end

  defp initialize(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    for _ <- 1..population_size, do: genotype.()
  end
end
