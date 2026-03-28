import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/svelte";
import ConferenceDashboard from "../svelte/ConferenceDashboard.svelte";

function mockLive() {
  return { pushEvent: vi.fn() };
}

const sampleConferences = [
  { id: "1", name: "ElixirConf 2026", slug: "elixirconf-2026", status: "draft", location: "Austin, TX", organizer_id: "u1" },
  { id: "2", name: "BeamConf", slug: "beamconf", status: "cfp_open", location: null, organizer_id: "u1" },
];

function renderDashboard(props = {}) {
  return render(ConferenceDashboard, {
    props: { conferences: [], live: mockLive(), ...props },
  });
}

describe("ConferenceDashboard", () => {
  describe("empty state", () => {
    it("shows 'No conferences yet' when list is empty", () => {
      renderDashboard();
      expect(screen.getByText(/No conferences yet/i)).toBeInTheDocument();
    });

    it("shows 'New conference' button", () => {
      renderDashboard();
      expect(screen.getByRole("button", { name: /New conference/i })).toBeInTheDocument();
    });
  });

  describe("conference list", () => {
    it("renders all conference names", () => {
      renderDashboard({ conferences: sampleConferences });
      expect(screen.getByText("ElixirConf 2026")).toBeInTheDocument();
      expect(screen.getByText("BeamConf")).toBeInTheDocument();
    });

    it("renders location when present", () => {
      renderDashboard({ conferences: sampleConferences });
      expect(screen.getByText("Austin, TX")).toBeInTheDocument();
    });

    it("shows Draft status badge", () => {
      renderDashboard({ conferences: sampleConferences });
      expect(screen.getByText("Draft")).toBeInTheDocument();
    });

    it("shows CFP Open status badge", () => {
      renderDashboard({ conferences: sampleConferences });
      expect(screen.getByText("CFP Open")).toBeInTheDocument();
    });
  });

  describe("new conference form", () => {
    it("form is hidden initially", () => {
      renderDashboard();
      expect(screen.queryByLabelText(/Conference name/i)).not.toBeInTheDocument();
    });

    it("opens form when 'New conference' is clicked", async () => {
      renderDashboard();
      await fireEvent.click(screen.getByRole("button", { name: /New conference/i }));
      expect(screen.getByLabelText(/Conference name/i)).toBeInTheDocument();
    });

    it("closes form when Cancel is clicked", async () => {
      renderDashboard();
      await fireEvent.click(screen.getByRole("button", { name: /New conference/i }));
      await fireEvent.click(screen.getByRole("button", { name: /Cancel/i }));
      expect(screen.queryByLabelText(/Conference name/i)).not.toBeInTheDocument();
    });

    it("pushes create_conference event on submit", async () => {
      const live = mockLive();
      renderDashboard({ live });

      await fireEvent.click(screen.getByRole("button", { name: /New conference/i }));

      await fireEvent.input(screen.getByLabelText(/Conference name/i), {
        target: { value: "My New Conf" },
      });

      // queryByRole (not getByRole) returns null when no named form; fallback to closest()
      const form = screen.queryByRole("form") ?? screen.getByLabelText(/Conference name/i).closest("form");
      await fireEvent.submit(form);

      expect(live.pushEvent).toHaveBeenCalledWith(
        "create_conference",
        expect.objectContaining({
          conference: expect.objectContaining({ name: "My New Conf" }),
        }),
        expect.any(Function)
      );
    });

    it("does not submit when name is empty", async () => {
      const live = mockLive();
      renderDashboard({ live });

      await fireEvent.click(screen.getByRole("button", { name: /New conference/i }));
      const form = screen.getByLabelText(/Conference name/i).closest("form");
      await fireEvent.submit(form);

      expect(live.pushEvent).not.toHaveBeenCalled();
    });
  });

  describe("delete conference", () => {
    it("pushes delete_conference event after confirm", async () => {
      const live = mockLive();
      vi.spyOn(window, "confirm").mockReturnValue(true);
      renderDashboard({ conferences: sampleConferences, live });

      const deleteButtons = screen.getAllByTitle(/Delete conference/i);
      await fireEvent.click(deleteButtons[0]);

      expect(live.pushEvent).toHaveBeenCalledWith("delete_conference", { id: "1" });

      vi.restoreAllMocks();
    });

    it("does not push event when confirm is cancelled", async () => {
      const live = mockLive();
      vi.spyOn(window, "confirm").mockReturnValue(false);
      renderDashboard({ conferences: sampleConferences, live });

      const deleteButtons = screen.getAllByTitle(/Delete conference/i);
      await fireEvent.click(deleteButtons[0]);

      expect(live.pushEvent).not.toHaveBeenCalled();

      vi.restoreAllMocks();
    });
  });
});
