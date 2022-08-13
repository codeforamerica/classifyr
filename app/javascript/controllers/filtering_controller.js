import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static get targets() {
    return ["form"];
  }

  submit(event) {
    if (event.target.value.length > 1) {
      this.formTarget.requestSubmit();
    }
  }
}
