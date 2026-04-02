<script setup>
import { computed } from 'vue'
import { useLiveVue } from 'live_vue'

const props = defineProps({
  board: { type: Array, default: () => [] },
  current_player: { type: String, default: 'x' },
  status: { type: String, default: 'playing' },
  winner: { type: String, default: null }
})

const live = useLiveVue()

function handleMove(index) {
  if (props.status !== 'playing' || props.board[index] != null) return
  live.pushEvent('move', { index })
}

function handleReset() {
  live.pushEvent('reset', {})
}

const statusMessage = computed(() => {
  if (props.status === 'won') return `🎉 Player ${props.winner.toUpperCase()} wins!`
  if (props.status === 'draw') return "🤝 It's a draw!"
  return `Player ${props.current_player.toUpperCase()}'s turn`
})

function cellDisplay(value) {
  if (value === 'x') return '✕'
  if (value === 'o') return '○'
  return ''
}

function cellClasses(cell) {
  return {
    cell: true,
    x: cell === 'x',
    o: cell === 'o',
    disabled: props.status !== 'playing' || cell != null
  }
}

const statusClasses = computed(() => ({
  status: true,
  won: props.status === 'won',
  draw: props.status === 'draw'
}))
</script>

<template>
  <div class="game-container">
    <h1>Tic-Tac-Toe</h1>

    <p :class="statusClasses">
      {{ statusMessage }}
    </p>

    <div class="board">
      <button
        v-for="(cell, i) in board"
        :key="i"
        :class="cellClasses(cell)"
        @click="handleMove(i)"
      >
        {{ cellDisplay(cell) }}
      </button>
    </div>

    <button v-if="status !== 'playing'" class="reset-btn" @click="handleReset">
      Play Again
    </button>
  </div>
</template>

<style scoped>
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
