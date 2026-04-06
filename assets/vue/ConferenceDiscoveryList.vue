<template>
  <div class="min-h-screen px-6 py-16">
    <div class="max-w-6xl mx-auto">
      <!-- Header -->
      <div class="flex items-start justify-between mb-12 gap-4">
        <div>
          <h1
            class="text-4xl sm:text-5xl text-stone-900 dark:text-stone-100 tracking-tight leading-tight"
            style="font-family: var(--font-display);"
          >
            Conferences
          </h1>
          <p class="mt-2 text-stone-500 dark:text-stone-400">
            Discover events happening on Juntos
          </p>
        </div>
        <a
          href="/"
          class="text-sm font-medium text-stone-500 dark:text-stone-400 hover:text-brand-800 dark:hover:text-brand-400 transition-colors flex-shrink-0 mt-1"
        >
          Running a conference? &rarr;
        </a>
      </div>

      <!-- Filter chips -->
      <div class="flex items-center gap-2 mb-10" role="group" aria-label="Filter conferences">
        <button
          v-for="f in filters"
          :key="f.value"
          @click="activeFilter = f.value"
          :class="[
            'px-4 py-1.5 rounded-full text-sm font-medium transition-all duration-150',
            activeFilter === f.value
              ? 'bg-brand-900 dark:bg-brand-400 text-white dark:text-brand-950 shadow-sm'
              : 'bg-stone-100 dark:bg-stone-800 text-stone-600 dark:text-stone-300 hover:bg-stone-200 dark:hover:bg-stone-700'
          ]"
          :aria-pressed="activeFilter === f.value"
        >
          {{ f.label }}
        </button>
      </div>

      <!-- Grid -->
      <div v-if="filtered.length > 0" class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
        <a
          v-for="conf in filtered"
          :key="conf.id"
          :href="`/${conf.slug}`"
          class="glass-card p-6 group hover:-translate-y-1 transition-all duration-200 hover:shadow-lg block focus-visible:outline-2 focus-visible:outline-action-500 focus-visible:outline-offset-2"
        >
          <div class="flex items-start justify-between mb-4">
            <span :class="['status-badge', statusClass(conf.status)]">
              {{ statusLabel(conf.status) }}
            </span>
            <span class="text-sm font-semibold text-stone-600 dark:text-stone-300">
              {{ priceLabel(conf) }}
            </span>
          </div>

          <h2 class="text-lg font-semibold text-stone-900 dark:text-stone-100 mb-1 group-hover:text-brand-800 dark:group-hover:text-brand-400 transition-colors leading-snug">
            {{ conf.name }}
          </h2>

          <div class="space-y-1 mt-3 text-sm text-stone-500 dark:text-stone-400">
            <p v-if="conf.location" class="flex items-center gap-1.5">
              <span class="hero-map-pin size-3.5 flex-shrink-0 opacity-60"></span>
              {{ conf.location }}
            </p>
            <p v-if="conf.starts_at" class="flex items-center gap-1.5">
              <span class="hero-calendar size-3.5 flex-shrink-0 opacity-60"></span>
              {{ conf.starts_at }}<span v-if="conf.ends_at"> – {{ conf.ends_at }}</span>
            </p>
          </div>

          <div v-if="conf.organizer_name" class="mt-4 pt-4 border-t border-stone-100 dark:border-stone-700/60 flex items-center gap-2">
            <div class="w-5 h-5 rounded-full bg-brand-100 dark:bg-brand-950/60 flex items-center justify-center flex-shrink-0">
              <span class="text-[9px] font-bold text-brand-800 dark:text-brand-400">
                {{ conf.organizer_name.charAt(0).toUpperCase() }}
              </span>
            </div>
            <p class="text-xs text-stone-400 dark:text-stone-500">
              {{ conf.organizer_name }}
            </p>
          </div>
        </a>
      </div>

      <!-- Empty state -->
      <div v-else class="text-center py-28">
        <div class="w-14 h-14 mx-auto mb-5 rounded-full bg-stone-100 dark:bg-stone-800 flex items-center justify-center">
          <span class="hero-calendar size-6 text-stone-400 dark:text-stone-500"></span>
        </div>
        <p class="text-lg font-medium text-stone-500 dark:text-stone-400">No conferences found.</p>
        <p class="text-sm text-stone-400 dark:text-stone-500 mt-1">Check back soon — more events are on the way.</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  conferences: { type: Array, default: () => [] }
})

const activeFilter = ref('all')

const filters = [
  { value: 'all', label: 'All' },
  { value: 'cfp_open', label: 'CFP Open' },
  { value: 'scheduled', label: 'Upcoming' },
  { value: 'complete', label: 'Past' }
]

const filtered = computed(() => {
  if (activeFilter.value === 'all') return props.conferences
  return props.conferences.filter(c => c.status === activeFilter.value)
})

function statusClass(status) {
  const map = {
    draft:      'bg-stone-100 dark:bg-stone-800 text-stone-500 dark:text-stone-400',
    cfp_open:   'bg-brand-50 dark:bg-brand-950/60 text-brand-800 dark:text-brand-400',
    cfp_closed: 'bg-stone-100 dark:bg-stone-800 text-stone-600 dark:text-stone-400',
    scheduled:  'bg-action-50 dark:bg-action-500/10 text-action-600 dark:text-action-400',
    complete:   'bg-stone-100 dark:bg-stone-800 text-stone-500 dark:text-stone-400'
  }
  return map[status] || map.draft
}

function statusLabel(status) {
  const map = {
    draft: 'Draft', cfp_open: 'CFP Open', cfp_closed: 'CFP Closed',
    scheduled: 'Upcoming', complete: 'Past'
  }
  return map[status] || status
}

function priceLabel(conf) {
  const { min_price_cents: min, max_price_cents: max } = conf
  if (!min && !max) return 'Free'
  if (min === 0 && max === 0) return 'Free'
  const fmt = cents => `$${(cents / 100).toFixed(0)}`
  if (min === max) return fmt(min)
  return `${fmt(min)}–${fmt(max)}`
}
</script>
