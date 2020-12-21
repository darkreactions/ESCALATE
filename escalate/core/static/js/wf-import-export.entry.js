import { r as registerInstance, e as createEvent, h, g as getElement } from './index-7ba6cdd3.js';
import { c as createCommonjsModule } from './_commonjsHelpers-0fb73f97.js';

var remedial = createCommonjsModule(function (module) {
/*jslint onevar: true, undef: true, nomen: true, eqeqeq: true, plusplus: true, bitwise: true, regexp: true, newcap: true, immed: true */
(function () {
    "use strict";

    var global = Function('return this')()
      , classes = "Boolean Number String Function Array Date RegExp Object".split(" ")
      , i
      , name
      , class2type = {}
      ;

    for (i in classes) {
      if (classes.hasOwnProperty(i)) {
        name = classes[i];
        class2type["[object " + name + "]"] = name.toLowerCase();
      }
    }

    function typeOf(obj) {
      return (null === obj || undefined === obj) ? String(obj) : class2type[Object.prototype.toString.call(obj)] || "object";
    }

    function isEmpty(o) {
        var i, v;
        if (typeOf(o) === 'object') {
            for (i in o) { // fails jslint
                v = o[i];
                if (v !== undefined && typeOf(v) !== 'function') {
                    return false;
                }
            }
        }
        return true;
    }

    if (!String.prototype.entityify) {
        String.prototype.entityify = function () {
            return this.replace(/&/g, "&amp;").replace(/</g,
                "&lt;").replace(/>/g, "&gt;");
        };
    }

    if (!String.prototype.quote) {
        String.prototype.quote = function () {
            var c, i, l = this.length, o = '"';
            for (i = 0; i < l; i += 1) {
                c = this.charAt(i);
                if (c >= ' ') {
                    if (c === '\\' || c === '"') {
                        o += '\\';
                    }
                    o += c;
                } else {
                    switch (c) {
                    case '\b':
                        o += '\\b';
                        break;
                    case '\f':
                        o += '\\f';
                        break;
                    case '\n':
                        o += '\\n';
                        break;
                    case '\r':
                        o += '\\r';
                        break;
                    case '\t':
                        o += '\\t';
                        break;
                    default:
                        c = c.charCodeAt();
                        o += '\\u00' + Math.floor(c / 16).toString(16) +
                            (c % 16).toString(16);
                    }
                }
            }
            return o + '"';
        };
    } 

    if (!String.prototype.supplant) {
        String.prototype.supplant = function (o) {
            return this.replace(/{([^{}]*)}/g,
                function (a, b) {
                    var r = o[b];
                    return typeof r === 'string' || typeof r === 'number' ? r : a;
                }
            );
        };
    }

    if (!String.prototype.trim) {
        String.prototype.trim = function () {
            return this.replace(/^\s*(\S*(?:\s+\S+)*)\s*$/, "$1");
        };
    }

    // CommonJS / npm / Ender.JS
    module.exports = {
        typeOf: typeOf,
        isEmpty: isEmpty
    };
    global.typeOf = global.typeOf || typeOf;
    global.isEmpty = global.isEmpty || isEmpty;
}());
});
var remedial_1 = remedial.typeOf;
var remedial_2 = remedial.isEmpty;

var json2yaml = createCommonjsModule(function (module) {
(function () {
  "use strict";

  var typeOf = remedial.typeOf
    ;

  function stringify(data) {
    var handlers
      , indentLevel = ''
      ;

    handlers = {
        "undefined": function () {
          // objects will not have `undefined` converted to `null`
          // as this may have unintended consequences
          // For arrays, however, this behavior seems appropriate
          return 'null';
        }
      , "null": function () {
          return 'null';
        }
      , "number": function (x) {
          return x;
        }
      , "boolean": function (x) {
          return x ? 'true' : 'false';
        }
      , "string": function (x) {
          // to avoid the string "true" being confused with the
          // the literal `true`, we always wrap strings in quotes
          return JSON.stringify(x);
        }
      , "array": function (x) {
          var output = ''
            ;

          if (0 === x.length) {
            output += '[]';
            return output;
          }

          indentLevel = indentLevel.replace(/$/, '  ');
          x.forEach(function (y) {
            // TODO how should `undefined` be handled?
            var handler = handlers[typeOf(y)]
              ;

            if (!handler) {
              throw new Error('what the crap: ' + typeOf(y));
            }

            output += '\n' + indentLevel + '- ' + handler(y);
             
          });
          indentLevel = indentLevel.replace(/  /, '');
          
          return output;
        }
      , "object": function (x) {
          var output = ''
            ;

          if (0 === Object.keys(x).length) {
            output += '{}';
            return output;
          }

          indentLevel = indentLevel.replace(/$/, '  ');
          Object.keys(x).forEach(function (k) {
            var val = x[k]
              , handler = handlers[typeOf(val)]
              ;

            if ('undefined' === typeof val) {
              // the user should do
              // delete obj.key
              // and not
              // obj.key = undefined
              // but we'll error on the side of caution
              return;
            }

            if (!handler) {
              throw new Error('what the crap: ' + typeOf(val));
            }

            output += '\n' + indentLevel + k + ': ' + handler(val);
          });
          indentLevel = indentLevel.replace(/  /, '');

          return output;
        }
      , "function": function () {
          // TODO this should throw or otherwise be ignored
          return '[object Function]';
        }
    };

    return '---' + handlers[typeOf(data)](data) + '\n';
  }

  module.exports.stringify = stringify;
}());
});
var json2yaml_1 = json2yaml.stringify;

const importExportCss = ".import-button{display:none}";

const ImportExport = class {
    constructor(hostRef) {
        registerInstance(this, hostRef);
        this.importEvent = createEvent(this, "import-workflow", 7);
        this.importWorkflow = () => {
            const file = this.fileInput.files[0];
            const reader = new FileReader();
            reader.onload = async () => {
                const data = reader.result;
                const format = 'json';
                const importedData = {
                    data: data,
                    format: format
                };
                await this.import(importedData);
            };
            reader.readAsText(file);
        };
        this.serialize = (workflow, format) => {
            switch (format) {
                case 'json':
                    return JSON.stringify(workflow);
                case 'yaml':
                    return json2yaml.stringify(workflow);
                case 'xml':
                    return JSON.stringify(workflow);
                default:
                    return workflow;
            }
        };
    }
    async export(designer, formatDescriptor) {
        let blobUrl = this.blobUrl;
        if (!!blobUrl) {
            window.URL.revokeObjectURL(blobUrl);
        }
        const workflow = designer.workflow;
        const data = this.serialize(workflow, formatDescriptor.format);
        const blob = new Blob([data], { type: formatDescriptor.mimeType });
        this.blobUrl = blobUrl = window.URL.createObjectURL(blob);
        const downloadLink = document.createElement('a');
        downloadLink.setAttribute('href', blobUrl);
        downloadLink.setAttribute('download', `workflow.${formatDescriptor.fileExtension}`);
        document.body.appendChild(downloadLink);
        downloadLink.click();
        document.body.removeChild(downloadLink);
    }
    async import(data) {
        if (!data) {
            this.fileInput.click();
        }
        else {
            const workflow = JSON.parse(data.data);
            this.importEvent.emit(workflow);
        }
    }
    render() {
        return (h("host", null, h("input", { type: "file", class: "import-button", onChange: this.importWorkflow, ref: el => this.fileInput = el })));
    }
    get el() { return getElement(this); }
};
ImportExport.style = importExportCss;

export { ImportExport as wf_import_export };
