defmodule PointingPartyWeb.LayoutHelpers do
  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def signed_in?(conn) do
    conn.assigns[:username]
  end
end
