<script setup>
import { ref } from 'vue'
import { useLiveVue } from 'live_vue'

const props = defineProps({
  conferences: { type: Array, default: () => [] }
})

const live = useLiveVue()

const showForm  = ref(false)
const name      = ref('')
const description = ref('')
const location  = ref('')
const startsAt  = ref('')
const submitting = ref(false)

function resetForm() {
  name.value        = ''
  description.value = ''
  location.value    = ''
  startsAt.value    = ''
  showForm.value    = false
  submitting.value  = false
}

function handleSubmit(e) {
  e.preventDefault()
  if (!name.value.trim()) return
  submitting.value = true
  live.pushEvent(
    'create_conference',
    { conference: { name: name.value, description: description.value, location: location.value, starts_at: startsAt.value } },
    () => resetForm()
  )
}

function deleteConference(id, conferenceName) {
  if (!confirm(`Delete "${conferenceName}"? This cannot be undone.`)) return
  live.pushEvent('delete_conference', { id })
}

function statusLabel(status) {
  const labels = {
    draft:      'Draft',
    cfp_open:   'CFP Open',
    cfp_closed: 'CFP Closed',
    scheduled:  'Scheduled',
    complete:   'Complete',
  }
  return labels[status] ?? status
}

function statusClasses(status) {
  const classes = {
    draft:      'bg-stone-100 dark:bg-stone-800 text-stone-500 dark:text-stone-400',
    cfp_open:   'bg-brand-50 dark:bg-brand-950/60 text-brand-800 dark:text-brand-400',
    cfp_closed: 'bg-stone-100 dark:bg-stone-800 text-stone-600 dark:text-stone-400',
    scheduled:  'bg-action-50 dark:bg-action-500/10 text-action-600 dark:text-action-400',
    complete:   'bg-stone-100 dark:bg-stone-800 text-stone-500 dark:text-stone-400',
  }
  return classes[status] ?? 'bg-stone-100 dark:bg-stone-800 text-stone-500 dark:text-stone-400'
}

// Expose for testing
defineExpose({ showForm, name, description, location, startsAt })
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-10">
      <h1
        style="font-family: var(--font-display);"
        class="text-3xl sm:text-4xl text-stone-900 dark:text-stone-100 tracking-tight"
      >
        My Conferences
      </h1>
      <button
        @click="showForm = true"
        class="btn-primary"
        :aria-expanded="showForm"
      >
        New conference <span aria-hidden="true">+</span>
      </button>
    </div>

    <!-- Create form -->
    <div v-if="showForm" class="glass-card p-7 mb-8">
      <div class="flex items-center justify-between mb-6">
        <h2
          style="font-family: var(--font-display);"
          class="text-xl text-stone-900 dark:text-stone-100"
        >
          New Conference
        </h2>
        <button
          @click="resetForm"
          class="p-1.5 text-stone-400 dark:text-stone-500 hover:text-stone-600 dark:hover:text-stone-300 hover:bg-stone-100 dark:hover:bg-stone-800 rounded-lg transition-colors"
          aria-label="Close form"
        >
          <span class="hero-x-mark size-5"></span>
        </button>
      </div>

      <form @submit="handleSubmit">
        <div class="grid gap-4 sm:grid-cols-2">
          <div class="sm:col-span-2">
            <label class="block text-sm font-medium text-stone-700 dark:text-stone-300 mb-1.5" for="conf-name">
              Conference name
            </label>
            <input
              id="conf-name"
              type="text"
              v-model="name"
              placeholder="ElixirConf 2026"
              required
              class="input-field"
            />
          </div>

          <div class="sm:col-span-2">
            <label class="block text-sm font-medium text-stone-700 dark:text-stone-300 mb-1.5" for="conf-desc">
              Description
              <span class="text-stone-400 dark:text-stone-500 font-normal">(optional)</span>
            </label>
            <textarea
              id="conf-desc"
              v-model="description"
              rows="3"
              placeholder="A short description of your conference…"
              class="input-field resize-none"
            ></textarea>
          </div>

          <div>
            <label class="block text-sm font-medium text-stone-700 dark:text-stone-300 mb-1.5" for="conf-location">
              Location
              <span class="text-stone-400 dark:text-stone-500 font-normal">(optional)</span>
            </label>
            <input
              id="conf-location"
              type="text"
              v-model="location"
              placeholder="Austin, TX"
              class="input-field"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-stone-700 dark:text-stone-300 mb-1.5" for="conf-starts">
              Start date
              <span class="text-stone-400 dark:text-stone-500 font-normal">(optional)</span>
            </label>
            <input
              id="conf-starts"
              type="date"
              v-model="startsAt"
              class="input-field"
            />
          </div>
        </div>

        <div class="flex justify-end gap-3 mt-6">
          <button
            type="button"
            @click="resetForm"
            class="btn-ghost"
          >
            Cancel
          </button>
          <button
            type="submit"
            :disabled="submitting"
            class="btn-primary"
          >
            {{ submitting ? 'Creating…' : 'Create conference' }}
          </button>
        </div>
      </form>
    </div>

    <!-- Empty state -->
    <div v-if="conferences.length === 0" class="text-center py-24">
      <div class="w-16 h-16 mx-auto mb-5 rounded-2xl bg-brand-50 dark:bg-brand-950/60 flex items-center justify-center">
        <span class="hero-calendar-days size-7 text-brand-700 dark:text-brand-400"></span>
      </div>
      <p style="font-family: var(--font-display);" class="text-2xl text-stone-700 dark:text-stone-300 mb-2">
        No conferences yet
      </p>
      <p class="text-sm text-stone-400 dark:text-stone-500">Click "New conference" to get started.</p>
    </div>

    <!-- Conference list -->
    <div v-else class="space-y-2.5">
      <div
        v-for="conference in conferences"
        :key="conference.id"
        class="glass-card px-6 py-4 flex items-center justify-between gap-4 group hover:shadow-md transition-shadow"
      >
        <div class="flex items-center gap-4 min-w-0">
          <div class="min-w-0">
            <div class="flex items-center gap-3 mb-1">
              <a
                :href="`/${conference.slug}`"
                class="font-medium text-stone-900 dark:text-stone-100 hover:text-brand-800 dark:hover:text-brand-400 transition-colors truncate"
              >
                {{ conference.name }}
              </a>
              <span
                :class="['status-badge', statusClasses(conference.status)]"
              >
                {{ statusLabel(conference.status) }}
              </span>
            </div>
            <div class="flex items-center gap-2.5 text-xs text-stone-400 dark:text-stone-500">
              <span v-if="conference.location" class="flex items-center gap-1">
                <span class="hero-map-pin size-3 opacity-60"></span>
                {{ conference.location }}
              </span>
              <span v-if="conference.location && conference.starts_at" aria-hidden="true">·</span>
              <span v-if="conference.starts_at">{{ conference.starts_at }}</span>
            </div>
          </div>
        </div>

        <div class="flex items-center gap-1 flex-shrink-0">
          <a
            :href="`/${conference.slug}`"
            class="p-2 text-stone-400 dark:text-stone-500 hover:text-stone-600 dark:hover:text-stone-300 hover:bg-stone-100 dark:hover:bg-stone-800 rounded-lg transition-colors"
            title="View public page"
            :aria-label="`View ${conference.name} public page`"
          >
            <span class="hero-arrow-top-right-on-square size-4"></span>
          </a>
          <button
            @click="deleteConference(conference.id, conference.name)"
            class="p-2 text-stone-300 dark:text-stone-600 opacity-0 group-hover:opacity-100 hover:text-red-600 dark:hover:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-all"
            title="Delete conference"
            :aria-label="`Delete ${conference.name}`"
          >
            <span class="hero-trash size-4"></span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
