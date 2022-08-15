import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "hideOnSelect",
    "incidentTypeCard",
    "selectedForm",
    "selectedIncidentCard",
    "incidentTypeId",
    "showOnSelectedConfidenceRating",
    "submitButton",
  ];

  initialize() {
    this.selected = null;
  }

  selectIncidentType(event) {
    const button = event.target;
    this.selected = event.target.closest(
      "[data-classify-target='incidentTypeCard']"
    );

    button.classList.add("hidden");
    button.nextElementSibling.classList.remove("hidden");
    const dupNode = this.selected.cloneNode(true);

    this.hideOnSelectTargets.forEach((el) => {
      el.classList.add("hidden");
    });

    this.selectedIncidentCardTarget.innerHTML = "";
    this.selectedIncidentCardTarget.appendChild(dupNode);
    this.selectedFormTarget.classList.remove("hidden");

    this.incidentTypeIdTarget.setAttribute(
      "value",
      this.selected.dataset.incidentId
    );
  }

  deselectIncidentType(event) {
    event.preventDefault();
  }

  selectConfidenceRating(event) {
    const select = event.target;

    // Only show the reasoning field if the confidence rating
    // is 'Low confidence' (1) or 'Somewhat Confident' (2)
    if (["0", "1"].includes(select.value)) {
      this.showOnSelectedConfidenceRatingTarget.classList.remove("hidden");
    } else {
      this.showOnSelectedConfidenceRatingTarget.classList.add("hidden");
    }

    if (["0", "1", "2"].includes(select.value)) {
      this.submitButtonTarget.classList.remove("hidden");
    } else {
      this.submitButtonTarget.classList.add("hidden");
    }
  }

  submit(event) {
    this.selectedFormTarget.requestSubmit();
    this.selectedFormTarget.classList.add("hidden");
  }
}
