defmodule JuntosWeb.TictactoeLiveTest do
  use JuntosWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "mount" do
    test "renders empty board with X to play", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/tictactoe")

      assert html =~ "TicTacToe"
      assert %{board: board, current_player: "x", status: :playing, winner: nil} =
               get_assigns(view)

      assert board == List.duplicate(nil, 9)
    end
  end

  describe "move event" do
    test "places mark and switches player", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/tictactoe")

      render_hook(view, "move", %{"index" => 0})
      assigns = get_assigns(view)

      assert Enum.at(assigns.board, 0) == "x"
      assert assigns.current_player == "o"
    end

    test "alternates between x and o", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/tictactoe")

      render_hook(view, "move", %{"index" => 0})
      render_hook(view, "move", %{"index" => 1})
      assigns = get_assigns(view)

      assert Enum.at(assigns.board, 0) == "x"
      assert Enum.at(assigns.board, 1) == "o"
      assert assigns.current_player == "x"
    end

    test "ignores move on occupied cell", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/tictactoe")

      render_hook(view, "move", %{"index" => 0})
      render_hook(view, "move", %{"index" => 0})
      assigns = get_assigns(view)

      assert Enum.at(assigns.board, 0) == "x"
      assert assigns.current_player == "o"
    end

    test "detects a winner (top row)", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/tictactoe")

      # X: 0, O: 3, X: 1, O: 4, X: 2 -> X wins top row
      render_hook(view, "move", %{"index" => 0})
      render_hook(view, "move", %{"index" => 3})
      render_hook(view, "move", %{"index" => 1})
      render_hook(view, "move", %{"index" => 4})
      render_hook(view, "move", %{"index" => 2})

      assigns = get_assigns(view)
      assert assigns.status == :won
      assert assigns.winner == "x"
    end

    test "detects a draw", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/tictactoe")

      # X O X
      # X X O
      # O X O
      moves = [0, 1, 2, 4, 3, 6, 5, 8, 7]
      Enum.each(moves, &render_hook(view, "move", %{"index" => &1}))

      # Verify: board should look like:
      # x o x
      # x x o
      # o x o
      assigns = get_assigns(view)
      assert assigns.status == :draw
      assert assigns.winner == nil
    end

    test "ignores moves after game is won", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/tictactoe")

      # X wins top row
      render_hook(view, "move", %{"index" => 0})
      render_hook(view, "move", %{"index" => 3})
      render_hook(view, "move", %{"index" => 1})
      render_hook(view, "move", %{"index" => 4})
      render_hook(view, "move", %{"index" => 2})

      # Try another move after win
      render_hook(view, "move", %{"index" => 5})
      assigns = get_assigns(view)

      assert Enum.at(assigns.board, 5) == nil
      assert assigns.status == :won
    end
  end

  describe "reset event" do
    test "resets to initial state after a game", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/tictactoe")

      render_hook(view, "move", %{"index" => 0})
      render_hook(view, "move", %{"index" => 1})
      render_hook(view, "reset", %{})

      assigns = get_assigns(view)
      assert assigns.board == List.duplicate(nil, 9)
      assert assigns.current_player == "x"
      assert assigns.status == :playing
      assert assigns.winner == nil
    end
  end

  defp get_assigns(view) do
    %{
      board: :sys.get_state(view.pid).socket.assigns.board,
      current_player: :sys.get_state(view.pid).socket.assigns.current_player,
      status: :sys.get_state(view.pid).socket.assigns.status,
      winner: :sys.get_state(view.pid).socket.assigns.winner
    }
  end
end
