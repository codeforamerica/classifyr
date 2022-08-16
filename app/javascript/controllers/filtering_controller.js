import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static get targets() {
    return ["form"];
  }

  initialize() {
    this.input = null;
    this.timeout = null;
  }

  submit(event) {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.input = event.target;

      if (this.input.value.length > 1 || this.input.value.length === 0) {
        this.formTarget.requestSubmit();
      }
    }, 200);
  }

  enable() {
    this.input.removeAttribute("disabled");
    this.input.classList.add("rounded-input");
    this.input.classList.remove("disabled-rounded-input");

    this.formTarget.requestSubmit();
  }

  disable() {
    this.input.setAttribute("disabled", "");
    this.input.classList.remove("rounded-input");
    this.input.classList.add("disabled-rounded-input");
  }
}
