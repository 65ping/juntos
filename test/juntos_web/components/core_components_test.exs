defmodule JuntosWeb.CoreComponentsTest do
  use ExUnit.Case, async: true

  use Phoenix.Component

  import Phoenix.LiveViewTest,
    only: [rendered_to_string: 1, render_component: 2]

  import JuntosWeb.CoreComponents

  # ---------------------------------------------------------------------------
  # Pure functions
  # ---------------------------------------------------------------------------

  describe "translate_error/1" do
    test "returns the message string when no interpolation" do
      assert translate_error({"is invalid", []}) == "is invalid"
    end

    test "substitutes integer opts into the message" do
      result = translate_error({"must be at least %{count} characters", [count: 8]})
      assert result =~ "8"
    end

    test "returns a string for plural-form messages" do
      result = translate_error({"must have %{count} item(s)", [count: 3]})
      assert is_binary(result)
    end
  end

  describe "translate_errors/2" do
    test "returns translated messages for the requested field" do
      errors = [name: {"can't be blank", []}, email: {"is invalid", []}]
      assert translate_errors(errors, :name) == ["can't be blank"]
      assert translate_errors(errors, :email) == ["is invalid"]
    end

    test "returns empty list when field has no errors" do
      errors = [name: {"can't be blank", []}]
      assert translate_errors(errors, :email) == []
    end

    test "returns all messages for a field with multiple errors" do
      errors = [name: {"can't be blank", []}, name: {"is too short", []}]
      assert length(translate_errors(errors, :name)) == 2
    end
  end

  describe "show/2" do
    test "returns a Phoenix.LiveView.JS struct" do
      assert %Phoenix.LiveView.JS{} = show("#el")
    end

    test "accepts an existing JS struct as first argument" do
      js = %Phoenix.LiveView.JS{}
      assert %Phoenix.LiveView.JS{} = show(js, "#el")
    end
  end

  describe "hide/2" do
    test "returns a Phoenix.LiveView.JS struct" do
      assert %Phoenix.LiveView.JS{} = hide("#el")
    end

    test "accepts an existing JS struct as first argument" do
      js = %Phoenix.LiveView.JS{}
      assert %Phoenix.LiveView.JS{} = hide(js, "#el")
    end
  end

  # ---------------------------------------------------------------------------
  # Component rendering — slot-less components via render_component
  # ---------------------------------------------------------------------------

  describe "icon/1" do
    test "renders a span with the hero icon class" do
      html = render_component(&icon/1, name: "hero-x-mark", class: "size-4")
      assert html =~ "hero-x-mark"
      assert html =~ "<span"
    end

    test "uses default size-4 class" do
      html = render_component(&icon/1, name: "hero-check")
      assert html =~ "size-4"
    end
  end

  describe "flash/1" do
    test "renders alert with info message from flash map" do
      html =
        render_component(&flash/1,
          kind: :info,
          flash: %{"info" => "Operation successful"},
          title: nil,
          rest: %{}
        )

      assert html =~ "Operation successful"
      assert html =~ ~s(role="alert")
    end

    test "renders alert with error message from flash map" do
      html =
        render_component(&flash/1,
          kind: :error,
          flash: %{"error" => "Something went wrong"},
          title: nil,
          rest: %{}
        )

      assert html =~ "Something went wrong"
    end

    test "renders nothing when flash map is empty" do
      html =
        render_component(&flash/1,
          kind: :info,
          flash: %{},
          title: nil,
          rest: %{}
        )

      refute html =~ ~s(role="alert")
    end

    test "renders title when provided" do
      html =
        render_component(&flash/1,
          kind: :info,
          flash: %{"info" => "Done"},
          title: "Success",
          rest: %{}
        )

      assert html =~ "Success"
    end
  end

  # ---------------------------------------------------------------------------
  # Component rendering — slot-bearing components via ~H sigil
  # ---------------------------------------------------------------------------

  describe "button/1" do
    test "renders a button element by default" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.button>Click me</.button>
        """)

      assert html =~ "<button"
      assert html =~ "Click me"
    end

    test "renders a link element when navigate is set" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.button navigate="/">Home</.button>
        """)

      assert html =~ "<a"
      assert html =~ "Home"
    end

    test "applies primary variant class" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.button variant="primary">Go</.button>
        """)

      assert html =~ "btn-primary"
    end

    test "soft variant used when no variant given" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.button>Default</.button>
        """)

      assert html =~ "btn-soft"
    end
  end

  describe "header/1" do
    test "renders h1 with title" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.header>Page Title</.header>
        """)

      assert html =~ "<h1"
      assert html =~ "Page Title"
    end

    test "renders subtitle when provided" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.header>
          My Title
          <:subtitle>Some subtitle</:subtitle>
        </.header>
        """)

      assert html =~ "Some subtitle"
    end
  end

  describe "input/1 text variant" do
    test "renders an input element with label" do
      html =
        render_component(&input/1,
          type: "text",
          name: "username",
          id: "username",
          value: "",
          label: "Username",
          errors: []
        )

      assert html =~ ~s(type="text")
      assert html =~ "Username"
    end

    test "renders error message when errors present" do
      html =
        render_component(&input/1,
          type: "text",
          name: "username",
          id: "username",
          value: "",
          label: "Username",
          errors: ["can't be blank"]
        )

      assert html =~ "can&#39;t be blank"
    end
  end

  describe "input/1 hidden variant" do
    test "renders a hidden input" do
      html =
        render_component(&input/1,
          type: "hidden",
          name: "csrf",
          id: "csrf",
          value: "token123",
          errors: []
        )

      assert html =~ ~s(type="hidden")
      assert html =~ "token123"
    end
  end

  describe "input/1 checkbox variant" do
    test "renders a checkbox input" do
      html =
        render_component(&input/1,
          type: "checkbox",
          name: "agree",
          id: "agree",
          value: false,
          label: "I agree",
          errors: []
        )

      assert html =~ ~s(type="checkbox")
      assert html =~ "I agree"
    end
  end

  describe "input/1 select variant" do
    test "renders a select element with options" do
      html =
        render_component(&input/1,
          type: "select",
          name: "color",
          id: "color",
          value: "red",
          label: "Color",
          options: [{"Red", "red"}, {"Blue", "blue"}],
          multiple: false,
          prompt: nil,
          errors: []
        )

      assert html =~ "<select"
      assert html =~ "Red"
    end

    test "renders prompt option when provided" do
      html =
        render_component(&input/1,
          type: "select",
          name: "color",
          id: "color",
          value: nil,
          label: "Color",
          options: [{"Red", "red"}],
          multiple: false,
          prompt: "Choose...",
          errors: []
        )

      assert html =~ "Choose..."
    end
  end

  describe "input/1 textarea variant" do
    test "renders a textarea element" do
      html =
        render_component(&input/1,
          type: "textarea",
          name: "body",
          id: "body",
          value: "Hello",
          label: "Message",
          errors: []
        )

      assert html =~ "<textarea"
      assert html =~ "Message"
    end
  end

  describe "table/1" do
    test "renders a table with column headers and rows" do
      assigns = %{rows: [%{id: 1, name: "Alice"}, %{id: 2, name: "Bob"}]}

      html =
        rendered_to_string(~H"""
        <.table id="users" rows={@rows}>
          <:col :let={u} label="Name">{u.name}</:col>
        </.table>
        """)

      assert html =~ "<table"
      assert html =~ "Name"
      assert html =~ "Alice"
      assert html =~ "Bob"
    end

    test "renders action column when action slot is provided" do
      assigns = %{rows: [%{id: 1, name: "Alice"}]}

      html =
        rendered_to_string(~H"""
        <.table id="users" rows={@rows}>
          <:col :let={u} label="Name">{u.name}</:col>
          <:action :let={u}>
            <span>Edit {u.name}</span>
          </:action>
        </.table>
        """)

      assert html =~ "Edit Alice"
    end
  end

  describe "list/1" do
    test "renders an unordered list with items" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.list>
          <:item title="Name">Alice</:item>
          <:item title="Role">Admin</:item>
        </.list>
        """)

      assert html =~ "<ul"
      assert html =~ "Alice"
      assert html =~ "Name"
      assert html =~ "Admin"
    end
  end
end
