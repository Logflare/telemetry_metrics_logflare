defmodule LogflareTelemetry.Config do
  @moduledoc false
  use TypedStruct

  typedstruct do
    field :api_client, term(), enforce: true
    field :api_key, term(), enforce: true
    field :url, binary(), enforce: true
    field :source_id, term(), enforce: true
    field :max_batch_size, integer(), enforce: true

    field :tick_interval, term()
    field :backend, term()
    field :beam, term()
    field :ecto, term()
    field :broadway, term()
    field :phoenix, term()
  end
end
