<script setup>
import { computed } from 'vue'
import { useLiveVue } from 'live_vue'

const props = defineProps({
  ticket_tiers: { type: Array, default: () => [] }
})

const live = useLiveVue()

function formatPrice(cents) {
  if (cents === 0) return 'Free'
  const dollars = Math.floor(cents / 100)
  const remainder = cents % 100
  return remainder === 0 ? `$${dollars}` : `$${dollars}.${String(remainder).padStart(2, '0')}`
}

const gridClass = computed(() => {
  const count = props.ticket_tiers.length
  if (count === 1) return 'max-w-sm mx-auto'
  if (count === 2) return 'sm:grid-cols-2 max-w-2xl mx-auto'
  return 'sm:grid-cols-3'
})

function remainingCount(tier) {
  return tier.quantity !== null ? tier.quantity - tier.sold_count : null
}

function isSoldOut(tier) {
  const remaining = remainingCount(tier)
  return remaining !== null && remaining <= 0
}

function handleGetTicket(tierId) {
  live.pushEvent('get_ticket', { tier_id: tierId })
}
</script>

<template>
  <section class="px-6 py-16 sm:py-20">
    <div class="max-w-4xl mx-auto">
      <h2
        style="font-family: var(--font-display);"
        class="text-3xl text-stone-900 dark:text-stone-100 text-center mb-10"
      >
        Tickets
      </h2>

      <div :class="['grid gap-6', gridClass]">
        <div
          v-for="tier in ticket_tiers"
          :key="tier.id"
          class="glass-card p-6 flex flex-col gap-4"
        >
          <div>
            <h3 class="text-lg font-semibold text-stone-900 dark:text-stone-100">{{ tier.name }}</h3>
            <p v-if="tier.description" class="text-sm text-stone-500 dark:text-stone-400 mt-1">
              {{ tier.description }}
            </p>
          </div>

          <div class="mt-auto">
            <p style="font-family: var(--font-display);" class="text-3xl text-stone-900 dark:text-stone-100">
              {{ formatPrice(tier.price_cents) }}
            </p>

            <p v-if="remainingCount(tier) !== null" class="text-xs text-stone-400 dark:text-stone-500 mt-1">
              {{ remainingCount(tier) }} remaining
            </p>

            <button
              @click="handleGetTicket(tier.id)"
              :disabled="isSoldOut(tier)"
              class="mt-4 w-full px-4 py-2.5 text-sm font-medium text-white bg-amber-600 hover:bg-amber-500 rounded-lg shadow-sm transition-all hover:-translate-y-px disabled:opacity-60 disabled:cursor-not-allowed disabled:hover:translate-y-0"
            >
              {{ isSoldOut(tier) ? 'Sold out' : 'Get ticket' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
