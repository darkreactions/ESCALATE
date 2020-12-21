import { r as registerInstance, h, f as Host } from './index-7ba6cdd3.js';
import { D as DisplayManager } from './display-manager-bf646102.js';
import { A as ActivityDisplayMode } from './index-e7819c2d.js';
import { A as ActivityManager } from './activity-manager-5aab214f.js';

const activityRendererCss = "";

const ActivityRenderer = class {
    constructor(hostRef) {
        registerInstance(this, hostRef);
        this.displayMode = ActivityDisplayMode.Design;
    }
    render() {
        if (!this.activity || !this.activityDefinition)
            return null;
        switch (this.displayMode) {
            case ActivityDisplayMode.Design:
                return this.renderDesigner();
            case ActivityDisplayMode.Edit:
                return this.renderEditor();
        }
    }
    renderDesigner() {
        const activity = this.activity;
        const definition = this.activityDefinition;
        const result = ActivityManager.renderDesigner(activity, definition);
        const iconClass = `${result.icon} mr-1`;
        return (h("div", null, h("h5", null, h("i", { class: iconClass }), result.title), h("p", { innerHTML: result.description })));
    }
    renderEditor() {
        const activity = this.activity;
        const definition = this.activityDefinition;
        const properties = definition.properties;
        return (h(Host, null, properties.map(property => {
            const html = DisplayManager.displayEditor(activity, property);
            return h("div", { class: "form-group", innerHTML: html });
        })));
    }
    async updateEditor(formData) {
        const activity = Object.assign({}, this.activity);
        const definition = this.activityDefinition;
        const properties = definition.properties;
        for (const property of properties) {
            DisplayManager.updateEditor(activity, property, formData);
        }
        return activity;
    }
};
ActivityRenderer.style = activityRendererCss;

export { ActivityRenderer as wf_activity_renderer };
