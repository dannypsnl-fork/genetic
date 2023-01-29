defmodule Problem do
  alias Types.Chromosome

  @type t :: module()

  # initial chromosome
  @callback genotype :: Chromosome.t()
  # How good the chromosome(solution) is?
  @callback fitness_function(Chromosome.t()) :: number()
  # population -> generation -> temperature -> stop?
  @callback terminate?(Enum.t(), integer(), integer()) :: boolean()
end
