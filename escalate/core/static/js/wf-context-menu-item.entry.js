import { r as registerInstance, h, g as getElement } from './index-7ba6cdd3.js';

const contextMenuItemCss = "";

const ContextMenuItem = class {
    constructor(hostRef) {
        registerInstance(this, hostRef);
    }
    render() {
        const text = this.text;
        return (h("a", { class: "dropdown-item", href: "#", onClick: e => e.preventDefault() }, text));
    }
    get el() { return getElement(this); }
};
ContextMenuItem.style = contextMenuItemCss;

export { ContextMenuItem as wf_context_menu_item };
