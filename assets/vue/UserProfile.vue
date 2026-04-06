<template>
  <div class="min-h-screen px-6 py-16">
    <div class="max-w-3xl mx-auto">
      <!-- Profile header -->
      <div class="flex items-start gap-6 mb-10">
        <div class="flex-shrink-0">
          <div
            class="w-20 h-20 rounded-2xl overflow-hidden bg-brand-50 dark:bg-brand-950/60 flex items-center justify-center"
          >
            <img
              v-if="profileUser.avatar_url"
              :src="profileUser.avatar_url"
              :alt="profileUser.display_name || emailPrefix"
              class="w-full h-full object-cover"
            />
            <span v-else class="text-2xl font-semibold text-brand-700 dark:text-brand-400">
              {{ avatarInitials }}
            </span>
          </div>
        </div>

        <div class="flex-1 min-w-0">
          <div class="flex items-start justify-between gap-4">
            <div>
              <h1
                class="text-2xl text-stone-900 dark:text-stone-100 font-semibold leading-tight"
                style="font-family: var(--font-display);"
              >
                {{ profileUser.display_name || emailPrefix }}
              </h1>
              <p v-if="profileUser.display_name" class="text-sm text-stone-400 dark:text-stone-500 mt-0.5">
                {{ emailPrefix }}
              </p>
            </div>
            <div class="flex items-center gap-2 flex-shrink-0">
              <button
                v-if="isOwnProfile && !editing"
                @click="emit('edit_profile', {})"
                class="btn-ghost !py-1.5 !px-3 !text-xs"
              >
                Edit profile
              </button>
              <button
                v-if="!isOwnProfile"
                @click="emit('send_message_to_user', {})"
                class="btn-primary !py-1.5 !px-4 !text-xs"
              >
                Send message
              </button>
            </div>
          </div>

          <p v-if="profileUser.bio && !editing" class="text-stone-600 dark:text-stone-300 mt-3 text-sm leading-relaxed">
            {{ profileUser.bio }}
          </p>
        </div>
      </div>

      <!-- Edit form -->
      <div v-if="editing" class="glass-card p-7 mb-8">
        <h2 class="font-semibold text-stone-900 dark:text-stone-100 mb-5">Edit profile</h2>
        <form @submit.prevent="saveProfile" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-stone-700 dark:text-stone-300 mb-1.5" for="display-name">
              Display name
            </label>
            <input
              id="display-name"
              v-model="form.display_name"
              type="text"
              class="input-field"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-stone-700 dark:text-stone-300 mb-1.5" for="bio">
              Bio
            </label>
            <textarea
              id="bio"
              v-model="form.bio"
              rows="3"
              class="input-field resize-none"
            />
          </div>
          <div>
            <label class="block text-sm font-medium text-stone-700 dark:text-stone-300 mb-1.5" for="avatar-url">
              Avatar URL
            </label>
            <input
              id="avatar-url"
              v-model="form.avatar_url"
              type="url"
              class="input-field"
            />
          </div>
          <div class="flex justify-end gap-3 pt-1">
            <button
              type="button"
              @click="emit('cancel_edit', {})"
              class="btn-ghost !py-1.5 !px-3 !text-xs"
            >
              Cancel
            </button>
            <button
              type="submit"
              class="btn-primary !py-1.5 !px-4 !text-xs"
            >
              Save changes
            </button>
          </div>
        </form>
      </div>

      <!-- Tabs -->
      <div class="border-b border-stone-200 dark:border-stone-700/60 mb-8" role="tablist">
        <div class="flex gap-0.5">
          <button
            v-for="tab in visibleTabs"
            :key="tab.value"
            @click="emit('switch_tab', { tab: tab.value })"
            :class="[
              'px-4 py-3.5 text-sm font-medium border-b-2 transition-colors',
              activeTab === tab.value
                ? 'border-brand-700 dark:border-brand-400 text-brand-800 dark:text-brand-400'
                : 'border-transparent text-stone-500 dark:text-stone-400 hover:text-stone-800 dark:hover:text-stone-200 hover:border-stone-300 dark:hover:border-stone-600'
            ]"
            role="tab"
            :aria-selected="activeTab === tab.value"
          >
            {{ tab.label }}
          </button>
        </div>
      </div>

      <!-- About -->
      <div v-if="activeTab === 'about'" role="tabpanel">
        <div v-if="profileUser.bio" class="text-stone-600 dark:text-stone-300 leading-relaxed">
          {{ profileUser.bio }}
        </div>
        <p v-else class="text-stone-400 dark:text-stone-500 text-sm">
          {{ isOwnProfile ? 'Add a bio to tell people about yourself.' : 'No bio yet.' }}
        </p>
      </div>

      <!-- Conferences -->
      <div v-else-if="activeTab === 'conferences'" role="tabpanel">
        <div v-if="conferencesData.length === 0" class="text-stone-400 dark:text-stone-500 text-sm">
          No conferences yet.
        </div>
        <div v-else class="space-y-2.5">
          <a
            v-for="conf in conferencesData"
            :key="conf.id"
            :href="`/${conf.slug}`"
            class="glass-card p-4 flex items-center justify-between hover:-translate-y-0.5 transition-transform group"
          >
            <span class="font-medium text-stone-900 dark:text-stone-100 group-hover:text-brand-800 dark:group-hover:text-brand-400 transition-colors">
              {{ conf.name }}
            </span>
            <span class="text-xs capitalize text-stone-400 dark:text-stone-500">{{ conf.status.replace('_', ' ') }}</span>
          </a>
        </div>
      </div>

      <!-- Inbox -->
      <div v-else-if="activeTab === 'inbox'" role="tabpanel">
        <div v-if="conversationsData.length === 0" class="text-stone-400 dark:text-stone-500 text-sm">
          No messages yet.
        </div>
        <div v-else class="space-y-2">
          <a
            v-for="conv in conversationsData"
            :key="conv.id"
            :href="`/messages/${conv.id}`"
            class="glass-card p-4 flex items-center justify-between hover:-translate-y-0.5 transition-transform group"
          >
            <div class="min-w-0 flex-1">
              <p class="text-sm font-medium text-stone-900 dark:text-stone-100 group-hover:text-brand-800 dark:group-hover:text-brand-400 transition-colors">
                Conversation
              </p>
              <p v-if="conv.last_message" class="text-xs text-stone-500 dark:text-stone-400 truncate mt-0.5">
                {{ conv.last_message }}
              </p>
            </div>
            <span v-if="conv.updated_at" class="text-xs text-stone-400 dark:text-stone-500 flex-shrink-0 ml-4">
              {{ conv.updated_at }}
            </span>
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useLiveVue } from 'live_vue'

const emit = useLiveVue()

const props = defineProps({
  profileUser:  { type: Object,  required: true },
  isOwnProfile: { type: Boolean, default: false },
  activeTab:    { type: String,  default: 'about' },
  editing:      { type: Boolean, default: false },
  tabData:      { type: Object,  default: () => ({}) }
})

const form = ref({
  display_name: props.profileUser.display_name || '',
  bio:          props.profileUser.bio || '',
  avatar_url:   props.profileUser.avatar_url || ''
})

watch(() => props.profileUser, (user) => {
  form.value = {
    display_name: user.display_name || '',
    bio:          user.bio || '',
    avatar_url:   user.avatar_url || ''
  }
})

const emailPrefix = computed(() => {
  const email = props.profileUser.email || ''
  return email.split('@')[0]
})

const avatarInitials = computed(() => {
  const name = props.profileUser.display_name || emailPrefix.value
  return name.split(' ').map(p => p[0]).join('').slice(0, 2).toUpperCase()
})

const allTabs = [
  { value: 'about',       label: 'About' },
  { value: 'conferences', label: 'Conferences' },
  { value: 'tickets',     label: 'Tickets' },
  { value: 'inbox',       label: 'Inbox' }
]

const visibleTabs = computed(() => {
  if (props.isOwnProfile) return allTabs
  return allTabs.filter(t => t.value !== 'inbox' && t.value !== 'tickets')
})

const conferencesData  = computed(() => props.tabData.conferences   || [])
const conversationsData = computed(() => props.tabData.conversations || [])

function saveProfile() {
  emit('save_profile', { ...form.value })
}
</script>
