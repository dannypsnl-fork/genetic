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
  defp evolve(population, problem, generation, last_max_fitness, temperature, opts) do
    population = evaluate(population, &problem.fitness_function/1, opts)
    best = hd(population)

    # 冷卻計算的概念是要是變化率慢慢減少，就可以用來判斷是否要停止演算法
    temperature =
      (1 - Keyword.get(opts, :cooling_rate, 0.2)) *
        (temperature + abs(best.fitness - last_max_fitness))

    fit_str =
      if is_float(best.fitness) do
        :erlang.float_to_binary(best.fitness, decimals: 4)
      else
        best.fitness
      end

    IO.write("\rCurrent Best: #{fit_str}\tGeneration: #{generation}")

    if problem.terminate?(population, generation, temperature) do
      best
    else
      {parents, leftover} = select(population, opts)
      children = crossover(parents, opts)
      mutants = mutation(population, opts)
      offspring = children ++ mutants
      new_population = reinsertion(parents, offspring, leftover, opts)
      evolve(new_population, problem, generation + 1, best.fitness, temperature, opts)
    end
  end

  defp reinsertion(parents, offspring, leftover, opts) do
    strategy = Keyword.get(opts, :reinsertion_strategy, &Toolbox.Reinsertion.pure/3)
    apply(strategy, [parents, offspring, leftover])
  end

  defp evaluate(population, fitness_function, opts) do
    sort_fn = Keyword.get(opts, :sort_fn, &>=/2)

    population
    |> Enum.map(fn chromosome ->
      %Chromosome{chromosome | fitness: fitness_function.(chromosome), age: chromosome.age + 1}
    end)
    |> Enum.sort_by(& &1.fitness, sort_fn)
  end

  defp select(population, opts) do
    select_fn = Keyword.get(opts, :selection_type, &Toolbox.Selection.elite/2)
    select_rate = Keyword.get(opts, :selection_rate, 0.8)

    n = round(length(population) * select_rate)
    n = if rem(n, 2) == 0, do: n, else: n + 1

    parents = select_fn |> apply([population, n])

    leftover =
      population
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(parents))

    parents =
      parents
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple(&1))

    {parents, MapSet.to_list(leftover)}
  end

  defp crossover(population, opts) do
    crossover_fn = Keyword.get(opts, :crossover_type, &Toolbox.Crossover.single_point/2)

    population
    |> Enum.reduce(
      [],
      fn {p1, p2}, acc ->
        {c1, c2} = apply(crossover_fn, [p1, p2])
        [c1, c2 | acc]
      end
    )
  end

  defp mutation(population, opts) do
    mutation_fn = Keyword.get(opts, :mutation_type, &Toolbox.Mutation.flip/1)
    rate = Keyword.get(opts, :mutation_rate, 0.05)
    # 選出一定比例的 chromosome 去修改，用 floor 確保這個 n 是整數
    n = floor(length(population) * rate)

    population
    |> Enum.take_random(n)
    |> Enum.map(&apply(mutation_fn, [&1]))
  end

  defp initialize(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    for _ <- 1..population_size, do: genotype.()
  end
end
