import { r as registerInstance, h, f as Host } from './index-7ba6cdd3.js';

const listFieldCss = "";

const ListField = class {
    constructor(hostRef) {
        registerInstance(this, hostRef);
    }
    render() {
        const name = this.name;
        const label = this.label;
        const items = this.items;
        return (h(Host, null, h("label", { htmlFor: name }, label), h("input", { id: name, name: name, type: "text", class: "form-control", value: items }), h("small", { class: "form-text text-muted" }, this.hint)));
    }
};
ListField.style = listFieldCss;

export { ListField as wf_list_field };
