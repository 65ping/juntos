defmodule JuntosWeb.TictactoeLive do
  use JuntosWeb, :live_view

  import LiveSvelte

  @winning_lines [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6]
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, initial_state())}
  end

  @impl true
  def handle_event("move", %{"index" => index}, socket) do
    index = String.to_integer("#{index}")
    board = socket.assigns.board

    if socket.assigns.status == :playing and Enum.at(board, index) == nil do
      player = socket.assigns.current_player
      new_board = List.replace_at(board, index, player)

      socket =
        case check_winner(new_board) do
          {:winner, winner} ->
            assign(socket, board: new_board, status: :won, winner: winner)

          :draw ->
            assign(socket, board: new_board, status: :draw)

          :playing ->
            next_player = if player == "x", do: "o", else: "x"
            assign(socket, board: new_board, current_player: next_player)
        end

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket, initial_state())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.svelte
      name="TicTacToe"
      props={
        %{
          board: @board,
          current_player: @current_player,
          status: Atom.to_string(@status),
          winner: @winner
        }
      }
      socket={@socket}
    />
    """
  end

  defp initial_state do
    %{
      board: List.duplicate(nil, 9),
      current_player: "x",
      status: :playing,
      winner: nil
    }
  end

  defp check_winner(board) do
    winner =
      Enum.find_value(@winning_lines, fn [a, b, c] ->
        va = Enum.at(board, a)
        vb = Enum.at(board, b)
        vc = Enum.at(board, c)

        if va != nil and va == vb and vb == vc, do: va
      end)

    cond do
      winner != nil -> {:winner, winner}
      Enum.all?(board, &(&1 != nil)) -> :draw
      true -> :playing
    end
  end
end
