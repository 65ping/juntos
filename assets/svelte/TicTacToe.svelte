<script>
  let { board = [], current_player = "x", status = "playing", winner = null, live } = $props();

  function handleMove(index) {
    if (status !== "playing" || board[index] != null) return;
    live.pushEvent("move", { index });
  }

  function handleReset() {
    live.pushEvent("reset", {});
  }

  function statusMessage() {
    if (status === "won") return `🎉 Player ${winner.toUpperCase()} wins!`;
    if (status === "draw") return "🤝 It's a draw!";
    return `Player ${current_player.toUpperCase()}'s turn`;
  }

  function cellDisplay(value) {
    if (value === "x") return "✕";
    if (value === "o") return "○";
    return "";
  }
</script>

<div class="game-container">
  <h1>Tic-Tac-Toe</h1>

  <p class="status" class:won={status === "won"} class:draw={status === "draw"}>
    {statusMessage()}
  </p>

  <div class="board">
    {#each board as cell, i}
      <button
        class="cell"
        class:x={cell === "x"}
        class:o={cell === "o"}
        class:disabled={status !== "playing" || cell != null}
        onclick={() => handleMove(i)}
      >
        {cellDisplay(cell)}
      </button>
    {/each}
  </div>

  {#if status !== "playing"}
    <button class="reset-btn" onclick={handleReset}>
      Play Again
    </button>
  {/if}
</div>

<style>
  .game-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 2rem;
    font-family: system-ui, -apple-system, sans-serif;
  }

  h1 {
    font-size: 2rem;
    margin-bottom: 1rem;
    color: #1a1a2e;
  }

  .status {
    font-size: 1.25rem;
    margin-bottom: 1.5rem;
    font-weight: 600;
    color: #555;
  }

  .status.won {
    color: #16a34a;
  }

  .status.draw {
    color: #d97706;
  }

  .board {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 6px;
    background: #334155;
    padding: 6px;
    border-radius: 12px;
  }

  .cell {
    width: 100px;
    height: 100px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 2.5rem;
    font-weight: 700;
    background: #f8fafc;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    transition: background-color 0.15s;
  }

  .cell:hover:not(.disabled) {
    background: #e2e8f0;
  }

  .cell.disabled {
    cursor: default;
  }

  .cell.x {
    color: #2563eb;
  }

  .cell.o {
    color: #dc2626;
  }

  .reset-btn {
    margin-top: 1.5rem;
    padding: 0.75rem 2rem;
    font-size: 1.1rem;
    font-weight: 600;
    color: white;
    background: #2563eb;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    transition: background-color 0.15s;
  }

  .reset-btn:hover {
    background: #1d4ed8;
  }
</style>
