import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";

function Smoke() {
  return <h1>Indie Vibe HQ</h1>;
}

describe("Smoke Test", () => {
  it("renders without crashing", () => {
    render(<Smoke />);
    expect(screen.getByText("Indie Vibe HQ")).toBeInTheDocument();
  });
});
