<template>
  <div class="flex flex-col h-[calc(100vh-80px)]">
    <!-- Header -->
    <div class="px-6 py-4 border-b border-stone-200 dark:border-stone-700/60 flex-shrink-0 glass-card rounded-none">
      <div class="max-w-3xl mx-auto flex items-center gap-3">
        <a
          href="/profile"
          class="p-1.5 text-stone-400 hover:text-stone-700 dark:hover:text-stone-200 hover:bg-stone-100 dark:hover:bg-stone-800 rounded-lg transition-colors"
          aria-label="Back to profile"
        >
          <span class="hero-arrow-left size-4"></span>
        </a>
        <h1 class="text-base font-semibold text-stone-900 dark:text-stone-100">
          {{ conversation.subject || 'Direct message' }}
        </h1>
      </div>
    </div>

    <!-- Messages -->
    <div ref="scrollRef" class="flex-1 overflow-y-auto px-6 py-6">
      <div class="max-w-3xl mx-auto space-y-4">
        <div
          v-for="msg in messages"
          :key="msg.id"
          :class="['flex', msg.is_own ? 'justify-end' : 'justify-start']"
        >
          <div :class="['max-w-[72%] flex flex-col gap-1', msg.is_own ? 'items-end' : 'items-start']">
            <span v-if="!msg.is_own" class="text-xs text-stone-400 dark:text-stone-500 px-1">
              {{ msg.sender_name }}
            </span>
            <div
              :class="[
                'px-4 py-2.5 text-sm leading-relaxed',
                msg.is_own
                  ? 'bg-brand-900 dark:bg-brand-800 text-white rounded-2xl rounded-br-sm'
                  : 'bg-stone-100 dark:bg-stone-800 text-stone-900 dark:text-stone-100 rounded-2xl rounded-bl-sm'
              ]"
            >
              {{ msg.body }}
            </div>
            <span class="text-xs text-stone-400 dark:text-stone-500 px-1">{{ msg.inserted_at }}</span>
          </div>
        </div>

        <div v-if="messages.length === 0" class="text-center py-20">
          <div class="w-12 h-12 mx-auto mb-4 rounded-2xl bg-brand-50 dark:bg-brand-950/60 flex items-center justify-center">
            <span class="hero-chat-bubble-left-right size-5 text-brand-600 dark:text-brand-400"></span>
          </div>
          <p class="text-stone-500 dark:text-stone-400 font-medium">No messages yet</p>
          <p class="text-sm text-stone-400 dark:text-stone-500 mt-1">Say hello to start the conversation.</p>
        </div>
      </div>
    </div>

    <!-- Input -->
    <div class="flex-shrink-0 px-6 py-4 border-t border-stone-200 dark:border-stone-700/60 bg-white/80 dark:bg-stone-900/80 backdrop-blur-sm">
      <div class="max-w-3xl mx-auto flex gap-3">
        <textarea
          v-model="draft"
          @keydown.enter.exact.prevent="send"
          rows="1"
          placeholder="Type a message…"
          class="input-field flex-1 resize-none"
          aria-label="Message input"
        />
        <button
          @click="send"
          :disabled="!draft.trim()"
          class="btn-primary flex-shrink-0 !py-2.5 !px-4"
          aria-label="Send message"
        >
          <span class="hero-paper-airplane size-4"></span>
        </button>
      </div>
      <p class="text-xs text-stone-400 dark:text-stone-500 mt-2 max-w-3xl mx-auto">
        Press Enter to send &middot; Shift+Enter for new line
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, nextTick } from 'vue'
import { useLiveVue } from 'live_vue'

const emit = useLiveVue()

const props = defineProps({
  messages:      { type: Array,  default: () => [] },
  conversation:  { type: Object, required: true },
  currentUserId: { type: String, required: true }
})

const draft     = ref('')
const scrollRef = ref(null)

function send() {
  const body = draft.value.trim()
  if (!body) return
  emit('send_message', { body })
  draft.value = ''
}

watch(() => props.messages, async () => {
  await nextTick()
  if (scrollRef.value) {
    scrollRef.value.scrollTop = scrollRef.value.scrollHeight
  }
}, { deep: true })
</script>
