import { describe, it, expect, vi } from "vitest";
import { mount } from "@vue/test-utils";
import TicTacToe from "../vue/TicTacToe.vue";

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
    ...overrides,
  };
}

function mountComponent(props = {}, live = mockLive()) {
  return mount(TicTacToe, {
    props: defaultProps(props),
    global: {
      provide: {
        _live_vue: live,
      },
    },
  });
}

describe("TicTacToe", () => {
  it("renders a 3x3 grid of cells", () => {
    const wrapper = mountComponent();

    const cells = wrapper.findAll(".cell");
    expect(cells.length).toBe(9);
  });

  it("displays current player turn", () => {
    const wrapper = mountComponent();

    expect(wrapper.text()).toContain("Player X's turn");
  });

  it("displays player O turn", () => {
    const wrapper = mountComponent({ current_player: "o" });

    expect(wrapper.text()).toContain("Player O's turn");
  });

  it("pushes move event when clicking empty cell", async () => {
    const live = mockLive();
    const wrapper = mountComponent({}, live);

    const cells = wrapper.findAll(".cell");
    await cells[4].trigger("click"); // center cell

    expect(live.pushEvent).toHaveBeenCalledWith("move", { index: 4 });
  });

  it("does not push event when clicking occupied cell", async () => {
    const live = mockLive();
    const wrapper = mountComponent({
      board: ["x", null, null, null, null, null, null, null, null],
    }, live);

    const cells = wrapper.findAll(".cell");
    await cells[0].trigger("click"); // occupied cell

    expect(live.pushEvent).not.toHaveBeenCalled();
  });

  it("displays marks on the board", () => {
    const wrapper = mountComponent({
      board: ["x", "o", null, null, null, null, null, null, null],
    });

    expect(wrapper.text()).toContain("✕");
    expect(wrapper.text()).toContain("○");
  });

  it("shows winner message", () => {
    const wrapper = mountComponent({
      status: "won",
      winner: "x",
      board: ["x", "x", "x", "o", "o", null, null, null, null],
    });

    expect(wrapper.text()).toMatch(/Player X wins/);
  });

  it("shows draw message", () => {
    const wrapper = mountComponent({
      status: "draw",
      board: ["x", "o", "x", "x", "x", "o", "o", "x", "o"],
    });

    expect(wrapper.text()).toMatch(/draw/i);
  });

  it("shows Play Again button when game is over", () => {
    const wrapper = mountComponent({ status: "won", winner: "x" });

    expect(wrapper.text()).toContain("Play Again");
  });

  it("does not show Play Again button during play", () => {
    const wrapper = mountComponent();

    expect(wrapper.text()).not.toContain("Play Again");
  });

  it("pushes reset event when clicking Play Again", async () => {
    const live = mockLive();
    const wrapper = mountComponent({ status: "won", winner: "x" }, live);

    await wrapper.find(".reset-btn").trigger("click");

    expect(live.pushEvent).toHaveBeenCalledWith("reset", {});
  });

  it("does not push move when game is won", async () => {
    const live = mockLive();
    const wrapper = mountComponent({
      status: "won",
      winner: "x",
      board: ["x", "x", "x", "o", "o", null, null, null, null],
    }, live);

    const cells = wrapper.findAll(".cell");
    // Click an empty cell - should not fire because game is over
    await cells[5].trigger("click");

    expect(live.pushEvent).not.toHaveBeenCalledWith(
      "move",
      expect.anything()
    );
  });
});
