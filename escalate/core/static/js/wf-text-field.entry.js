import { r as registerInstance, h } from './index-7ba6cdd3.js';

const textFieldCss = "";

const TextField = class {
    constructor(hostRef) {
        registerInstance(this, hostRef);
    }
    render() {
        const name = this.name;
        return (h("host", null, h("label", { htmlFor: name }, this.label), h("input", { id: name, name: name, type: "text", class: "form-control", value: this.value }), h("small", { class: "form-text text-muted" }, this.hint)));
    }
};
TextField.style = textFieldCss;

export { TextField as wf_text_field };
