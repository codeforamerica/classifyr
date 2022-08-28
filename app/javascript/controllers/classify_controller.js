import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "hideOnSelect",
    "incidentTypeCard",
    "selectedForm",
    "selectedIncidentCard",
    "incidentTypeId",
    "incidentTypeUnknown",
    "showOnSelectedConfidenceRating",
    "submitButton",
    "deselectedHover",
  ];

  initialize() {
    this.selected = null;
    this.hoveredButton = null;
  }

  selectIncidentType(event) {
    const button = event.target;
    this.selected = event.target.closest(
      "[data-classify-target='incidentTypeCard']"
    );

    // Disable search input
    const selectedEvent = new CustomEvent("selected-incident-type");
    window.dispatchEvent(selectedEvent);

    // Hide "Select" button of selected card and
    // show "Selected" button before cloning
    button.classList.add("hidden");
    button.nextElementSibling.classList.remove("hidden");
    const dupNode = this.selected.cloneNode(true);

    // Hide all cards
    this.hideOnSelectTargets.forEach((el) => {
      el.classList.add("hidden");
    });

    // Set cloned card in the appropriate div
    // in the form
    this.selectedIncidentCardTarget.innerHTML = "";
    this.selectedIncidentCardTarget.appendChild(dupNode);
    this.selectedFormTarget.classList.remove("hidden");

    // Set the incident type ID in a hidden field
    this.incidentTypeIdTarget.setAttribute(
      "value",
      this.selected.dataset.incidentId
    );
  }

  deselectIncidentType(event) {
    event.preventDefault();
    this.selectedIncidentCardTarget.innerHTML = "";
    this.selectedFormTarget.classList.add("hidden");

    // Enable search input
    const deselectedEvent = new CustomEvent("deselected-incident-type");
    window.dispatchEvent(deselectedEvent);
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

  mouseenter(event) {
    this.hoveredButton = event.target;

    this.hoveredButton.classList.remove("button-selected");
    this.hoveredButton.classList.add("button-deselect");

    this.hoveredButton.childNodes[1].classList.add("hidden");
    this.hoveredButton.childNodes[3].classList.remove("hidden");

    this.hoveredButton.innerHTML = this.hoveredButton.innerHTML.replace(
      "Selected",
      "Deselect"
    );
  }

  mouseleave() {
    if (this.hoveredButton !== null) {
      this.hoveredButton.classList.add("button-selected");
      this.hoveredButton.classList.remove("button-deselect");

      this.hoveredButton.childNodes[1].classList.remove("hidden");
      this.hoveredButton.childNodes[3].classList.add("hidden");

      this.hoveredButton.innerHTML = this.hoveredButton.innerHTML.replace(
        "Deselect",
        "Selected"
      );

      this.hoveredButton = null;
    }
  }

  submitUnknown(e) {
    e.preventDefault();
    this.incidentTypeUnknownTarget.setAttribute("value", true);
    this.selectedFormTarget.requestSubmit();
  }

  submit(e) {
    e.preventDefault();
    this.selectedFormTarget.requestSubmit();
    this.selectedFormTarget.classList.add("hidden");
  }
}
