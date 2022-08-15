import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static get targets() {
    return ["form"];
  }

  initialize() {
    this.input = null;
  }

  submit(event) {
    this.input = event.target;

    if (this.input.value.length > 1) {
      this.formTarget.requestSubmit();
    }
  }

  enable() {
    this.input.removeAttribute("disabled");
    this.input.classList.add("rounded-input");
    this.input.classList.remove("disabled-rounded-input");
  }

  disable() {
    this.input.setAttribute("disabled", "");
    this.input.classList.remove("rounded-input");
    this.input.classList.add("disabled-rounded-input");
  }
}
