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
end
