<template>
  <div>
    <!-- Section nav -->
    <nav
      class="border-b border-stone-200 dark:border-stone-700/60 px-4 sm:px-6 overflow-x-auto"
      aria-label="Conference sections"
    >
      <div class="max-w-4xl mx-auto flex gap-0.5 min-w-max sm:min-w-0">
        <button
          v-for="sec in sections"
          :key="sec.value"
          @click="activeSection = sec.value"
          :class="[
            'px-4 py-3.5 text-sm font-medium border-b-2 transition-colors whitespace-nowrap',
            activeSection === sec.value
              ? 'border-brand-700 dark:border-brand-400 text-brand-800 dark:text-brand-400'
              : 'border-transparent text-stone-500 dark:text-stone-400 hover:text-stone-800 dark:hover:text-stone-200 hover:border-stone-300 dark:hover:border-stone-600'
          ]"
          :aria-current="activeSection === sec.value ? 'page' : undefined"
        >
          {{ sec.label }}
        </button>
      </div>
    </nav>

    <!-- Overview -->
    <div v-if="activeSection === 'overview'" class="px-4 sm:px-6 py-10">
      <div class="max-w-4xl mx-auto space-y-6">

        <!-- Key dates -->
        <div v-if="hasAnyDate" class="glass-card p-6">
          <h2 class="text-xs font-semibold uppercase tracking-widest text-stone-400 dark:text-stone-500 mb-4">Key Dates</h2>
          <div class="grid sm:grid-cols-2 gap-4">
            <div v-if="conferenceInfo.starts_at" class="flex items-start gap-3">
              <div class="w-8 h-8 rounded-lg bg-brand-50 dark:bg-brand-950/60 flex items-center justify-center flex-shrink-0">
                <span class="hero-calendar-days size-4 text-brand-700 dark:text-brand-400"></span>
              </div>
              <div>
                <p class="text-xs text-stone-400 dark:text-stone-500 mb-0.5">Conference</p>
                <p class="text-sm font-medium text-stone-900 dark:text-stone-100">
                  {{ conferenceInfo.starts_at }}<span v-if="conferenceInfo.ends_at && conferenceInfo.ends_at !== conferenceInfo.starts_at"> – {{ conferenceInfo.ends_at }}</span>
                </p>
              </div>
            </div>
            <div v-if="conferenceInfo.location" class="flex items-start gap-3">
              <div class="w-8 h-8 rounded-lg bg-brand-50 dark:bg-brand-950/60 flex items-center justify-center flex-shrink-0">
                <span class="hero-map-pin size-4 text-brand-700 dark:text-brand-400"></span>
              </div>
              <div>
                <p class="text-xs text-stone-400 dark:text-stone-500 mb-0.5">Location</p>
                <p class="text-sm font-medium text-stone-900 dark:text-stone-100">{{ conferenceInfo.location }}</p>
              </div>
            </div>
            <div v-if="conferenceInfo.cfp_opens_at" class="flex items-start gap-3">
              <div class="w-8 h-8 rounded-lg bg-action-50 dark:bg-action-500/10 flex items-center justify-center flex-shrink-0">
                <span class="hero-megaphone size-4 text-action-600 dark:text-action-400"></span>
              </div>
              <div>
                <p class="text-xs text-stone-400 dark:text-stone-500 mb-0.5">CFP Opens</p>
                <p class="text-sm font-medium text-stone-900 dark:text-stone-100">{{ conferenceInfo.cfp_opens_at }}</p>
              </div>
            </div>
            <div v-if="conferenceInfo.cfp_closes_at" class="flex items-start gap-3">
              <div class="w-8 h-8 rounded-lg bg-action-50 dark:bg-action-500/10 flex items-center justify-center flex-shrink-0">
                <span class="hero-clock size-4 text-action-600 dark:text-action-400"></span>
              </div>
              <div>
                <p class="text-xs text-stone-400 dark:text-stone-500 mb-0.5">CFP Closes</p>
                <p class="text-sm font-medium text-stone-900 dark:text-stone-100">{{ conferenceInfo.cfp_closes_at }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Quick stats -->
        <div v-if="hasStats" class="grid grid-cols-3 gap-3">
          <div v-if="speakers.length > 0" class="glass-card p-4 text-center">
            <p class="text-2xl font-bold text-stone-900 dark:text-stone-100">{{ speakers.length }}</p>
            <p class="text-xs text-stone-400 dark:text-stone-500 mt-1">Speaker{{ speakers.length !== 1 ? 's' : '' }}</p>
          </div>
          <div v-if="sessions.length > 0" class="glass-card p-4 text-center">
            <p class="text-2xl font-bold text-stone-900 dark:text-stone-100">{{ sessions.length }}</p>
            <p class="text-xs text-stone-400 dark:text-stone-500 mt-1">Session{{ sessions.length !== 1 ? 's' : '' }}</p>
          </div>
          <div v-if="ticket_tiers.length > 0" class="glass-card p-4 text-center">
            <p class="text-2xl font-bold text-stone-900 dark:text-stone-100">{{ ticketPriceRange }}</p>
            <p class="text-xs text-stone-400 dark:text-stone-500 mt-1">Tickets</p>
          </div>
        </div>

        <!-- Organizer -->
        <div v-if="organizer" class="glass-card p-6 flex items-start gap-4">
          <div
            class="w-12 h-12 rounded-full bg-brand-50 dark:bg-brand-950/60 flex items-center justify-center text-brand-800 dark:text-brand-400 font-semibold text-lg flex-shrink-0"
          >
            {{ initials(organizer.name) }}
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-xs uppercase tracking-widest text-stone-400 dark:text-stone-500 mb-1 font-medium">Organizer</p>
            <p class="font-semibold text-stone-900 dark:text-stone-100">{{ organizer.name }}</p>
            <p v-if="organizer.bio" class="text-sm text-stone-500 dark:text-stone-400 mt-1.5 leading-relaxed">{{ organizer.bio }}</p>
          </div>
        </div>

        <!-- CTAs -->
        <div class="flex flex-wrap gap-3 pt-2">
          <button
            v-if="sessions.length > 0"
            @click="activeSection = 'schedule'"
            class="btn-ghost !py-2 !px-4 !text-sm"
          >
            View schedule <span aria-hidden="true">→</span>
          </button>
          <button
            v-if="ticket_tiers.length > 0"
            @click="activeSection = 'tickets'"
            class="btn-primary !py-2 !px-4 !text-sm"
          >
            Get tickets <span aria-hidden="true">→</span>
          </button>
        </div>

      </div>
    </div>

    <!-- Schedule -->
    <div v-else-if="activeSection === 'schedule'" class="px-4 sm:px-6 py-10">
      <div class="max-w-4xl mx-auto">
        <div v-if="days.length === 0" class="text-center py-16">
          <span class="hero-calendar size-8 mx-auto mb-3 block text-stone-300 dark:text-stone-600"></span>
          <p class="text-stone-400 dark:text-stone-500">Schedule not yet published.</p>
        </div>
        <template v-else>
          <!-- Day tabs -->
          <div v-if="days.length > 1" class="flex gap-2 mb-8" role="tablist" aria-label="Conference days">
            <button
              v-for="day in days"
              :key="day"
              @click="activeDay = day"
              :class="[
                'px-4 py-1.5 rounded-full text-sm font-medium transition-all duration-150',
                activeDay === day
                  ? 'bg-brand-900 dark:bg-brand-400 text-white dark:text-brand-950 shadow-sm'
                  : 'bg-stone-100 dark:bg-stone-800 text-stone-600 dark:text-stone-300 hover:bg-stone-200 dark:hover:bg-stone-700'
              ]"
              :aria-selected="activeDay === day"
              role="tab"
            >
              Day {{ day }}
            </button>
          </div>

          <div class="space-y-2.5">
            <div
              v-for="session in daySessions"
              :key="session.id"
              :class="[
                'glass-card p-5 flex gap-5',
                session.session_type === 'break' ? 'opacity-50' : ''
              ]"
            >
              <div class="w-16 flex-shrink-0 text-sm text-stone-400 dark:text-stone-500 pt-0.5 tabular-nums">
                {{ session.starts_at || '' }}
              </div>
              <div class="flex-1 min-w-0">
                <div class="flex items-start justify-between gap-3">
                  <h3 class="font-semibold text-stone-900 dark:text-stone-100 leading-snug">{{ session.title }}</h3>
                  <span
                    v-if="session.session_type !== 'talk'"
                    :class="['text-xs px-2.5 py-0.5 rounded-full font-medium flex-shrink-0 capitalize',
                      session.session_type === 'keynote'
                        ? 'bg-brand-50 dark:bg-brand-950/60 text-brand-700 dark:text-brand-400'
                        : session.session_type === 'workshop'
                          ? 'bg-action-50 dark:bg-action-500/10 text-action-600 dark:text-action-400'
                          : 'bg-stone-100 dark:bg-stone-800 text-stone-500 dark:text-stone-400'
                    ]"
                  >
                    {{ session.session_type }}
                  </span>
                </div>
                <p v-if="session.speaker_name" class="text-sm text-stone-500 dark:text-stone-400 mt-1">
                  {{ session.speaker_name }}
                </p>
                <p v-if="session.description" class="text-xs text-stone-400 dark:text-stone-500 mt-1.5 leading-relaxed">
                  {{ session.description }}
                </p>
                <p v-if="session.room" class="text-xs text-stone-400 dark:text-stone-500 mt-1.5 flex items-center gap-1">
                  <span class="hero-map-pin size-3 opacity-60"></span>
                  {{ session.room }}
                </p>
              </div>
            </div>
          </div>
        </template>
      </div>
    </div>

    <!-- Speakers -->
    <div v-else-if="activeSection === 'speakers'" class="px-4 sm:px-6 py-10">
      <div class="max-w-4xl mx-auto">
        <div v-if="speakers.length === 0" class="text-center py-16">
          <span class="hero-user-group size-8 mx-auto mb-3 block text-stone-300 dark:text-stone-600"></span>
          <p class="text-stone-400 dark:text-stone-500">Speakers will be announced soon.</p>
        </div>
        <div v-else class="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <button
            v-for="speaker in speakers"
            :key="speaker.name"
            @click="toggleSpeaker(speaker.name)"
            :class="[
              'glass-card p-6 text-left transition-all duration-200 w-full',
              expandedSpeakers.has(speaker.name)
                ? 'ring-2 ring-brand-700/40 dark:ring-brand-400/30'
                : 'hover:-translate-y-0.5'
            ]"
          >
            <div class="flex items-start gap-4">
              <div class="w-12 h-12 rounded-full bg-brand-50 dark:bg-brand-950/60 flex items-center justify-center text-brand-800 dark:text-brand-400 font-semibold text-lg flex-shrink-0">
                {{ initials(speaker.name) }}
              </div>
              <div class="flex-1 min-w-0">
                <p class="font-semibold text-stone-900 dark:text-stone-100 leading-snug">{{ speaker.name }}</p>
                <p v-if="speaker.sessionTitle" class="text-xs text-brand-700 dark:text-brand-400 mt-0.5 truncate">{{ speaker.sessionTitle }}</p>
                <p
                  v-if="speaker.bio"
                  :class="[
                    'text-sm text-stone-500 dark:text-stone-400 mt-2 leading-relaxed',
                    expandedSpeakers.has(speaker.name) ? '' : 'line-clamp-2'
                  ]"
                >
                  {{ speaker.bio }}
                </p>
                <p v-if="!speaker.bio" class="text-xs text-stone-400 dark:text-stone-500 mt-1">No bio available</p>
                <p v-if="speaker.bio" class="text-xs text-brand-700 dark:text-brand-400 mt-2 font-medium">
                  {{ expandedSpeakers.has(speaker.name) ? 'Show less ↑' : 'Read more ↓' }}
                </p>
              </div>
            </div>
          </button>
        </div>
      </div>
    </div>

    <!-- Tickets -->
    <div v-else-if="activeSection === 'tickets'" class="px-4 sm:px-6 py-10">
      <div class="max-w-4xl mx-auto">
        <div v-if="ticket_tiers.length === 0" class="text-center py-16">
          <span class="hero-ticket size-8 mx-auto mb-3 block text-stone-300 dark:text-stone-600"></span>
          <p class="text-stone-400 dark:text-stone-500">Tickets not yet available.</p>
        </div>
        <div v-else class="grid sm:grid-cols-2 gap-5">
          <div
            v-for="tier in ticket_tiers"
            :key="tier.id"
            class="glass-card p-6 flex flex-col"
          >
            <div class="flex-1">
              <h3 class="font-semibold text-stone-900 dark:text-stone-100 text-lg">{{ tier.name }}</h3>
              <p v-if="tier.description" class="text-sm text-stone-500 dark:text-stone-400 mt-1.5 leading-relaxed">{{ tier.description }}</p>
            </div>
            <div class="mt-5 pt-4 border-t border-stone-100 dark:border-stone-700/60 flex items-center justify-between">
              <div>
                <span class="text-2xl font-bold text-stone-900 dark:text-stone-100">
                  {{ tier.price_cents === 0 ? 'Free' : `$${(tier.price_cents / 100).toFixed(0)}` }}
                </span>
                <span v-if="tier.quantity > 0" class="text-xs text-stone-400 dark:text-stone-500 ml-2">
                  {{ tier.quantity - tier.sold_count }} left
                </span>
              </div>
              <button
                @click="emit('get_ticket', { tier_id: tier.id })"
                :disabled="tier.sold_count >= tier.quantity && tier.quantity > 0"
                :class="[
                  'btn-primary !py-2 !px-4 !text-xs',
                  tier.sold_count >= tier.quantity && tier.quantity > 0
                    ? 'opacity-40 cursor-not-allowed hover:transform-none'
                    : ''
                ]"
              >
                {{ tier.sold_count >= tier.quantity && tier.quantity > 0 ? 'Sold out' : 'Get ticket' }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, reactive } from 'vue'
import { useLiveVue } from 'live_vue'

const emit = useLiveVue()

const props = defineProps({
  sessions:        { type: Array,  default: () => [] },
  ticket_tiers:    { type: Array,  default: () => [] },
  organizer:       { type: Object, default: null },
  conference_info: { type: Object, default: null }
})

const activeSection = ref('overview')
const activeDay     = ref(1)
const expandedSpeakers = reactive(new Set())

function toggleSpeaker(name) {
  if (expandedSpeakers.has(name)) {
    expandedSpeakers.delete(name)
  } else {
    expandedSpeakers.add(name)
  }
}

const days = computed(() => {
  return [...new Set(props.sessions.map(s => s.day_number))].sort()
})

const daySessions = computed(() => {
  return props.sessions
    .filter(s => s.day_number === activeDay.value)
    .sort((a, b) => a.position - b.position)
})

const speakers = computed(() => {
  const seen = new Set()
  return props.sessions
    .filter(s => s.speaker_name && !seen.has(s.speaker_name) && seen.add(s.speaker_name))
    .map(s => ({ name: s.speaker_name, bio: s.speaker_bio, sessionTitle: s.title }))
})

const ticketPriceRange = computed(() => {
  if (!props.ticket_tiers.length) return ''
  const prices = props.ticket_tiers.map(t => t.price_cents)
  const min = Math.min(...prices)
  const max = Math.max(...prices)
  if (min === 0 && max === 0) return 'Free'
  if (min === max) return min === 0 ? 'Free' : `$${(min / 100).toFixed(0)}`
  return `$${(min / 100).toFixed(0)}–$${(max / 100).toFixed(0)}`
})

const conferenceInfo = computed(() => props.conference_info || {})

const hasAnyDate = computed(() =>
  conferenceInfo.value.starts_at ||
  conferenceInfo.value.cfp_opens_at ||
  conferenceInfo.value.cfp_closes_at ||
  conferenceInfo.value.location
)

const hasStats = computed(() =>
  speakers.value.length > 0 ||
  props.sessions.length > 0 ||
  props.ticket_tiers.length > 0
)

function initials(name) {
  if (!name) return '?'
  return name.split(' ').map(p => p[0]).join('').slice(0, 2).toUpperCase()
}

const sections = [
  { value: 'overview', label: 'Overview' },
  { value: 'schedule', label: 'Schedule' },
  { value: 'speakers', label: 'Speakers' },
  { value: 'tickets',  label: 'Tickets' }
]
</script>
