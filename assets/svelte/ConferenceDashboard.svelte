<script>
  let { conferences = [], live } = $props();

  let conferenceList = $state.raw(conferences);

  $effect(() => {
    conferenceList = conferences;
  });

  let showForm = $state(false);
  let name = $state("");
  let description = $state("");
  let location = $state("");
  let startsAt = $state("");
  let submitting = $state(false);

  function resetForm() {
    name = "";
    description = "";
    location = "";
    startsAt = "";
    showForm = false;
    submitting = false;
  }

  function handleSubmit(e) {
    e.preventDefault();
    if (!name.trim()) return;
    submitting = true;
    live.pushEvent(
      "create_conference",
      { conference: { name, description, location, starts_at: startsAt } },
      () => resetForm()
    );
  }

  function deleteConference(id, conferenceName) {
    if (!confirm(`Delete "${conferenceName}"? This cannot be undone.`)) return;
    live.pushEvent("delete_conference", { id });
  }

  function statusLabel(status) {
    const labels = {
      draft: "Draft",
      cfp_open: "CFP Open",
      cfp_closed: "CFP Closed",
      scheduled: "Scheduled",
      complete: "Complete",
    };
    return labels[status] ?? status;
  }

  function statusClasses(status) {
    const classes = {
      draft: "bg-stone-100 dark:bg-stone-800 text-stone-500 dark:text-stone-400",
      cfp_open: "bg-emerald-50 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-400",
      cfp_closed: "bg-sky-50 dark:bg-sky-900/30 text-sky-700 dark:text-sky-400",
      scheduled: "bg-amber-50 dark:bg-amber-900/30 text-amber-700 dark:text-amber-400",
      complete: "bg-stone-100 dark:bg-stone-800 text-stone-500 dark:text-stone-400",
    };
    return classes[status] ?? "bg-stone-100 dark:bg-stone-800 text-stone-500 dark:text-stone-400";
  }
</script>

<div>
  <div class="flex items-center justify-between mb-10">
    <h1
      style="font-family: var(--font-display);"
      class="text-3xl text-stone-900 dark:text-stone-100 tracking-tight"
    >
      My Conferences
    </h1>
    <button
      onclick={() => (showForm = true)}
      class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-amber-600 hover:bg-amber-500 rounded-lg shadow-sm transition-all hover:-translate-y-px"
    >
      New conference <span aria-hidden="true">+</span>
    </button>
  </div>

  {#if showForm}
    <div class="glass-card p-6 mb-8">
      <div class="flex items-center justify-between mb-6">
        <h2
          style="font-family: var(--font-display);"
          class="text-xl text-stone-900 dark:text-stone-100"
        >
          New Conference
        </h2>
        <button
          onclick={resetForm}
          class="text-stone-400 dark:text-stone-500 hover:text-stone-600 dark:hover:text-stone-300 transition-colors"
          aria-label="Close"
        >
          <span class="hero-x-mark size-5"></span>
        </button>
      </div>

      <form onsubmit={handleSubmit}>
        <div class="grid gap-4 sm:grid-cols-2">
          <div class="sm:col-span-2">
            <label class="block text-sm font-medium text-stone-700 dark:text-stone-300 mb-1.5" for="conf-name">
              Conference name
            </label>
            <input
              id="conf-name"
              type="text"
              bind:value={name}
              placeholder="ElixirConf 2026"
              required
              class="w-full px-3 py-2 text-sm border border-stone-300 dark:border-stone-700 rounded-lg bg-white dark:bg-stone-900 text-stone-900 dark:text-stone-100 placeholder-stone-400 dark:placeholder-stone-600 focus:outline-none focus:border-amber-400 focus:ring-2 focus:ring-amber-400/20 transition-colors"
            />
          </div>

          <div class="sm:col-span-2">
            <label class="block text-sm font-medium text-stone-700 dark:text-stone-300 mb-1.5" for="conf-desc">
              Description <span class="text-stone-400 dark:text-stone-500 font-normal">(optional)</span>
            </label>
            <textarea
              id="conf-desc"
              bind:value={description}
              rows="3"
              placeholder="A short description of your conference…"
              class="w-full px-3 py-2 text-sm border border-stone-300 dark:border-stone-700 rounded-lg bg-white dark:bg-stone-900 text-stone-900 dark:text-stone-100 placeholder-stone-400 dark:placeholder-stone-600 focus:outline-none focus:border-amber-400 focus:ring-2 focus:ring-amber-400/20 transition-colors resize-none"
            ></textarea>
          </div>

          <div>
            <label class="block text-sm font-medium text-stone-700 dark:text-stone-300 mb-1.5" for="conf-location">
              Location <span class="text-stone-400 dark:text-stone-500 font-normal">(optional)</span>
            </label>
            <input
              id="conf-location"
              type="text"
              bind:value={location}
              placeholder="Austin, TX"
              class="w-full px-3 py-2 text-sm border border-stone-300 dark:border-stone-700 rounded-lg bg-white dark:bg-stone-900 text-stone-900 dark:text-stone-100 placeholder-stone-400 dark:placeholder-stone-600 focus:outline-none focus:border-amber-400 focus:ring-2 focus:ring-amber-400/20 transition-colors"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-stone-700 dark:text-stone-300 mb-1.5" for="conf-starts">
              Start date <span class="text-stone-400 dark:text-stone-500 font-normal">(optional)</span>
            </label>
            <input
              id="conf-starts"
              type="date"
              bind:value={startsAt}
              class="w-full px-3 py-2 text-sm border border-stone-300 dark:border-stone-700 rounded-lg bg-white dark:bg-stone-900 text-stone-900 dark:text-stone-100 focus:outline-none focus:border-amber-400 focus:ring-2 focus:ring-amber-400/20 transition-colors"
            />
          </div>
        </div>

        <div class="flex justify-end gap-3 mt-6">
          <button
            type="button"
            onclick={resetForm}
            class="px-4 py-2 text-sm font-medium text-stone-600 dark:text-stone-400 hover:text-stone-900 dark:hover:text-stone-100 hover:bg-stone-100 dark:hover:bg-stone-800 rounded-lg transition-colors"
          >
            Cancel
          </button>
          <button
            type="submit"
            disabled={submitting}
            class="px-5 py-2 text-sm font-medium text-white bg-amber-600 hover:bg-amber-500 rounded-lg shadow-sm transition-all hover:-translate-y-px disabled:opacity-60 disabled:cursor-not-allowed disabled:hover:translate-y-0"
          >
            {submitting ? "Creating…" : "Create conference"}
          </button>
        </div>
      </form>
    </div>
  {/if}

  {#if conferenceList.length === 0}
    <div class="text-center py-20 text-stone-400 dark:text-stone-500">
      <p style="font-family: var(--font-display);" class="text-2xl mb-2">
        No conferences yet
      </p>
      <p class="text-sm">Click "New conference" to get started.</p>
    </div>
  {:else}
    <div class="space-y-3">
      {#each conferenceList as conference (conference.id)}
        <div class="glass-card px-6 py-5 flex items-center justify-between gap-4 group hover:shadow-md transition-shadow">
          <div class="flex items-center gap-4 min-w-0">
            <div class="min-w-0">
              <div class="flex items-center gap-3 mb-1">
                <a
                  href="/{conference.slug}"
                  class="font-medium text-stone-900 dark:text-stone-100 hover:text-amber-700 dark:hover:text-amber-400 transition-colors truncate"
                >
                  {conference.name}
                </a>
                <span
                  class="inline-block px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wider rounded-full shrink-0 {statusClasses(conference.status)}"
                >
                  {statusLabel(conference.status)}
                </span>
              </div>
              <div class="flex items-center gap-3 text-xs text-stone-400 dark:text-stone-500">
                {#if conference.location}
                  <span>{conference.location}</span>
                {/if}
                {#if conference.location && conference.starts_at}
                  <span>·</span>
                {/if}
                {#if conference.starts_at}
                  <span>{conference.starts_at}</span>
                {/if}
              </div>
            </div>
          </div>

          <div class="flex items-center gap-1 shrink-0">
            <a
              href="/{conference.slug}"
              class="p-2 text-stone-400 dark:text-stone-500 hover:text-stone-600 dark:hover:text-stone-300 hover:bg-stone-100 dark:hover:bg-stone-800 rounded-md transition-colors"
              title="View public page"
              aria-label="View {conference.name} public page"
            >
              <span class="hero-arrow-top-right-on-square size-4"></span>
            </a>
            <button
              onclick={() => deleteConference(conference.id, conference.name)}
              class="p-2 text-stone-300 dark:text-stone-600 opacity-0 group-hover:opacity-100 hover:text-red-600 dark:hover:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-md transition-all"
              title="Delete conference"
              aria-label="Delete {conference.name}"
            >
              <span class="hero-trash size-4"></span>
            </button>
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>
