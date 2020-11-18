from core.views.crud_views import LoginRequired
from django.shortcuts import render
from django.views import View

class WorkflowView(LoginRequired, View):
    template_name = 'core/workflow.html'

    # @method_decorator(login_required)
    def get(self, request, *args, **kwargs):
        components = """[{
              "type": "ReceiveHttpRequest",
              "displayName": "Receive HTTP Request",
              "description": "Receive an incoming HTTP request.",
              "runtimeDescription": "x => !!x.state.path ? `Handle <strong>${ x.state.method } ${ x.state.path }</strong>.` : x.definition.description",
              "category": "HTTP",
              "outcomes": ["Done"],
              "properties": [
                {
                  "name": "path",
                  "type": "text",
                  "label": "Path",
                  "hint": "The relative path that triggers this activity.",
                  "options": {}
                },
                {
                  "name": "method",
                  "type": "select",
                  "label": "Method",
                  "hint": "The HTTP method that triggers this activity.",
                  "options": {
                    "items": [
                      "GET",
                      "POST",
                      "PUT",
                      "DELETE",
                      "PATCH",
                      "OPTIONS",
                      "POOP"
                    ]
                  }
                },
                {
                  "name": "readContent",
                  "type": "boolean",
                  "label": "Read Content",
                  "hint": "A value indicating whether the HTTP request content body should be read and stored as part of the HTTP request model. The stored format depends on the content-type header.",
                  "options": {}
                },
                {
                  "name": "name",
                  "type": "text",
                  "label": "Name",
                  "hint": "Optionally provide a name for this activity. You can reference named activities from expressions.",
                  "options": {}
                },
                {
                  "name": "title",
                  "type": "text",
                  "label": "Title",
                  "hint": "Optionally provide a custom title for this activity.",
                  "options": {}
                },
                {
                  "name": "description",
                  "type": "text",
                  "label": "Description",
                  "hint": "Optionally provide a custom description for this activity.",
                  "options": {}
                }
              ]
            }]"""
        # workflow = """{"activities":[{"id":"timer","top":137,"left":171,"type":"TimerEvent","state":{}, "executed":true},{"id":"send-email","top":641,"left":193,"type":"SendEmail","state":{}, "blocking":true},{"id":"if-else","top":378,"left":139,"type":"IfElse","state":{}},{"id":"log","top":644,"left":438,"type":"Log","state":{}, "faulted":true, "message":{"title":"Faulted","content":"This didnt work."}}],"connections":[{"sourceActivityId":"timer","destinationActivityId":"if-else","outcome":"Done"},{"sourceActivityId":"if-else","destinationActivityId":"send-email","outcome":"True"},{"sourceActivityId":"if-else","destinationActivityId":"log","outcome":"False"}]}"""
        workflow = """
                                    {
                    "activities": [
                        {
                            "id": "2c8d9868-a0ce-416f-b07f-915186b93a54",
                            "top": 159,
                            "left": 673,
                            "type": "ReceiveHttpRequest",
                            "state": {}
                        },
                        {
                            "id": "2cfafd9c-1b76-4497-8111-fe79edd30ef5",
                            "top": 150,
                            "left": 150,
                            "type": "ReceiveHttpRequest",
                            "state": {}
                        }
                    ],
                    "connections": [
                        {
                            "sourceActivityId": "2cfafd9c-1b76-4497-8111-fe79edd30ef5",
                            "destinationActivityId": "2c8d9868-a0ce-416f-b07f-915186b93a54",
                            "outcome": ""
                        }
                    ]
                }
                """

        context = {'components': components, 'workflow': workflow}
        
        return render(request, self.template_name, context=context)