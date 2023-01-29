defmodule Genetic do
  @moduledoc """
  Documentation for `Genetic`.
  """
  alias Problem
  alias Types.Chromosome

  @doc """
  entry to run a genetic algorithm
  """
  @spec run(Problem.t()) :: Chromosome.t()
  def run(problem, opts \\ []) do
    population = initialize(&problem.genotype/0)

    population
    |> evolve(problem, 0, 0, 0, opts)
  end

  # improve
  defp evolve(population, problem, generation, last_max_fitness, temperature, opts \\ []) do
    population = evaluate(population, &problem.fitness_function/1, opts)
    best = Enum.max_by(population, &problem.fitness_function/1)
    cooling_rate = Keyword.get(opts, :cooling_rate, 0.2)
    temperature = (1 - cooling_rate) * (temperature + (best.fitness - last_max_fitness))
    IO.write("\rCurrent Best: #{best.fitness}")

    if problem.terminate?(population, generation, temperature) do
      best
    else
      population
      |> select(opts)
      |> crossover(opts)
      |> mutation(opts)
      |> evolve(problem, generation + 1, best.fitness, temperature, opts)
    end
  end

  defp evaluate(population, fitness_function, opts \\ []) do
    sort_fn = Keyword.get(opts, :sort_fn, &>=/2)

    population
    |> Enum.map(fn chromosome ->
      %Chromosome{chromosome | fitness: fitness_function.(chromosome), age: chromosome.age + 1}
    end)
    |> Enum.sort_by(& &1.fitness, sort_fn)
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
        cx_point = :rand.uniform(length(p1.genes))
        {h1, t1} = Enum.split(p1.genes, cx_point)
        {h2, t2} = Enum.split(p2.genes, cx_point)
        c1 = %Chromosome{p1 | genes: h1 ++ t2}
        c2 = %Chromosome{p2 | genes: h2 ++ t1}
        [c1, c2 | acc]
      end
    )
  end

  defp mutation(population, opts \\ []) do
    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < Keyword.get(opts, :drop_possibility, 0.05) do
        %Chromosome{chromosome | genes: Enum.shuffle(chromosome.genes)}
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
