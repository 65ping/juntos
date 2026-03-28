import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/svelte";
import ConferenceTickets from "../svelte/ConferenceTickets.svelte";

function mockLive() {
  return { pushEvent: vi.fn() };
}

const sampleTiers = [
  { id: "t1", name: "General Admission", description: "Standard entry", price_cents: 9900, quantity: 100, sold_count: 10 },
  { id: "t2", name: "Early Bird", description: null, price_cents: 4900, quantity: null, sold_count: 0 },
  { id: "t3", name: "Workshop Only", description: "Workshops included", price_cents: 0, quantity: 20, sold_count: 20 },
];

function renderTickets(props = {}) {
  return render(ConferenceTickets, {
    props: { ticket_tiers: sampleTiers, live: mockLive(), ...props },
  });
}

describe("ConferenceTickets", () => {
  describe("rendering", () => {
    it("renders all tier names", () => {
      renderTickets();
      expect(screen.getByText("General Admission")).toBeInTheDocument();
      expect(screen.getByText("Early Bird")).toBeInTheDocument();
      expect(screen.getByText("Workshop Only")).toBeInTheDocument();
    });

    it("renders description when present", () => {
      renderTickets();
      expect(screen.getByText("Standard entry")).toBeInTheDocument();
      expect(screen.getByText("Workshops included")).toBeInTheDocument();
    });

    it("does not render description element when absent", () => {
      renderTickets({ ticket_tiers: [sampleTiers[1]] });
      expect(screen.queryByText("null")).not.toBeInTheDocument();
    });

    it("formats dollar prices correctly", () => {
      renderTickets();
      expect(screen.getByText("$99")).toBeInTheDocument();
      expect(screen.getByText("$49")).toBeInTheDocument();
    });

    it("shows Free for zero price", () => {
      renderTickets();
      expect(screen.getByText("Free")).toBeInTheDocument();
    });

    it("shows remaining count when quantity is set", () => {
      renderTickets();
      // 100 - 10 = 90 remaining for General Admission
      expect(screen.getByText(/90 remaining/i)).toBeInTheDocument();
      // 20 - 20 = 0 remaining for Workshop Only (exact match avoids matching "90 remaining")
      expect(screen.getByText("0 remaining")).toBeInTheDocument();
    });

    it("does not show remaining count when quantity is null", () => {
      renderTickets({ ticket_tiers: [sampleTiers[1]] });
      expect(screen.queryByText(/remaining/i)).not.toBeInTheDocument();
    });

    it("renders a Get ticket button for available tiers", () => {
      renderTickets();
      const getTicketButtons = screen.getAllByRole("button", { name: /Get ticket/i });
      expect(getTicketButtons).toHaveLength(2);
    });

    it("renders a Sold out button for sold-out tiers", () => {
      renderTickets();
      expect(screen.getByRole("button", { name: /Sold out/i })).toBeInTheDocument();
    });

    it("sold out button is disabled", () => {
      renderTickets();
      expect(screen.getByRole("button", { name: /Sold out/i })).toBeDisabled();
    });

    it("renders the Tickets heading", () => {
      renderTickets();
      expect(screen.getByRole("heading", { name: /Tickets/i })).toBeInTheDocument();
    });
  });

  describe("get ticket interaction", () => {
    it("pushes get_ticket event with tier id when clicked", async () => {
      const live = mockLive();
      renderTickets({ ticket_tiers: [sampleTiers[0]], live });

      await fireEvent.click(screen.getByRole("button", { name: /Get ticket/i }));

      expect(live.pushEvent).toHaveBeenCalledWith("get_ticket", { tier_id: "t1" });
    });

    it("pushes correct tier id for each button", async () => {
      const live = mockLive();
      renderTickets({ live });

      const buttons = screen.getAllByRole("button", { name: /Get ticket/i });
      await fireEvent.click(buttons[1]);

      expect(live.pushEvent).toHaveBeenCalledWith("get_ticket", { tier_id: "t2" });
    });
  });
});
