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

  def crossover(p1, p2) do
    {c1, c2} =
      Enum.zip(p1.genes, p2.genes)
      |> Enum.map(fn {x, y} ->
        v = Bitwise.bor(x, y)
        {v, v}
      end)
      |> Enum.unzip()

    {%Chromosome{genes: c1, size: length(c1)}, %Chromosome{genes: c2, size: length(c2)}}
  end
end

soln =
  Genetic.run(OneMax,
    crossover_type: &OneMax.crossover/2,
    selection_rate: 0.9
  )

IO.write("\n")
IO.inspect(soln)
