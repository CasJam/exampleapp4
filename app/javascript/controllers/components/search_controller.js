import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["searchModal", "input", "results"];
  static values = {};

  connect() {}

  launch() {
    var searchModal = this.searchModalTarget;

    if (searchModal) {
      searchModal.classList.remove("hidden");

      this.inputTarget.value = "";
      this.inputTarget.focus();
    }
  }

  keyboardLaunch(event) {
    if (event.key === "/") {
      // Don't trigger if any input, textarea, or contenteditable element is focused
      const activeElement = document.activeElement;
      const isEditable = activeElement.tagName === 'INPUT' ||
                        activeElement.tagName === 'TEXTAREA' ||
                        activeElement.isContentEditable;

      // Launch search modal when user types "/"
      if (!isEditable) {
        event.preventDefault();
        this.launch();
      }
    }
  }

  close() {
    var searchModal = this.searchModalTarget;
    if (searchModal) {
      this.reset(searchModal);
    }
  }

  keyboardClose(event) {
    if (event.key === "Escape") {
      const searchModalOpen = this.searchModalTarget && this.searchModalTarget.classList.contains("hidden") === false;
      if (searchModalOpen) {
        this.close();
      }
    }
  }

  clickOutsideHide(event) {
    var searchModal = this.searchModalTarget;
    if (searchModal) {
      var searchModalBox = searchModal.querySelector(".search-modal-box");

      if (searchModalBox.contains(event.target) === false) {
        this.reset(searchModal);
      }
    }
  }

  reset() {
    this.searchModalTarget.classList.add("hidden");
    this.inputTarget.value = "";
    this.resultsTarget.innerHTML = "";
    this.resultsTarget.classList.add("hidden");
  }

  search(event) {
    const query = event.target.value;

    if (query.length > 0) {
      fetch(`/search?query=${encodeURIComponent(query)}`, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html"
        }
      })
      .then(response => response.text())
      .then(html => {
        Turbo.renderStreamMessage(html);
        this.resultsTarget.classList.remove("hidden");
      });
    } else {
      this.resultsTarget.classList.add("hidden");
      this.resultsTarget.innerHTML = "";
    }
  }

  navigateResults(event) {
    if (event.key === "ArrowDown" || event.key === "ArrowUp") {
      event.preventDefault();

      const results = this.resultsTarget.querySelectorAll('.search-result');
      if (results.length === 0) return;

      const currentFocused = document.activeElement;
      const isInputFocused = currentFocused === this.inputTarget;

      if (event.key === "ArrowDown") {
        if (isInputFocused) {
          // If input is focused, focus first result
          results[0].focus();
        } else {
          // Find current focused result
          const currentIndex = Array.from(results).indexOf(currentFocused);
          if (currentIndex < results.length - 1) {
            // Focus next result if not at bottom
            results[currentIndex + 1].focus();
          }
          // If at bottom, stay focused on last result
        }
      } else if (event.key === "ArrowUp") {
        if (isInputFocused) {
          // If input is focused, stay on input
          return;
        }

        // Find current focused result
        const currentIndex = Array.from(results).indexOf(currentFocused);
        if (currentIndex > 0) {
          // Focus previous result if not at top
          results[currentIndex - 1].focus();
        } else {
          // If at top, focus input
          this.inputTarget.focus();
        }
      }
    }
  }
}
