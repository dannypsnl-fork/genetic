defmodule Problem do
  alias Types.Chromosome

  @type t :: module()

  @callback genotype :: Chromosome.t()
  @callback fitness_function(Chromosome.t()) :: number()
  @callback terminate?(Enum.t()) :: boolean()
end
