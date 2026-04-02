import { describe, it, expect, vi } from "vitest";
import { mount } from "@vue/test-utils";
import ConferenceTickets from "../vue/ConferenceTickets.vue";

function mockLive() {
  return { pushEvent: vi.fn() };
}

const sampleTiers = [
  { id: "t1", name: "General Admission", description: "Standard entry", price_cents: 9900, quantity: 100, sold_count: 10 },
  { id: "t2", name: "Early Bird", description: null, price_cents: 4900, quantity: null, sold_count: 0 },
  { id: "t3", name: "Workshop Only", description: "Workshops included", price_cents: 0, quantity: 20, sold_count: 20 },
];

function renderTickets(props = {}, live = mockLive()) {
  return mount(ConferenceTickets, {
    props: { ticket_tiers: sampleTiers, ...props },
    global: {
      provide: { _live_vue: live },
    },
  });
}

describe("ConferenceTickets", () => {
  describe("rendering", () => {
    it("renders all tier names", () => {
      const wrapper = renderTickets();
      expect(wrapper.text()).toContain("General Admission");
      expect(wrapper.text()).toContain("Early Bird");
      expect(wrapper.text()).toContain("Workshop Only");
    });

    it("renders description when present", () => {
      const wrapper = renderTickets();
      expect(wrapper.text()).toContain("Standard entry");
      expect(wrapper.text()).toContain("Workshops included");
    });

    it("does not render description element when absent", () => {
      const wrapper = renderTickets({ ticket_tiers: [sampleTiers[1]] });
      expect(wrapper.text()).not.toContain("null");
    });

    it("formats dollar prices correctly", () => {
      const wrapper = renderTickets();
      expect(wrapper.text()).toContain("$99");
      expect(wrapper.text()).toContain("$49");
    });

    it("shows Free for zero price", () => {
      const wrapper = renderTickets();
      expect(wrapper.text()).toContain("Free");
    });

    it("shows remaining count when quantity is set", () => {
      const wrapper = renderTickets();
      // 100 - 10 = 90 remaining for General Admission
      expect(wrapper.text()).toMatch(/90 remaining/i);
      // 20 - 20 = 0 remaining for Workshop Only
      expect(wrapper.text()).toContain("0 remaining");
    });

    it("does not show remaining count when quantity is null", () => {
      const wrapper = renderTickets({ ticket_tiers: [sampleTiers[1]] });
      expect(wrapper.text()).not.toMatch(/remaining/i);
    });

    it("renders a Get ticket button for available tiers", () => {
      const wrapper = renderTickets();
      const getTicketButtons = wrapper.findAll("button").filter(b => b.text().match(/Get ticket/i));
      expect(getTicketButtons).toHaveLength(2);
    });

    it("renders a Sold out button for sold-out tiers", () => {
      const wrapper = renderTickets();
      const soldOutButton = wrapper.findAll("button").find(b => b.text().match(/Sold out/i));
      expect(soldOutButton).toBeDefined();
    });

    it("sold out button is disabled", () => {
      const wrapper = renderTickets();
      const soldOutButton = wrapper.findAll("button").find(b => b.text().match(/Sold out/i));
      expect(soldOutButton.attributes("disabled")).toBeDefined();
    });

    it("renders the Tickets heading", () => {
      const wrapper = renderTickets();
      expect(wrapper.find("h2").text()).toMatch(/Tickets/i);
    });
  });

  describe("get ticket interaction", () => {
    it("pushes get_ticket event with tier id when clicked", async () => {
      const live = mockLive();
      const wrapper = renderTickets({ ticket_tiers: [sampleTiers[0]] }, live);

      const getTicketButton = wrapper.findAll("button").find(b => b.text().match(/Get ticket/i));
      await getTicketButton.trigger("click");

      expect(live.pushEvent).toHaveBeenCalledWith("get_ticket", { tier_id: "t1" });
    });

    it("pushes correct tier id for each button", async () => {
      const live = mockLive();
      const wrapper = renderTickets({}, live);

      const buttons = wrapper.findAll("button").filter(b => b.text().match(/Get ticket/i));
      await buttons[1].trigger("click");

      expect(live.pushEvent).toHaveBeenCalledWith("get_ticket", { tier_id: "t2" });
    });
  });
});
