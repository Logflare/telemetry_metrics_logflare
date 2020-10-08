defmodule LogflareTelemetry.Config do
  @moduledoc false
  use TypedStruct

  typedstruct do
    field :tick_interval, term()
    field :backend, term()
    field :beam, term()
    field :ecto, term()
    field :broadway, term()
    field :phoenix, term()
  end
end
