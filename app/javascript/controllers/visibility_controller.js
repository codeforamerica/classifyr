import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["hide", "temporaryHide"];

  show() {
    this.hideTargets.forEach((el) => {
      el.classList.remove("hidden");
    });

    this.hideTemporary();
  }

  hide() {
    this.hideTargets.forEach((el) => {
      el.classList.add("hidden");
    });

    this.showTemporary();
  }

  showTemporary() {
    this.temporaryHideTargets.forEach((el) => {
      el.classList.remove("hidden");
    });
  }

  hideTemporary() {
    this.temporaryHideTargets.forEach((el) => {
      el.classList.add("hidden");
    });
  }
}
