defmodule Juntos.Factory do
  use ExMachina

  def user_factory do
    %{
      email: sequence(:email, &"user#{&1}@example.com")
    }
  end
end
