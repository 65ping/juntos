defmodule Juntos.DataCaseTest do
  use Juntos.DataCase, async: true

  describe "errors_on/1" do
    test "returns a map of field error messages" do
      changeset =
        {%{}, %{name: :string}}
        |> Ecto.Changeset.cast(%{}, [:name])
        |> Ecto.Changeset.validate_required([:name])

      errors = errors_on(changeset)
      assert errors.name == ["can't be blank"]
    end

    test "interpolates %{count} in length validation messages" do
      changeset =
        {%{}, %{name: :string}}
        |> Ecto.Changeset.cast(%{name: "ab"}, [:name])
        |> Ecto.Changeset.validate_length(:name, min: 5)

      errors = errors_on(changeset)
      assert Enum.any?(errors.name, &(&1 =~ "5"))
    end

    test "returns empty map for valid changeset" do
      changeset =
        {%{}, %{name: :string}}
        |> Ecto.Changeset.cast(%{name: "Alice"}, [:name])
        |> Ecto.Changeset.validate_required([:name])

      assert errors_on(changeset) == %{}
    end

    test "returns multiple errors for a field" do
      changeset =
        {%{}, %{name: :string}}
        |> Ecto.Changeset.cast(%{name: "x"}, [:name])
        |> Ecto.Changeset.validate_length(:name, min: 3)
        |> Ecto.Changeset.validate_format(:name, ~r/\d/, message: "must contain a digit")

      errors = errors_on(changeset)
      assert length(errors.name) == 2
    end
  end
end
