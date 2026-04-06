# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias Juntos.Accounts.User
alias Juntos.Core.Conference
alias Juntos.Core.Session
alias Juntos.Core.TicketTier

# Create organizer accounts
organizers =
  [
    %{
      email: "alice@example.com",
      display_name: "Alice Cheng",
      bio:
        "Conference organizer & community builder. 10+ years running developer events across Asia-Pacific."
    },
    %{
      email: "marcos@example.com",
      display_name: "Marcos Ferreira",
      bio: "Founder of BrazilConf. Passionate about making tech conferences more inclusive."
    },
    %{
      email: "priya@example.com",
      display_name: "Priya Nair",
      bio: "Engineering manager by day, conference organizer by night. ElixirForum moderator."
    }
  ]
  |> Enum.map(fn attrs ->
    case Ash.get(User, [email: attrs.email], domain: Juntos.Accounts) do
      {:ok, user} -> user
      _ -> Ash.Seed.seed!(User, attrs)
    end
  end)

[alice, marcos, priya] = organizers

# ElixirConf Asia 2026
ec_asia =
  Ash.Seed.seed!(Conference, %{
    name: "ElixirConf Asia 2026",
    slug: "elixirconf-asia-2026",
    description:
      "The premier Elixir conference in Asia-Pacific, bringing together engineers, architects, and enthusiasts to explore the cutting edge of functional programming and distributed systems.",
    location: "Singapore",
    status: :cfp_open,
    starts_at: ~U[2026-09-12 09:00:00Z],
    ends_at: ~U[2026-09-14 18:00:00Z],
    cfp_opens_at: ~U[2026-04-01 00:00:00Z],
    cfp_closes_at: ~U[2026-06-30 23:59:00Z],
    organizer_id: alice.id
  })

Ash.Seed.seed!(TicketTier, %{
  conference_id: ec_asia.id,
  name: "Early Bird",
  description: "Limited early bird pricing — grab yours before they're gone.",
  price_cents: 29900,
  quantity: 100,
  sold_count: 67,
  position: 1
})

Ash.Seed.seed!(TicketTier, %{
  conference_id: ec_asia.id,
  name: "General Admission",
  description: "Full conference access, all three days.",
  price_cents: 49900,
  quantity: 300,
  sold_count: 12,
  position: 2
})

Ash.Seed.seed!(TicketTier, %{
  conference_id: ec_asia.id,
  name: "Workshop Pass",
  description: "Includes all workshops plus general admission.",
  price_cents: 79900,
  quantity: 50,
  sold_count: 3,
  position: 3
})

Ash.Seed.seed!(Session, %{
  conference_id: ec_asia.id,
  title: "Opening Keynote",
  session_type: :keynote,
  day_number: 1,
  starts_at: ~U[2026-09-12 09:00:00Z],
  ends_at: ~U[2026-09-12 10:00:00Z],
  room: "Main Stage",
  speaker_name: "José Valim",
  speaker_bio: "Creator of Elixir.",
  position: 1
})

Ash.Seed.seed!(Session, %{
  conference_id: ec_asia.id,
  title: "Ash Framework: Beyond CRUD",
  session_type: :talk,
  day_number: 1,
  starts_at: ~U[2026-09-12 10:30:00Z],
  ends_at: ~U[2026-09-12 11:15:00Z],
  room: "Track A",
  speaker_name: "Zach Daniel",
  speaker_bio: "Creator of the Ash Framework.",
  position: 2
})

Ash.Seed.seed!(Session, %{
  conference_id: ec_asia.id,
  title: "Building Real-time Apps with LiveView",
  session_type: :talk,
  day_number: 1,
  starts_at: ~U[2026-09-12 11:30:00Z],
  ends_at: ~U[2026-09-12 12:15:00Z],
  room: "Track A",
  speaker_name: "Chris McCord",
  speaker_bio: "Creator of Phoenix Framework.",
  position: 3
})

Ash.Seed.seed!(Session, %{
  conference_id: ec_asia.id,
  title: "Lunch Break",
  session_type: :break,
  day_number: 1,
  starts_at: ~U[2026-09-12 12:15:00Z],
  ends_at: ~U[2026-09-12 13:30:00Z],
  room: nil,
  position: 4
})

Ash.Seed.seed!(Session, %{
  conference_id: ec_asia.id,
  title: "Distributed Elixir at Scale",
  session_type: :talk,
  day_number: 1,
  starts_at: ~U[2026-09-12 13:30:00Z],
  ends_at: ~U[2026-09-12 14:15:00Z],
  room: "Track A",
  speaker_name: "Andrea Leopardi",
  speaker_bio: "Elixir core team member.",
  position: 5
})

Ash.Seed.seed!(Session, %{
  conference_id: ec_asia.id,
  title: "Hands-on LiveView Workshop",
  session_type: :workshop,
  day_number: 2,
  starts_at: ~U[2026-09-13 09:00:00Z],
  ends_at: ~U[2026-09-13 12:00:00Z],
  room: "Workshop Room 1",
  speaker_name: "Chris McCord",
  position: 1
})

Ash.Seed.seed!(Session, %{
  conference_id: ec_asia.id,
  title: "Ash Framework Deep Dive",
  session_type: :workshop,
  day_number: 2,
  starts_at: ~U[2026-09-13 09:00:00Z],
  ends_at: ~U[2026-09-13 12:00:00Z],
  room: "Workshop Room 2",
  speaker_name: "Zach Daniel",
  position: 2
})

# BrazilConf 2026
brazil =
  Ash.Seed.seed!(Conference, %{
    name: "BrazilConf 2026",
    slug: "brazilconf-2026",
    description:
      "A celebration of open source, Elixir, and the vibrant Brazilian developer community. Three days of talks, workshops, and connections in the heart of São Paulo.",
    location: "São Paulo, Brazil",
    status: :scheduled,
    starts_at: ~U[2026-11-05 09:00:00Z],
    ends_at: ~U[2026-11-07 18:00:00Z],
    organizer_id: marcos.id
  })

Ash.Seed.seed!(TicketTier, %{
  conference_id: brazil.id,
  name: "Community",
  description: "Discounted ticket for students and open source contributors.",
  price_cents: 9900,
  quantity: 200,
  sold_count: 89,
  position: 1
})

Ash.Seed.seed!(TicketTier, %{
  conference_id: brazil.id,
  name: "Standard",
  price_cents: 24900,
  quantity: 400,
  sold_count: 134,
  position: 2
})

Ash.Seed.seed!(Session, %{
  conference_id: brazil.id,
  title: "Welcome & Vision",
  session_type: :keynote,
  day_number: 1,
  starts_at: ~U[2026-11-05 09:00:00Z],
  ends_at: ~U[2026-11-05 09:45:00Z],
  room: "Auditório Principal",
  speaker_name: "Marcos Ferreira",
  position: 1
})

Ash.Seed.seed!(Session, %{
  conference_id: brazil.id,
  title: "Elixir na Indústria Brasileira",
  session_type: :talk,
  day_number: 1,
  starts_at: ~U[2026-11-05 10:00:00Z],
  ends_at: ~U[2026-11-05 10:45:00Z],
  room: "Sala A",
  speaker_name: "Ana Souza",
  speaker_bio: "Staff Engineer at Nubank.",
  position: 2
})

Ash.Seed.seed!(Session, %{
  conference_id: brazil.id,
  title: "LiveView para Produtos de Alto Tráfego",
  session_type: :talk,
  day_number: 1,
  starts_at: ~U[2026-11-05 11:00:00Z],
  ends_at: ~U[2026-11-05 11:45:00Z],
  room: "Sala A",
  speaker_name: "Pedro Lima",
  speaker_bio: "Principal Engineer at iFood.",
  position: 3
})

# ElixirMix Online
online =
  Ash.Seed.seed!(Conference, %{
    name: "ElixirMix Online",
    slug: "elixirmix-online-2026",
    description:
      "A free, fully online Elixir conference open to everyone around the world. No travel required — just great talks and a welcoming community.",
    location: "Online",
    status: :cfp_open,
    starts_at: ~U[2026-08-01 14:00:00Z],
    ends_at: ~U[2026-08-01 22:00:00Z],
    cfp_opens_at: ~U[2026-05-01 00:00:00Z],
    cfp_closes_at: ~U[2026-07-01 23:59:00Z],
    organizer_id: priya.id
  })

Ash.Seed.seed!(TicketTier, %{
  conference_id: online.id,
  name: "Free Admission",
  description: "100% free — register to get your joining link and reminders.",
  price_cents: 0,
  quantity: 0,
  sold_count: 0,
  position: 1
})

# Functional Futures (complete / past)
past =
  Ash.Seed.seed!(Conference, %{
    name: "Functional Futures 2025",
    slug: "functional-futures-2025",
    description:
      "A two-day deep dive into functional programming paradigms, featuring talks on Elixir, Haskell, Clojure, and F#.",
    location: "Berlin, Germany",
    status: :complete,
    starts_at: ~U[2025-10-10 09:00:00Z],
    ends_at: ~U[2025-10-11 18:00:00Z],
    organizer_id: alice.id
  })

Ash.Seed.seed!(TicketTier, %{
  conference_id: past.id,
  name: "General",
  price_cents: 39900,
  quantity: 250,
  sold_count: 250,
  position: 1
})

IO.puts("✓ Seed data created")
IO.puts("  - 4 conferences (cfp_open, cfp_open, scheduled, complete)")
IO.puts("  - 3 organizer users")
IO.puts("  - Ticket tiers and sessions for each")
