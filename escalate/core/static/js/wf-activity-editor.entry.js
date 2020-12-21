import { r as registerInstance, e as createEvent, h, g as getElement } from './index-7ba6cdd3.js';
import { A as ActivityDisplayMode } from './index-e7819c2d.js';

const activityEditorCss = "";

const ActivityEditor = class {
    constructor(hostRef) {
        registerInstance(this, hostRef);
        this.submit = createEvent(this, "update-activity", 7);
        this.activityDefinitions = [];
    }
    async onSubmit(e) {
        e.preventDefault();
        const form = e.target;
        const formData = new FormData(form);
        const updatedActivity = await this.renderer.updateEditor(formData);
        this.submit.emit(updatedActivity);
        this.show = false;
    }
    componentDidRender() {
        const modal = $(this.el.querySelector('.modal'));
        const action = this.show ? 'show' : 'hide';
        modal.modal(action);
    }
    render() {
        const activity = this.activity;
        if (!activity) {
            return null;
        }
        const activityDefinition = this.activityDefinitions.find(x => x.type == activity.type);
        if (!activityDefinition) {
            console.error(`No activity of type ${this.activity.type} exists in the library.`);
            return;
        }
        const displayName = activityDefinition.displayName;
        return (h("div", null, h("div", { class: "modal", tabindex: "-1", role: "dialog" }, h("div", { class: "modal-dialog modal-xl", role: "document" }, h("div", { class: "modal-content" }, h("form", { onSubmit: e => this.onSubmit(e) }, h("div", { class: "modal-header" }, h("h5", { class: "modal-title" }, "Edit ", displayName), h("button", { type: "button", class: "close", "data-dismiss": "modal", "aria-label": "Close" }, h("span", { "aria-hidden": "true" }, "\u00D7"))), h("div", { class: "modal-body" }, h("wf-activity-renderer", { activity: activity, activityDefinition: activityDefinition, displayMode: ActivityDisplayMode.Edit, ref: x => this.renderer = x })), h("div", { class: "modal-footer" }, h("button", { type: "button", class: "btn btn-secondary", "data-dismiss": "modal" }, "Cancel"), h("button", { type: "submit", class: "btn btn-primary" }, "Save"))))))));
    }
    get el() { return getElement(this); }
};
ActivityEditor.style = activityEditorCss;

export { ActivityEditor as wf_activity_editor };
