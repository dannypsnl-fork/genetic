defmodule Schedule do
  @behaviour Problem
  alias Types.Chromosome

  @credit_hours [3.0, 3.0, 3.0, 4.5, 3.0, 3.0, 3.0, 3.0, 4.5, 1.5]
  @diffculties [8.0, 9.0, 4.0, 3.0, 5.0, 2.0, 4.0, 2.0, 6.0, 1.0]
  @usefulness [8.0, 9.0, 6.0, 2.0, 8.0, 9.0, 1.0, 2.0, 5.0, 1.0]
  @interest [8.0, 8.0, 5.0, 9.0, 7.0, 2.0, 8.0, 2.0, 7.0, 10.0]

  def genotype() do
    genes = for _ <- 1..10, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: 10}
  end

  def fitness_function(chromosome) do
    schedule = chromosome.genes

    fitness =
      [schedule, @diffculties, @usefulness, @interest]
      |> Enum.zip()
      |> Enum.map(fn {class, diff, use, int} ->
        class * (0.3 * use + 0.3 * int - 0.3 * diff)
      end)
      |> Enum.sum()

    credit =
      schedule
      |> Enum.zip(@credit_hours)
      |> Enum.map(fn {class, c} -> class * c end)
      |> Enum.sum()

    if credit > 18.0 do
      -99999
    else
      fitness
    end
  end

  def terminate?(_, generation, _) do
    generation == 10000
  end
end

soln =
  Genetic.run(
    Schedule,
    reinsertion_type: &Toolbox.Reinsertion.elitist(&1, &2, &3, 0.1),
    selection_rate: 0.8,
    mutation_rate: 0.1
    # invariant: selection_rate + mutation_rate + survival_rate = 1.0
  )

IO.write("\n")
IO.inspect(soln)
