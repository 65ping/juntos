defmodule Juntos.Factory do
  use ExMachina

  @moduledoc false
  def user_factory do
    %{
      email: sequence(:email, &"user#{&1}@example.com")
    }
  end
end
