import { r as registerInstance, h } from './index-7ba6cdd3.js';

const booleanFieldCss = "";

const BooleanField = class {
    constructor(hostRef) {
        registerInstance(this, hostRef);
    }
    render() {
        const name = this.name;
        return (h("div", { class: "form-group" }, h("div", { class: "form-check" }, h("input", { id: name, name: name, class: "form-check-input", type: "checkbox", value: 'true', checked: this.checked }), h("label", { class: "form-check-label", htmlFor: name }, this.label)), h("small", { class: "form-text text-muted" }, this.hint)));
    }
};
BooleanField.style = booleanFieldCss;

export { BooleanField as wf_boolean_field };
