defmodule Toolbox.Mutation do
  alias Types.Chromosome

  def flip(chromosome) do
    genes =
      chromosome.genes
      |> Enum.map(&Bitwise.bxor(&1, 1))

    %Chromosome{genes: genes, size: chromosome.size}
  end

  def flip2(chromosome, p) do
    genes =
      chromosome.genes
      |> Enum.map(fn g ->
        if :rand.uniform() < p do
          Bitwise.bxor(g, 1)
        else
          g
        end
      end)

    %Chromosome{genes: genes, size: chromosome.size}
  end

  def scramble(chromosome) do
    genes =
      chromosome.genes
      |> Enum.shuffle()

    %Chromosome{genes: genes, size: chromosome.size}
  end

  def gaussian(chromosome) do
    mu = Enum.sum(chromosome.genes)

    sigma_sum =
      chromosome.genes
      |> Enum.map(fn x -> (mu - x) * (mu - x) end)
      |> Enum.sum()

    sigma = sigma_sum / length(chromosome.genes)

    genes =
      chromosome.genes
      |> Enum.map(fn _ -> :rand.normal(mu, sigma) end)

    %Chromosome{genes: genes, size: chromosome.size}
  end
end
