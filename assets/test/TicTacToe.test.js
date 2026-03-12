import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/svelte";
import TicTacToe from "../svelte/TicTacToe.svelte";

function mockLive() {
  return {
    pushEvent: vi.fn(),
  };
}

function defaultProps(overrides = {}) {
  return {
    board: [null, null, null, null, null, null, null, null, null],
    current_player: "x",
    status: "playing",
    winner: null,
    live: mockLive(),
    ...overrides,
  };
}

describe("TicTacToe", () => {
  it("renders a 3x3 grid of cells", () => {
    const props = defaultProps();
    render(TicTacToe, { props });

    const cells = screen.getAllByRole("button", { name: "" });
    // 9 empty cells
    expect(cells.length).toBe(9);
  });

  it("displays current player turn", () => {
    render(TicTacToe, { props: defaultProps() });

    expect(screen.getByText("Player X's turn")).toBeInTheDocument();
  });

  it("displays player O turn", () => {
    render(TicTacToe, {
      props: defaultProps({ current_player: "o" }),
    });

    expect(screen.getByText("Player O's turn")).toBeInTheDocument();
  });

  it("pushes move event when clicking empty cell", async () => {
    const props = defaultProps();
    render(TicTacToe, { props });

    const cells = screen.getAllByRole("button");
    await fireEvent.click(cells[4]); // center cell

    expect(props.live.pushEvent).toHaveBeenCalledWith("move", { index: 4 });
  });

  it("does not push event when clicking occupied cell", async () => {
    const props = defaultProps({
      board: ["x", null, null, null, null, null, null, null, null],
    });
    render(TicTacToe, { props });

    const cells = screen.getAllByRole("button");
    await fireEvent.click(cells[0]); // occupied cell

    expect(props.live.pushEvent).not.toHaveBeenCalled();
  });

  it("displays marks on the board", () => {
    render(TicTacToe, {
      props: defaultProps({
        board: ["x", "o", null, null, null, null, null, null, null],
      }),
    });

    expect(screen.getByText("✕")).toBeInTheDocument();
    expect(screen.getByText("○")).toBeInTheDocument();
  });

  it("shows winner message", () => {
    render(TicTacToe, {
      props: defaultProps({
        status: "won",
        winner: "x",
        board: ["x", "x", "x", "o", "o", null, null, null, null],
      }),
    });

    expect(screen.getByText(/Player X wins/)).toBeInTheDocument();
  });

  it("shows draw message", () => {
    render(TicTacToe, {
      props: defaultProps({
        status: "draw",
        board: ["x", "o", "x", "x", "x", "o", "o", "x", "o"],
      }),
    });

    expect(screen.getByText(/draw/i)).toBeInTheDocument();
  });

  it("shows Play Again button when game is over", () => {
    render(TicTacToe, {
      props: defaultProps({ status: "won", winner: "x" }),
    });

    expect(screen.getByText("Play Again")).toBeInTheDocument();
  });

  it("does not show Play Again button during play", () => {
    render(TicTacToe, { props: defaultProps() });

    expect(screen.queryByText("Play Again")).not.toBeInTheDocument();
  });

  it("pushes reset event when clicking Play Again", async () => {
    const props = defaultProps({ status: "won", winner: "x" });
    render(TicTacToe, { props });

    await fireEvent.click(screen.getByText("Play Again"));

    expect(props.live.pushEvent).toHaveBeenCalledWith("reset", {});
  });

  it("does not push move when game is won", async () => {
    const props = defaultProps({
      status: "won",
      winner: "x",
      board: ["x", "x", "x", "o", "o", null, null, null, null],
    });
    render(TicTacToe, { props });

    const cells = screen.getAllByRole("button");
    // Click an empty cell - should not fire because game is over
    await fireEvent.click(cells[5]);

    expect(props.live.pushEvent).not.toHaveBeenCalledWith(
      "move",
      expect.anything()
    );
  });
});
