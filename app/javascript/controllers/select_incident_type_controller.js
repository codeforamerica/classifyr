import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "type",
    "selectedFormContainer",
    "selectedIncident",
    "incidentTypeId",
  ];

  initialize() {
    this.selected = null;
  }

  select(event) {
    const button = event.target;
    this.selected = event.target.closest(
      "[data-select-incident-type-target='type']"
    );
    console.log(this.selected);
    button.classList.add("hidden");
    button.nextElementSibling.classList.remove("hidden");
    const dupNode = this.selected.cloneNode(true);

    this.typeTargets.forEach((el) => {
      el.classList.add("hidden");
    });

    this.selectedIncidentTarget.appendChild(dupNode);
    this.selectedFormContainerTarget.classList.remove("hidden");

    this.incidentTypeIdTarget.setAttribute(
      "value",
      this.selected.dataset.incidentId
    );
  }
}
