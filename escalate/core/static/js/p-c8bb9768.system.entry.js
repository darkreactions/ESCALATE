System.register(["./p-a5a09fce.system.js"],(function(t){"use strict";var e,n;return{setters:[function(t){e=t.r;n=t.h}],execute:function(){var r="wf-expression-field .input-group>.form-control:not(:last-child){border-top-left-radius:0.25rem;border-bottom-left-radius:0.25rem}";var a=t("wf_expression_field",function(){function t(t){var r=this;e(this,t);this.selectSyntax=function(t){return r.syntax=t};this.onSyntaxOptionClick=function(t,e){t.preventDefault();r.selectSyntax(e)};this.renderInputField=function(){var t=r.name;var e=r.value;if(r.multiline)return n("textarea",{id:t,name:t+".expression",class:"form-control",rows:3},e);return n("input",{id:t,name:t+".expression",value:e,type:"text",class:"form-control"})}}t.prototype.render=function(){var t=this;var e=this.name;var r=this.label;var a=this.hint;var i=["Literal","JavaScript","Liquid"];var o=this.syntax||"Literal";return n("host",null,n("label",{htmlFor:e},r),n("div",{class:"input-group"},n("input",{name:e+".syntax",value:o,type:"hidden"}),this.renderInputField(),n("div",{class:"input-group-append"},n("button",{class:"btn btn-primary dropdown-toggle",type:"button",id:e+"_dropdownMenuButton","data-toggle":"dropdown","aria-haspopup":"true","aria-expanded":"false"},o),n("div",{class:"dropdown-menu","aria-labelledby":e+"_dropdownMenuButton"},i.map((function(e){return n("a",{onClick:function(n){return t.onSyntaxOptionClick(n,e)},class:"dropdown-item",href:"#"},e)}))))),n("small",{class:"form-text text-muted"},a))};return t}());a.style=r}}}));