import { r as registerInstance, e as createEvent, h, f as Host, g as getElement } from './index-7ba6cdd3.js';

const contextMenuCss = "";

const ContextMenu = class {
    constructor(hostRef) {
        registerInstance(this, hostRef);
        this.contextMenuEvent = createEvent(this, "context-menu", 7);
        this.isHidden = true;
        this.position = { left: 0, top: 0 };
        this.onContextMenu = (e) => {
            if (e.defaultPrevented)
                return;
            e.preventDefault();
            this.contextMenuEvent.emit();
            this.position = { left: e.pageX, top: e.pageY };
            this.isHidden = false;
        };
        this.onContextMenuClick = () => {
            this.isHidden = true;
        };
    }
    targetChangeHandler(newValue, oldValue) {
        if (!!oldValue) {
            oldValue.removeEventListener('contextmenu', this.onContextMenu);
        }
        this.setupTarget(newValue);
    }
    targetSelectorChangeHandler(newValue) {
        this.target = document.querySelector(newValue);
    }
    handleBodyClick() {
        this.isHidden = true;
    }
    handleContextMenu() {
        this.isHidden = true;
    }
    async handleContextMenuEvent(e) {
        this.onContextMenu(e);
    }
    componentDidLoad() {
        this.setupTarget(this.target);
    }
    render() {
        const css = {
            left: `${this.position.left}px`,
            top: `${this.position.top}px`,
            display: this.isHidden ? 'none' : 'block'
        };
        return (h(Host, { class: "dropdown-menu context-menu canvas-context-menu position-fixed", style: css, onClick: this.onContextMenuClick }, h("slot", null)));
    }
    setupTarget(value) {
        if (!!value) {
            value.addEventListener('contextmenu', this.onContextMenu, { capture: false });
        }
    }
    get el() { return getElement(this); }
    static get watchers() { return {
        "target": ["targetChangeHandler"],
        "targetSelector": ["targetSelectorChangeHandler"]
    }; }
};
ContextMenu.style = contextMenuCss;

export { ContextMenu as wf_context_menu };
